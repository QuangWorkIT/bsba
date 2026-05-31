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
  final List<String> availableSlots;
  final List<Amenity> amenities;
  final List<BoardGame> libraryHighlights;
  final int totalGames;
  final String openHours; // e.g. "10:00 AM – 11:00 PM"
  final SpaceHost host;

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
  });
}
