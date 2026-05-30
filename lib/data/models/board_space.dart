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