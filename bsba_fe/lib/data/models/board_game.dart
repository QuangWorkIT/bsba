class BoardGame {
  final String id;
  final String name;
  final String category;
  final String imageUrl;
  final int minPlayers;
  final int maxPlayers;
  final int? difficultyLevel;
  final double rentalPrice;
  final int? playTimeMinutes;
  final String? description;
  final String? storeName;
  final String? storeDescription;
  final int? quantity; // total stock at store
  final int? availableQuantity;
  final bool? isAvailable;
  final int? stock;

  const BoardGame({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.minPlayers,
    required this.maxPlayers,
    this.difficultyLevel,
    required this.rentalPrice,
    this.playTimeMinutes,
    this.description,
    this.storeName,
    this.storeDescription,
    this.quantity,
    this.availableQuantity,
    this.isAvailable,
    this.stock,
  });

  String get playerRange => '$minPlayers–$maxPlayers players';

  String get difficulty {
    if (difficultyLevel == null) return 'N/A';
    if (difficultyLevel! <= 2) return 'Easy';
    if (difficultyLevel! <= 4) return 'Medium';
    return 'Hard';
  }

  String get playDuration {
    if (playTimeMinutes == null) return 'N/A';
    if (playTimeMinutes! >= 120) return '120+ Min';
    return '$playTimeMinutes Min';
  }

  factory BoardGame.fromJson(Map<String, dynamic> json) {
    return BoardGame(
      id: json['id'],
      name: json['name'],
      category: json['category'] ?? 'General',
      imageUrl: json['imageUrl'] ?? '',
      minPlayers: json['minPlayers'] ?? 1,
      maxPlayers: json['maxPlayers'] ?? 1,
      difficultyLevel: json['difficultyLevel'],
      rentalPrice: (json['rentalPrice'] as num?)?.toDouble() ?? 0.0,
      playTimeMinutes: json['playTimeMinutes'],
      description: json['description'],
      storeName: json['storeName'],
      storeDescription: json['storeDescription'],
      quantity: json['quantity'] as int?,
      availableQuantity: json['availableQuantity'] as int?,
      isAvailable: json['isAvailable'] as bool?,
      stock: json['quantity'],
    );
  }

  BoardGame copyWith({
    String? id,
    String? name,
    String? category,
    String? imageUrl,
    int? minPlayers,
    int? maxPlayers,
    int? difficultyLevel,
    double? rentalPrice,
    int? playTimeMinutes,
    String? description,
    String? storeName,
    String? storeDescription,
    int? quantity,
    int? availableQuantity,
    bool? isAvailable,
    int? stock,
  }) {
    return BoardGame(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      minPlayers: minPlayers ?? this.minPlayers,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      rentalPrice: rentalPrice ?? this.rentalPrice,
      playTimeMinutes: playTimeMinutes ?? this.playTimeMinutes,
      description: description ?? this.description,
      storeName: storeName ?? this.storeName,
      storeDescription: storeDescription ?? this.storeDescription,
      quantity: quantity ?? this.quantity,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      isAvailable: isAvailable ?? this.isAvailable,
      stock: stock ?? this.stock,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is BoardGame && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
