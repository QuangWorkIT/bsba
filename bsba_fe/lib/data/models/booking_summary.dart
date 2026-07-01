enum BookingStatus { pending, confirmed, completed, cancelled, noShow }

class BookingSummary {
  const BookingSummary({
    required this.id,
    required this.title,
    required this.location,
    required this.date,
    required this.time,
    required this.players,
    required this.total,
    required this.imageAsset,
    required this.status,
    required this.qrCode,
    this.startsAt,
    this.endsAt,
  });

  static const _statusByBackendValue = {
    'PENDING': BookingStatus.pending,
    'CONFIRMED': BookingStatus.confirmed,
    'CHECKED_IN': BookingStatus.confirmed,
    'COMPLETED': BookingStatus.completed,
    'CANCELLED': BookingStatus.cancelled,
    'NO_SHOW': BookingStatus.noShow,
  };

  static const _statusLabels = {
    BookingStatus.pending: 'Pending',
    BookingStatus.confirmed: 'Confirmed',
    BookingStatus.completed: 'Completed',
    BookingStatus.cancelled: 'Cancelled',
    BookingStatus.noShow: 'No Show',
  };

  static const _weekdayLabels = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static const _monthLabels = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  final String id;
  final String title;
  final String location;
  final String date;
  final String time;
  final String players;
  final String total;
  final String imageAsset;
  final BookingStatus status;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final String qrCode;

  String get statusLabel => _statusLabels[status] ?? 'Unknown';

  String badgeLabel({DateTime? now}) {
    if (status == BookingStatus.pending && isWithin24HoursBeforeStart(now)) {
      return 'Up coming';
    }

    return statusLabel;
  }

  bool isWithin24HoursBeforeStart([DateTime? now]) {
    final startsAt = this.startsAt;
    if (startsAt == null) return false;

    final effectiveNow = now ?? DateTime.now();
    final untilStart = startsAt.difference(effectiveNow);
    return !untilStart.isNegative && untilStart <= const Duration(hours: 24);
  }

  factory BookingSummary.fromJson(Map<String, dynamic> json) {
    final startsAt = _parseSlotDateTime(json['slot_date'], json['start_time']);
    final endsAt = _parseSlotDateTime(json['slot_date'], json['end_time']);
    final status = _statusByBackendValue[json['status']] ?? BookingStatus.noShow;

    return BookingSummary(
      id: json['id']?.toString() ?? '',
      title: json['storeName'] ?? 'Unknown Space',
      location: json['storeLocation'] ?? 'Unknown Location',
      date: startsAt != null ? _formatDate(startsAt) : json['date'] ?? 'N/A',
      time: startsAt != null && endsAt != null
          ? '${_formatTime(startsAt)} - ${_formatTime(endsAt)}'
          : json['time'] ?? 'N/A',
      players: '${json['participants'] ?? 0} Players',
      total: '\$${json['total'] ?? 0}',
      imageAsset: json['storeImage'] ?? json['imageUrl'] ?? json['imageAsset'] ?? '',
      status: status,
      startsAt: startsAt,
      endsAt: endsAt,
      qrCode: json['qrCode']?.toString() ?? '',
    );
  }

  static DateTime? _parseSlotDateTime(dynamic date, dynamic time) {
    if (date is! String || time is! String) return null;
    return DateTime.tryParse('${date}T$time');
  }

  static String _formatDate(DateTime value) {
    final weekday = _weekdayLabels[value.weekday - 1];
    final month = _monthLabels[value.month - 1];
    return '$weekday, $month ${value.day}';
  }

  static String _formatTime(DateTime value) {
    final period = value.hour >= 12 ? 'PM' : 'AM';
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}
