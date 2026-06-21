class Booking {
  const Booking({
    required this.userId,
    required this.storeId,
    required this.slotId,
    required this.participantCount,
    required this.totalPrice,
    this.note,
  });

  final String userId;
  final String storeId;
  final String slotId;
  final int participantCount;
  final int totalPrice;
  final String? note;

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'storeId': storeId,
      'slotId': slotId,
      'participantCount': participantCount,
      'totalPrice': totalPrice,
      if (note != null && note!.isNotEmpty) 'note': note,
    };
  }
}
