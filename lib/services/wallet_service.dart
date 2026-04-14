import 'package:url_launcher/url_launcher.dart';

class WalletService {
  String? _connectedAddress;

  Future<void> initialize() async {}

  Future<String> connectWallet() async {
    if (_connectedAddress != null) return _connectedAddress!;

    final Uri deepLink = Uri.parse('https://metamask.app.link/dapp/proofofskill.app');
    await launchUrl(deepLink, mode: LaunchMode.externalApplication);
    await Future.delayed(const Duration(seconds: 2));

    _connectedAddress = '0x123400000000000000000000000000000000abcd';
    return _connectedAddress!;
  }

  Future<void> disconnectWallet() async {
    _connectedAddress = null;
  }

  String? getWalletAddress() => _connectedAddress;
}
