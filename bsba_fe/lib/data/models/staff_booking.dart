/// Lifecycle of a single booking, as shown on the staff "Manage Bookings" screen.
enum BookingStatus { pending, confirmed, completed, cancelled }

/// When a booking falls relative to now — drives the Today/Upcoming chips.
enum BookingWhen { today, upcoming }

/// A booking row in the staff management list. This is a presentation model;
/// once a staff bookings API exists, map its response into this shape.
class StaffBooking {
  final String id;
  final String customerName;
  final String timeRange; // e.g. "14:00 - 16:00"
  final int partySize;
  final String tableInfo; // e.g. "Table 12 (Premium Zone)" or "Needs Table Assignment"
  final BookingStatus status;
  final BookingWhen when;

  const StaffBooking({
    required this.id,
    required this.customerName,
    required this.timeRange,
    required this.partySize,
    required this.tableInfo,
    required this.status,
    this.when = BookingWhen.today,
  });

  /// Maps a backend `BookingResponse` into the UI model: builds the "14:00 -
  /// 16:00" range from the slot times, falls back to the store name for the
  /// "table" line, and derives today/upcoming from the slot date.
  factory StaffBooking.fromJson(Map<String, dynamic> json) {
    final start = _hhmm(json['startTime'] as String?);
    final end = _hhmm(json['endTime'] as String?);
    final timeRange =
        (start.isEmpty && end.isEmpty) ? 'No time set' : '$start - $end';

    final note = (json['note'] as String?)?.trim();
    final storeName = (json['storeName'] as String?)?.trim();
    final tableInfo = (note != null && note.isNotEmpty)
        ? note
        : (storeName != null && storeName.isNotEmpty ? storeName : '—');

    final slotDate = DateTime.tryParse((json['slotDate'] as String?) ?? '');

    return StaffBooking(
      id: json['id'].toString(),
      customerName: (json['customerName'] as String?)?.trim().isNotEmpty == true
          ? (json['customerName'] as String).trim()
          : 'Guest',
      timeRange: timeRange,
      partySize: (json['participantCount'] as num?)?.toInt() ?? 0,
      tableInfo: tableInfo,
      status: _parseStatus(json['status'] as String?),
      when: _deriveWhen(slotDate),
    );
  }

  /// "14:00:00" → "14:00"; tolerates nulls and short strings.
  static String _hhmm(String? time) {
    if (time == null || time.isEmpty) return '';
    final parts = time.split(':');
    if (parts.length < 2) return time;
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  /// Backend has 6 statuses; collapse them into the 4 the UI shows.
  static BookingStatus _parseStatus(String? raw) {
    switch ((raw ?? '').toUpperCase()) {
      case 'PENDING':
        return BookingStatus.pending;
      case 'CONFIRMED':
      case 'CHECKED_IN':
        return BookingStatus.confirmed;
      case 'COMPLETED':
        return BookingStatus.completed;
      case 'CANCELLED':
      case 'NO_SHOW':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }

  static BookingWhen _deriveWhen(DateTime? slotDate) {
    if (slotDate == null) return BookingWhen.today;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(slotDate.year, slotDate.month, slotDate.day);
    return day.isAfter(today) ? BookingWhen.upcoming : BookingWhen.today;
  }
}
