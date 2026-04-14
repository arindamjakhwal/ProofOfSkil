import '../models/nft_model.dart';

/// NFT service — replace with Web3/Ethereum + IPFS integration.
/// Firebase Firestore for metadata indexing, blockchain for ownership.
class NFTService {
  final List<NFTModel> _allNFTs = [
    NFTModel(
      tokenId: 'nft_001',
      ownerId: 'user_001',
      title: 'Flutter Mastery',
      description: 'Certified Flutter developer — 10+ sessions completed',
      metadataUrl: 'ipfs://QmFlutterMastery001',
      iconName: 'flutter_dash',
      price: 0.05,
      status: NFTStatus.owned,
      skill: 'Flutter',
      createdAt: DateTime(2026, 2, 15),
    ),
    NFTModel(
      tokenId: 'nft_002',
      ownerId: 'user_001',
      title: 'Python Pro',
      description: 'Advanced Python programming skills verified',
      metadataUrl: 'ipfs://QmPythonPro002',
      iconName: 'code',
      price: 0.03,
      status: NFTStatus.owned,
      skill: 'Python',
      createdAt: DateTime(2026, 3, 1),
    ),
    NFTModel(
      tokenId: 'nft_003',
      ownerId: 'user_002',
      title: 'React Expert',
      description: 'React.js expertise — top 5% skill exchange rating',
      metadataUrl: 'ipfs://QmReactExpert003',
      iconName: 'web',
      price: 0.04,
      status: NFTStatus.available,
      skill: 'React',
      createdAt: DateTime(2026, 1, 20),
    ),
    NFTModel(
      tokenId: 'nft_004',
      ownerId: 'user_003',
      title: 'Design Guru',
      description: 'UI/UX Design mastery — 15+ sessions with 4.5+ rating',
      metadataUrl: 'ipfs://QmDesignGuru004',
      iconName: 'palette',
      price: 0.06,
      status: NFTStatus.available,
      skill: 'UI/UX Design',
      createdAt: DateTime(2026, 3, 10),
    ),
    NFTModel(
      tokenId: 'nft_005',
      ownerId: 'user_004',
      title: 'ML Pioneer',
      description: 'Machine Learning expertise verified through skill exchange',
      metadataUrl: 'ipfs://QmMLPioneer005',
      iconName: 'psychology',
      price: 0.08,
      status: NFTStatus.forSale,
      skill: 'Machine Learning',
      createdAt: DateTime(2026, 2, 28),
    ),
    NFTModel(
      tokenId: 'nft_006',
      ownerId: 'user_005',
      title: 'Blockchain Builder',
      description: 'Solidity smart contract development skills verified',
      metadataUrl: 'ipfs://QmBlockchainBuilder006',
      iconName: 'link',
      price: 0.10,
      status: NFTStatus.available,
      skill: 'Blockchain',
      createdAt: DateTime(2026, 3, 15),
    ),
    NFTModel(
      tokenId: 'nft_007',
      ownerId: 'user_002',
      title: 'Data Wizard',
      description: 'Data Science proficiency — top-tier analytics skills',
      metadataUrl: 'ipfs://QmDataWizard007',
      iconName: 'analytics',
      price: 0.07,
      status: NFTStatus.available,
      skill: 'Data Science',
      createdAt: DateTime(2026, 3, 20),
    ),
    NFTModel(
      tokenId: 'nft_008',
      ownerId: 'user_006',
      title: 'Content Creator',
      description: 'Content writing mastery — proven skill exchange track record',
      metadataUrl: 'ipfs://QmContentCreator008',
      iconName: 'edit_note',
      price: 0.02,
      status: NFTStatus.forSale,
      skill: 'Content Writing',
      createdAt: DateTime(2026, 4, 1),
    ),
  ];

  /// Get NFTs owned by user.
  /// Replace with: Query Firestore where ownerId == userId
  Future<List<NFTModel>> getUserNFTs(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _allNFTs.where((n) => n.ownerId == userId).toList();
  }

  /// Get NFTs available for purchase (not owned by user).
  /// Replace with: Query Firestore where status == 'available' || 'forSale'
  Future<List<NFTModel>> getAvailableNFTs(String excludeUserId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _allNFTs
        .where((n) =>
            n.ownerId != excludeUserId &&
            (n.status == NFTStatus.available || n.status == NFTStatus.forSale))
        .toList();
  }

  /// Buy an NFT.
  /// Replace with: Smart contract call + Firestore update
  Future<NFTModel> buyNFT(String tokenId, String buyerId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _allNFTs.indexWhere((n) => n.tokenId == tokenId);
    if (index >= 0) {
      _allNFTs[index] = _allNFTs[index].copyWith(
        ownerId: buyerId,
        status: NFTStatus.owned,
      );
      return _allNFTs[index];
    }
    throw Exception('NFT not found');
  }

  /// List NFT for sale.
  /// Replace with: Smart contract approve + Firestore update
  Future<NFTModel> listForSale(String tokenId, double price) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _allNFTs.indexWhere((n) => n.tokenId == tokenId);
    if (index >= 0) {
      _allNFTs[index] = _allNFTs[index].copyWith(
        price: price,
        status: NFTStatus.forSale,
      );
      return _allNFTs[index];
    }
    throw Exception('NFT not found');
  }

  /// Remove NFT from sale listing.
  /// Replace with: Smart contract revoke + Firestore update
  Future<NFTModel> delistNFT(String tokenId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _allNFTs.indexWhere((n) => n.tokenId == tokenId);
    if (index >= 0) {
      _allNFTs[index] = _allNFTs[index].copyWith(
        status: NFTStatus.owned,
      );
      return _allNFTs[index];
    }
    throw Exception('NFT not found');
  }
}
