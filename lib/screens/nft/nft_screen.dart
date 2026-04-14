import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/nft_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/nft_provider.dart';

import '../../widgets/primary_button.dart';

class NFTScreen extends StatefulWidget {
  const NFTScreen({super.key});

  @override
  State<NFTScreen> createState() => _NFTScreenState();
}

class _NFTScreenState extends State<NFTScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        final nft = context.read<NFTProvider>();
        nft.loadHoldings(user.id);
        nft.loadMarketplace(user.id);
      }
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nft = context.watch<NFTProvider>();
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'NFT Marketplace',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          if (nft.isWalletConnected)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.account_balance_wallet,
                          color: AppColors.success, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${nft.balance.toStringAsFixed(3)} ETH',
                        style: const TextStyle(
                          color: AppColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(49),
          child: Column(
            children: [
              TabBar(
                controller: _tabCtrl,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textMuted,
                indicatorColor: AppColors.primary,
                indicatorWeight: 2.5,
                labelStyle: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: 'Holdings'),
                  Tab(text: 'Buy'),
                  Tab(text: 'Sell'),
                ],
              ),
              Container(height: 1, color: AppColors.border),
            ],
          ),
        ),
      ),
      body: !nft.isWalletConnected
          ? _buildConnectWallet(nft)
          : TabBarView(
              controller: _tabCtrl,
              children: [
                _HoldingsTab(holdings: nft.holdings),
                _BuyTab(
                  marketplace: nft.marketplace,
                  userId: user?.id ?? '',
                  onBuy: (tokenId) =>
                      nft.buyNFT(tokenId, user?.id ?? ''),
                ),
                _SellTab(
                  holdings: nft.holdings,
                  onList: (tokenId, price) =>
                      nft.listForSale(tokenId, price),
                  onDelist: (tokenId) => nft.delistNFT(tokenId),
                ),
              ],
            ),
    );
  }

  Widget _buildConnectWallet(NFTProvider nft) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.account_balance_wallet_rounded,
                  color: AppColors.primary, size: 40),
            ),
            const SizedBox(height: 24),
            const Text(
              'Connect Your Wallet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Connect your MetaMask wallet to browse,\nbuy, and sell skill NFTs.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Network: Ethereum Sepolia Testnet',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Connect MetaMask',
              icon: Icons.account_balance_wallet_rounded,
              isLoading: nft.isLoading,
              onPressed: () => nft.connectWallet(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Holdings Tab ───────────────────────────────────────────
class _HoldingsTab extends StatelessWidget {
  final List<NFTModel> holdings;
  const _HoldingsTab({required this.holdings});

  @override
  Widget build(BuildContext context) {
    if (holdings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.collections_rounded,
                color: AppColors.textMuted, size: 48),
            SizedBox(height: 12),
            Text('No NFTs yet',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 16)),
            SizedBox(height: 4),
            Text('Complete sessions to earn skill NFTs',
                style: TextStyle(
                    color: AppColors.textMuted, fontSize: 13)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.78,
      ),
      itemCount: holdings.length,
      itemBuilder: (_, i) => _NFTCard(nft: holdings[i]),
    );
  }
}

// ─── Buy Tab ────────────────────────────────────────────────
class _BuyTab extends StatelessWidget {
  final List<NFTModel> marketplace;
  final String userId;
  final Future<bool> Function(String) onBuy;

  const _BuyTab({
    required this.marketplace,
    required this.userId,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    if (marketplace.isEmpty) {
      return const Center(
        child: Text('No NFTs available right now',
            style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.68,
      ),
      itemCount: marketplace.length,
      itemBuilder: (_, i) => _MarketNFTCard(
        nft: marketplace[i],
        onBuy: () => onBuy(marketplace[i].tokenId),
      ),
    );
  }
}

// ─── Sell Tab ────────────────────────────────────────────────
class _SellTab extends StatelessWidget {
  final List<NFTModel> holdings;
  final Future<bool> Function(String, double) onList;
  final Future<bool> Function(String) onDelist;

  const _SellTab({
    required this.holdings,
    required this.onList,
    required this.onDelist,
  });

  @override
  Widget build(BuildContext context) {
    final ownedNFTs = holdings;

    if (ownedNFTs.isEmpty) {
      return const Center(
        child: Text('No NFTs to sell',
            style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: ownedNFTs.length,
      itemBuilder: (_, i) => _SellNFTTile(
        nft: ownedNFTs[i],
        onList: (price) => onList(ownedNFTs[i].tokenId, price),
        onDelist: () => onDelist(ownedNFTs[i].tokenId),
      ),
    );
  }
}

// ─── NFT Card (Holdings) ────────────────────────────────────
class _NFTCard extends StatelessWidget {
  final NFTModel nft;
  const _NFTCard({required this.nft});

  IconData _getIcon() {
    switch (nft.iconName) {
      case 'flutter_dash':
        return Icons.flutter_dash;
      case 'code':
        return Icons.code_rounded;
      case 'web':
        return Icons.web_rounded;
      case 'palette':
        return Icons.palette_rounded;
      case 'psychology':
        return Icons.psychology_rounded;
      case 'link':
        return Icons.link_rounded;
      case 'analytics':
        return Icons.analytics_rounded;
      case 'edit_note':
        return Icons.edit_note_rounded;
      default:
        return Icons.verified_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.15)),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          // Icon area
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryLight,
                    AppColors.primary.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16)),
              ),
              child: Center(
                child: Icon(_getIcon(),
                    size: 44, color: AppColors.primary),
              ),
            ),
          ),
          // Info area
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nft.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.diamond_rounded,
                          size: 12, color: AppColors.secondary),
                      const SizedBox(width: 4),
                      Text(
                        '${nft.price} ETH',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: nft.status == NFTStatus.forSale
                          ? AppColors.warningLight
                          : AppColors.successLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      nft.status == NFTStatus.forSale
                          ? 'Listed'
                          : 'Owned',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: nft.status == NFTStatus.forSale
                            ? AppColors.warning
                            : AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Marketplace NFT Card ───────────────────────────────────
class _MarketNFTCard extends StatelessWidget {
  final NFTModel nft;
  final VoidCallback onBuy;
  const _MarketNFTCard({required this.nft, required this.onBuy});

  IconData _getIcon() {
    switch (nft.iconName) {
      case 'flutter_dash':
        return Icons.flutter_dash;
      case 'code':
        return Icons.code_rounded;
      case 'web':
        return Icons.web_rounded;
      case 'palette':
        return Icons.palette_rounded;
      case 'psychology':
        return Icons.psychology_rounded;
      case 'link':
        return Icons.link_rounded;
      case 'analytics':
        return Icons.analytics_rounded;
      case 'edit_note':
        return Icons.edit_note_rounded;
      default:
        return Icons.verified_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.secondaryLight,
                    AppColors.secondary.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16)),
              ),
              child: Center(
                child: Icon(_getIcon(),
                    size: 44, color: AppColors.secondary),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nft.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    nft.description,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textMuted),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        '${nft.price} ETH',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: onBuy,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Buy',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sell NFT Tile ──────────────────────────────────────────
class _SellNFTTile extends StatefulWidget {
  final NFTModel nft;
  final Future<bool> Function(double) onList;
  final VoidCallback onDelist;

  const _SellNFTTile({
    required this.nft,
    required this.onList,
    required this.onDelist,
  });

  @override
  State<_SellNFTTile> createState() => _SellNFTTileState();
}

class _SellNFTTileState extends State<_SellNFTTile> {
  final _priceCtrl = TextEditingController();

  @override
  void dispose() {
    _priceCtrl.dispose();
    super.dispose();
  }

  void _showPriceDialog() {
    _priceCtrl.clear();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Set Price',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Price in ETH',
                  suffixText: 'ETH',
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                text: 'List for Sale',
                onPressed: () {
                  final price =
                      double.tryParse(_priceCtrl.text) ?? 0.0;
                  if (price > 0) {
                    widget.onList(price);
                    Navigator.pop(ctx);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isForSale = widget.nft.status == NFTStatus.forSale;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isForSale
              ? AppColors.warning.withValues(alpha: 0.3)
              : AppColors.border,
        ),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.verified_rounded,
                color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.nft.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isForSale
                      ? 'Listed at ${widget.nft.price} ETH'
                      : widget.nft.skill ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: isForSale
                        ? AppColors.warning
                        : AppColors.textSecondary,
                    fontWeight: isForSale
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: isForSale ? widget.onDelist : _showPriceDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isForSale
                    ? AppColors.errorLight
                    : AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isForSale ? 'Delist' : 'Sell',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isForSale
                      ? AppColors.error
                      : AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
