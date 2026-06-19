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

  /// Sample data mirroring the Figma frame, so the screen renders fully before a
  /// real API is wired. Swap this out for a repository/service later.
  static List<StaffBooking> sample() => const [
        StaffBooking(
          id: 'b1',
          customerName: 'Jonathan Wick',
          timeRange: '14:00 - 16:00',
          partySize: 4,
          tableInfo: 'Table 12 (Premium Zone)',
          status: BookingStatus.confirmed,
        ),
        StaffBooking(
          id: 'b2',
          customerName: 'Sarah Connor',
          timeRange: '14:30 - 15:30',
          partySize: 2,
          tableInfo: 'Needs Table Assignment',
          status: BookingStatus.pending,
        ),
        StaffBooking(
          id: 'b3',
          customerName: 'Bruce Wayne',
          timeRange: '15:00 - 18:00',
          partySize: 8,
          tableInfo: 'The Library (Private Room)',
          status: BookingStatus.confirmed,
        ),
        StaffBooking(
          id: 'b4',
          customerName: 'Ellen Ripley',
          timeRange: '16:30 - 18:30',
          partySize: 3,
          tableInfo: 'Table 04',
          status: BookingStatus.confirmed,
        ),
        StaffBooking(
          id: 'b5',
          customerName: 'Peter Parker',
          timeRange: '17:00 - 19:00',
          partySize: 5,
          tableInfo: 'Awaiting deposit payment',
          status: BookingStatus.pending,
        ),
        StaffBooking(
          id: 'b6',
          customerName: 'Diana Prince',
          timeRange: 'Tomorrow · 10:00 - 12:00',
          partySize: 6,
          tableInfo: 'Table 08',
          status: BookingStatus.confirmed,
          when: BookingWhen.upcoming,
        ),
        StaffBooking(
          id: 'b7',
          customerName: 'Clark Kent',
          timeRange: '09:00 - 11:00',
          partySize: 2,
          tableInfo: 'Table 02',
          status: BookingStatus.completed,
        ),
        StaffBooking(
          id: 'b8',
          customerName: 'Tony Stark',
          timeRange: '12:00 - 13:00',
          partySize: 4,
          tableInfo: 'Table 10',
          status: BookingStatus.cancelled,
        ),
      ];
}
