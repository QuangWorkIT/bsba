class BoardSpace {
  final String id;
  final String name;
  final String address;
  final double distanceMi;
  final double rating;
  final String imageUrl;
  final String description;
  final List<String> availableSlots;
  final List<String> featuredGames;
  final double pricePerHour;

  const BoardSpace({
    required this.id,
    required this.name,
    required this.address,
    required this.distanceMi,
    required this.rating,
    required this.imageUrl,
    required this.description,
    required this.availableSlots,
    required this.featuredGames,
    required this.pricePerHour,
  });

  /// Maps a `SpaceCardResponse` from GET /api/v1/spaces.
  factory BoardSpace.fromJson(Map<String, dynamic> json) {
    final slots = (json['availableSlotsToday'] as List<dynamic>?) ?? const [];
    final games = (json['featuredGames'] as List<dynamic>?) ?? const [];

    return BoardSpace(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      address: '', // not provided by the spaces list endpoint
      distanceMi: (json['distanceMiles'] as num?)?.toDouble() ?? 0,
      rating: (json['ratingAvg'] as num?)?.toDouble() ?? 0,
      imageUrl: json['coverImageUrl'] as String? ?? '',
      description: json['description'] as String? ?? '',
      availableSlots: slots
          .map((s) => (s as Map<String, dynamic>)['startTime'] as String? ?? '')
          .where((s) => s.isNotEmpty)
          .toList(),
      featuredGames: games.map((g) => g as String).toList(),
      pricePerHour: 0,
    );
  }

  /// Creates a copy with optional overrides.
  BoardSpace copyWith({
    String? id,
    String? name,
    String? address,
    double? distanceMi,
    double? rating,
    String? imageUrl,
    String? description,
    List<String>? availableSlots,
    List<String>? featuredGames,
    double? pricePerHour,
  }) {
    return BoardSpace(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      distanceMi: distanceMi ?? this.distanceMi,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      availableSlots: availableSlots ?? this.availableSlots,
      featuredGames: featuredGames ?? this.featuredGames,
      pricePerHour: pricePerHour ?? this.pricePerHour,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is BoardSpace && other.id == id);

  @override
  int get hashCode => id.hashCode;
}