class BoardGame {
  final String id;
  final String title;
  final String category;
  final String imageUrl;
  final int minPlayers;
  final int maxPlayers;
  final String difficulty; // e.g. "Medium", "Hard"
  final double rentalPrice; // per hour / per session
  final String? playDuration; // e.g. "120+ Min", "60–90 Min"
  final String? description;

  const BoardGame({
    required this.id,
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.minPlayers,
    required this.maxPlayers,
    required this.difficulty,
    required this.rentalPrice,
    this.playDuration,
    this.description,
  });

  String get playerRange => '$minPlayers–$maxPlayers players';

  BoardGame copyWith({
    String? id,
    String? title,
    String? category,
    String? imageUrl,
    int? minPlayers,
    int? maxPlayers,
    String? difficulty,
    double? rentalPrice,
    String? playDuration,
    String? description,
  }) {
    return BoardGame(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      minPlayers: minPlayers ?? this.minPlayers,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      difficulty: difficulty ?? this.difficulty,
      rentalPrice: rentalPrice ?? this.rentalPrice,
      playDuration: playDuration ?? this.playDuration,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is BoardGame && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
