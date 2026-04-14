class MetadataService {
  Map<String, dynamic> createMetadataObject({
    required String imageCID,
    required String rarity,
    String? name,
    String? description,
  }) {
    return {
      'name': name ?? 'ProofOfSkill NFT',
      'description': description ?? 'Skill NFT reward',
      'image': 'ipfs://$imageCID',
      'attributes': [
        {
          'trait_type': 'Rarity',
          'value': rarity,
        }
      ],
    };
  }

  Future<String> generateMetadataCID(Map<String, dynamic> metadata) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return 'ipfs://generated-metadata-cid';
  }

  Future<Map<String, dynamic>> fetchMetadataFromIPFS(String tokenURI) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'name': 'Minted Skill NFT',
      'description': 'Minted NFT metadata',
      'image': 'ipfs://bafkreia63gorqxj22d6yuxo5di5igfw6qcfzfcophi27kbrg2lxn7p5q6a',
      'attributes': [
        {
          'trait_type': 'Rarity',
          'value': 'Common',
        }
      ],
    };
  }
}
