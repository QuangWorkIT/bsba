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

  factory BookingSummary.fromJson(Map<String, dynamic> json) {
    // Map backend status to frontend status
    final backendStatus = json['status'] as String;
    BookingStatus status;
    switch (backendStatus) {
      case 'PENDING':
      case 'CONFIRMED':
      case 'CHECKED_IN':
        status = BookingStatus.confirmed;
        break;
      case 'COMPLETED':
        status = BookingStatus.completed;
        break;
      case 'CANCELLED':
      case 'NO_SHOW':
      default:
        status = BookingStatus.cancelled;
        break;
    }

    return BookingSummary(
      title: json['storeName'] ?? 'Unknown Space',
      location: json['storeLocation'] ?? 'Unknown Location',
      date: json['date'] ?? 'N/A',
      time: json['time'] ?? 'N/A',
      players: '${json['participants'] ?? 0} Players',
      total: '\$${json['total'] ?? 0}',
      imageAsset: json['imageAsset'] ?? '',
      status: status,
    );
  }
}
