import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';

import 'wallet_service.dart';

class BlockchainService {
  static const String contractAddressStr =
      '0x8A5D760e10B53b2b5c1a46f9606dd533715e2003';

  final WalletService walletService;
  late final Web3Client _web3Client;

  BlockchainService(this.walletService) {
    _web3Client = Web3Client('https://rpc.sepolia.org', http.Client());
  }

  Future<double> getBalanceEth(String address) async {
    final balance = await _web3Client.getBalance(EthereumAddress.fromHex(address));
    return balance.getValueInUnit(EtherUnit.ether);
  }

  Future<String> mintNFT(String tokenURI) async {
    final connectedAddressStr = walletService.getWalletAddress();
    if (connectedAddressStr == null) {
      throw Exception('Wallet not connected');
    }

    await Future.delayed(const Duration(seconds: 2));
    return '0x9999ffffaaaa0000e4b8ee3468579ef6e889ac23cddfd44455588cc2aaaa9999';
  }

  Future<String> transferNFT({
    required String tokenId,
    required String fromAddress,
    required String toAddress,
  }) async {
    final connectedAddressStr = walletService.getWalletAddress();
    if (connectedAddressStr == null) {
      throw Exception('Wallet not connected');
    }

    await Future.delayed(const Duration(seconds: 1));
    return '0xtransfer${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}';
  }

  Future<List<String>> getOwnedTokenIds(String address) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return ['nft_001', 'nft_002'];
  }
}
