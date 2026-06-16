import 'board_game.dart';

class Amenity {
  final String label;
  final String iconName; // mapped to IconData in the UI layer

  const Amenity({required this.label, required this.iconName});
}

class SpaceHost {
  final String name;
  final String avatarUrl;
  final bool isVerified;

  const SpaceHost({
    required this.name,
    required this.avatarUrl,
    required this.isVerified,
  });
}

class SpaceSlot {
  final String id;
  final String startTime;

  const SpaceSlot({required this.id, required this.startTime});
}

class BoardSpaceDetail {
  final String id;
  final String name;
  final String description;
  final String address;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final int maxPlayers;
  final int areaSqFt;
  final double pricePerHour;
  final List<SpaceSlot> availableSlots;
  final List<Amenity> amenities;
  final List<BoardGame> libraryHighlights;
  final int totalGames;
  final String openHours; // e.g. "10:00 AM – 11:00 PM"
  final SpaceHost host;
  final String? phone;
  final String? email;
  final double? latitude;
  final double? longitude;

  const BoardSpaceDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.maxPlayers,
    required this.areaSqFt,
    required this.pricePerHour,
    required this.availableSlots,
    required this.amenities,
    required this.libraryHighlights,
    required this.totalGames,
    required this.openHours,
    required this.host,
    this.phone,
    this.email,
    this.latitude,
    this.longitude,
  });

  factory BoardSpaceDetail.fromJson(Map<String, dynamic> json) {
    return BoardSpaceDetail(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      imageUrl:
          json['coverImageUrl'] ??
          'https://images.unsplash.com/photo-1611532736597-de2d4265fba3?w=900&q=80',
      rating: (json['ratingAvg'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] ?? 0,
      maxPlayers: json['totalCapacity'] ?? 4,
      areaSqFt: 450,
      pricePerHour: 15.0,
      availableSlots:
          (json['timeSlots'] as List<dynamic>?)
              ?.map((s) {
                final startTime = s['startTime'] as String? ?? '10:00';
                return SpaceSlot(
                  id: s['id'] ?? '',
                  startTime: startTime.length >= 5
                      ? startTime.substring(0, 5)
                      : startTime,
                );
              })
              .whereType<SpaceSlot>()
              .toList() ??
          [],
      amenities: const [
        Amenity(label: 'High-speed WiFi', iconName: 'wifi'),
        Amenity(label: 'Coffee Station', iconName: 'coffee'),
        Amenity(label: 'Mini Fridge', iconName: 'kitchen'),
        Amenity(label: 'Smart TV', iconName: 'tv'),
      ],
      libraryHighlights:
          (json['boardGames'] as List<dynamic>?)
              ?.map((g) => BoardGame.fromJson(g as Map<String, dynamic>))
              .toList() ??
          [],
      totalGames: (json['boardGames'] as List<dynamic>?)?.length ?? 0,
      openHours: '10:00 AM – 11:00 PM',
      host: const SpaceHost(
        name: 'Sarah M.',
        avatarUrl: 'https://i.pravatar.cc/150?img=47',
        isVerified: true,
      ),
      phone: json['phone'],
      email: json['email'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}
