enum BookingStatus { confirmed, completed, cancelled }

class BookingSummary {
  const BookingSummary({
    required this.title,
    required this.location,
    required this.date,
    required this.time,
    required this.players,
    required this.total,
    required this.imageAsset,
    required this.status,
  });

  final String title;
  final String location;
  final String date;
  final String time;
  final String players;
  final String total;
  final String imageAsset;
  final BookingStatus status;
}
