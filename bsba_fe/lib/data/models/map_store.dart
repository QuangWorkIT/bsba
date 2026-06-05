class MapStore {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String hours;
  final double rating;
  final String description;
  final double? distanceKm;
  final String? coverImageUrl;

  const MapStore({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.hours,
    required this.rating,
    required this.description,
    this.distanceKm,
    this.coverImageUrl,
  });

  factory MapStore.fromJson(Map<String, dynamic> json) {
    final openTime = json['openTime'] as String? ?? '09:00:00';
    final closeTime = json['closeTime'] as String? ?? '22:00:00';

    return MapStore(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      hours: _formatHours(openTime, closeTime),
      rating: (json['ratingAvg'] as num?)?.toDouble() ?? 0,
      description: json['description'] as String? ?? '',
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      coverImageUrl: json['coverImageUrl'] as String?,
    );
  }

  static String formatDistanceKm(double kilometers) {
    if (kilometers < 1) {
      return '${(kilometers * 1000).round()} m away';
    }
    return '${kilometers.toStringAsFixed(1)} km away';
  }

  static String _formatHours(String openTime, String closeTime) {
    return 'Open ${_formatTime(openTime)} - ${_formatTime(closeTime)}';
  }

  static String _formatTime(String time) {
    final parts = time.split(':');
    if (parts.length < 2) return time;

    var hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;

    return minute == '00' ? '$hour:00 $period' : '$hour:$minute $period';
  }
}
