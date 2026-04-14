/// Lightweight location data attached to a user.
class UserLocation {
  final double latitude;
  final double longitude;

  const UserLocation({
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };

  factory UserLocation.fromJson(Map<String, dynamic> json) => UserLocation(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
      );

  /// Distance approximation in km (Haversine simplified).
  double distanceTo(UserLocation other) {
    const double kmPerDegLat = 111.0;
    final dLat = (other.latitude - latitude).abs() * kmPerDegLat;
    final dLng = (other.longitude - longitude).abs() *
        kmPerDegLat *
        0.7; // rough cos correction
    return (dLat * dLat + dLng * dLng).sqrt();
  }
}

extension _Sqrt on double {
  double sqrt() {
    if (this <= 0) return 0;
    double x = this;
    double y = (x + 1) / 2;
    while ((y - x / y).abs() > 0.0001) {
      y = (y + x / y) / 2;
    }
    return y;
  }
}
