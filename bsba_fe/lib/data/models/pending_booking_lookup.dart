class PendingBookingLookup {
  const PendingBookingLookup({
    required this.bookingId,
    required this.cartId,
    required this.slotId,
  });

  final String bookingId;
  final String cartId;
  final String slotId;

  factory PendingBookingLookup.fromJson(Map<String, dynamic> json) {
    return PendingBookingLookup(
      bookingId: json['bookingId']?.toString() ?? '',
      cartId: json['cartId']?.toString() ?? '',
      slotId: json['slotId']?.toString() ?? '',
    );
  }
}
