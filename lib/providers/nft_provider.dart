import 'package:flutter/material.dart';
import '../models/nft_model.dart';
import '../services/nft_service.dart';
import '../services/web3_service.dart';

class NFTProvider extends ChangeNotifier {
  final NFTService _nftService = NFTService();
  final Web3Service _web3Service = Web3Service();

  List<NFTModel> _holdings = [];
  List<NFTModel> _marketplace = [];
  bool _isLoading = false;
  bool _isWalletConnected = false;
  String? _walletAddress;
  double _balance = 0.0;
  String? _error;

  List<NFTModel> get holdings => _holdings;
  List<NFTModel> get marketplace => _marketplace;
  bool get isLoading => _isLoading;
  bool get isWalletConnected => _isWalletConnected;
  String? get walletAddress => _walletAddress;
  double get balance => _balance;
  String? get error => _error;

  /// Load user's NFT holdings.
  Future<void> loadHoldings(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _holdings = await _nftService.getUserNFTs(userId);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Load NFTs available for purchase.
  Future<void> loadMarketplace(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _marketplace = await _nftService.getAvailableNFTs(userId);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Connect MetaMask wallet.
  Future<bool> connectWallet() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _walletAddress = await _web3Service.connectWallet();
      _balance = await _web3Service.getBalance();
      _isWalletConnected = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Disconnect wallet.
  Future<void> disconnectWallet() async {
    await _web3Service.disconnectWallet();
    _isWalletConnected = false;
    _walletAddress = null;
    _balance = 0.0;
    notifyListeners();
  }

  /// Buy an NFT from marketplace.
  Future<bool> buyNFT(String tokenId, String buyerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (!_isWalletConnected) {
        throw Exception('Wallet not connected');
      }
      final nft = await _nftService.buyNFT(tokenId, buyerId);
      _holdings.add(nft);
      _marketplace.removeWhere((n) => n.tokenId == tokenId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// List an owned NFT for sale.
  Future<bool> listForSale(String tokenId, double price) async {
    _error = null;
    try {
      if (!_isWalletConnected) {
        throw Exception('Wallet not connected');
      }
      final nft = await _nftService.listForSale(tokenId, price);
      final index = _holdings.indexWhere((n) => n.tokenId == tokenId);
      if (index >= 0) {
        _holdings[index] = nft;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Remove an NFT from sale listing.
  Future<bool> delistNFT(String tokenId) async {
    _error = null;
    try {
      final nft = await _nftService.delistNFT(tokenId);
      final index = _holdings.indexWhere((n) => n.tokenId == tokenId);
      if (index >= 0) {
        _holdings[index] = nft;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
