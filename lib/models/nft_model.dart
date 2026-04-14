enum NFTStatus { owned, forSale, available }

class NFTModel {
  final String tokenId;
  final String ownerId;
  final String title;
  final String description;
  final String? metadataUrl; // IPFS CID
  final String? imageUrl;
  final String iconName; // Material icon fallback
  final double price; // in ETH
  final NFTStatus status;
  final String? skill; // skill this NFT certifies
  final DateTime createdAt;

  const NFTModel({
    required this.tokenId,
    required this.ownerId,
    required this.title,
    required this.description,
    this.metadataUrl,
    this.imageUrl,
    this.iconName = 'verified',
    required this.price,
    this.status = NFTStatus.available,
    this.skill,
    required this.createdAt,
  });

  NFTModel copyWith({
    String? ownerId,
    double? price,
    NFTStatus? status,
  }) {
    return NFTModel(
      tokenId: tokenId,
      ownerId: ownerId ?? this.ownerId,
      title: title,
      description: description,
      metadataUrl: metadataUrl,
      imageUrl: imageUrl,
      iconName: iconName,
      price: price ?? this.price,
      status: status ?? this.status,
      skill: skill,
      createdAt: createdAt,
    );
  }

  /// JSON serialization — ready for Firestore
  Map<String, dynamic> toJson() => {
        'tokenId': tokenId,
        'ownerId': ownerId,
        'title': title,
        'description': description,
        'metadataUrl': metadataUrl,
        'imageUrl': imageUrl,
        'iconName': iconName,
        'price': price,
        'status': status.name,
        'skill': skill,
        'createdAt': createdAt.toIso8601String(),
      };

  factory NFTModel.fromJson(Map<String, dynamic> json) => NFTModel(
        tokenId: json['tokenId'] as String,
        ownerId: json['ownerId'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        metadataUrl: json['metadataUrl'] as String?,
        imageUrl: json['imageUrl'] as String?,
        iconName: json['iconName'] as String? ?? 'verified',
        price: (json['price'] as num).toDouble(),
        status: NFTStatus.values.byName(json['status'] as String),
        skill: json['skill'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
