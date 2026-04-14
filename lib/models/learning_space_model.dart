enum SpaceType { library, cafe, openSpace, coworking }

class LearningSpaceModel {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final SpaceType type;
  final String? address;
  final double? rating;

  const LearningSpaceModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.type,
    this.address,
    this.rating,
  });

  String get typeLabel {
    switch (type) {
      case SpaceType.library:
        return 'Library';
      case SpaceType.cafe:
        return 'Café';
      case SpaceType.openSpace:
        return 'Open Space';
      case SpaceType.coworking:
        return 'Coworking';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'type': type.name,
        'address': address,
        'rating': rating,
      };

  factory LearningSpaceModel.fromJson(Map<String, dynamic> json) =>
      LearningSpaceModel(
        id: json['id'] as String,
        name: json['name'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        type: SpaceType.values.byName(json['type'] as String),
        address: json['address'] as String?,
        rating: (json['rating'] as num?)?.toDouble(),
      );
}
