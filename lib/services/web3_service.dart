import 'package:flutter/foundation.dart';

import 'blockchain_service.dart';
import 'metadata_service.dart';
import 'wallet_service.dart';

class Web3Service {
  final WalletService _walletService = WalletService();
  late final BlockchainService _blockchainService;
  final MetadataService _metadataService = MetadataService();

  Web3Service() {
    _blockchainService = BlockchainService(_walletService);
  }

  bool get isConnected => _walletService.getWalletAddress() != null;
  String? get connectedAddress => _walletService.getWalletAddress();

  Future<String> connectWallet() async {
    await _walletService.initialize();
    return _walletService.connectWallet();
  }

  /// Disconnect wallet.
  Future<void> disconnectWallet() async {
    await _walletService.disconnectWallet();
  }

  Future<double> getBalance() async {
    final address = _walletService.getWalletAddress();
    if (address == null) throw Exception('Wallet not connected');

    try {
      return await _blockchainService.getBalanceEth(address);
    } catch (_) {
      return 0.0;
    }
  }

  Future<String> mintNFT({
    required String metadataUrl,
    required String recipientAddress,
  }) async {
    if (!isConnected) throw Exception('Wallet not connected');
    return _blockchainService.mintNFT(metadataUrl);
  }

  Future<String> mintNFTFromImageCid({
    required String imageCID,
    required String rarity,
  }) async {
    if (!isConnected) throw Exception('Wallet not connected');

    final metadata = _metadataService.createMetadataObject(
      imageCID: imageCID,
      rarity: rarity,
    );
    final tokenUri = await _metadataService.generateMetadataCID(metadata);
    final txHash = await _blockchainService.mintNFT(tokenUri);
    if (kDebugMode) {
      debugPrint('Minted with tokenUri=$tokenUri tx=$txHash');
    }
    return txHash;
  }

  Future<String> transferNFT({
    required String tokenId,
    required String fromAddress,
    required String toAddress,
  }) async {
    if (!isConnected) throw Exception('Wallet not connected');
    return _blockchainService.transferNFT(
      tokenId: tokenId,
      fromAddress: fromAddress,
      toAddress: toAddress,
    );
  }

  Future<List<String>> getOwnedTokenIds(String address) async {
    return _blockchainService.getOwnedTokenIds(address);
  }
}
