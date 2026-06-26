import 'package:flutter/foundation.dart';
import '../../data/models/board_game.dart';
import '../../data/models/booking_summary.dart';
import '../../data/models/board_space_detail.dart';
import '../../data/models/booking.dart';
import '../../data/models/pending_booking_lookup.dart';
import '../../data/repositories/board_space_repository.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/repositories/cart_repository.dart';
import '../../data/services/current_user.dart';

class SpaceDetailViewModel extends ChangeNotifier {
  static const int defaultParticipantCount = 2;
  static const String defaultBookingNote = 'Optional note';

  final BoardSpaceRepository _spaceRepository;
  final BookingRepository _bookingRepository;
  final CartRepository _cartRepository;

  SpaceDetailViewModel(
    this._spaceRepository,
    this._bookingRepository,
    this._cartRepository,
  );

  // ── State ──────────────────────────────────────────────────────────────────

  BoardSpaceDetail? _space;
  bool _isLoading = false;
  bool _isCreatingBooking = false;
  String? _error;
  String? _bookingError;
  SpaceSlot? _selectedSlot;
  String? _pendingBookingId;
  String? _pendingCartId;
  List<PendingBookingLookup> _pendingBookings = const [];

  // ── Getters ────────────────────────────────────────────────────────────────

  BoardSpaceDetail? get space => _space;
  bool get isLoading => _isLoading;
  bool get isCreatingBooking => _isCreatingBooking;
  String? get error => _error;
  String? get bookingError => _bookingError;
  SpaceSlot? get selectedSlot => _selectedSlot;
  String? get pendingBookingId => _pendingBookingId;
  String? get pendingCartId => _pendingCartId;
  List<PendingBookingLookup> get pendingBookings => _pendingBookings;

  // ── Actions ────────────────────────────────────────────────────────────────

  void selectSlot(SpaceSlot slot) {
    _selectedSlot = slot;
    notifyListeners();
  }

  bool selectPendingBookingForSlot(SpaceSlot slot) {
    final pendingBooking = _findPendingBookingBySlotId(slot.id);
    if (pendingBooking == null) return false;

    _setCurrentPendingBooking(pendingBooking, slot);
    notifyListeners();
    return true;
  }

  Future<BookingSummary> createPendingBooking(SpaceSlot slot) async {
    final space = _space;
    if (space == null) {
      throw StateError('Space detail is not loaded.');
    }

    _isCreatingBooking = true;
    _bookingError = null;
    notifyListeners();

    try {
      final booking = await _bookingRepository.createBooking(
        Booking(
          userId: CurrentUser.instance.id,
          storeId: space.id,
          slotId: slot.id,
          participantCount: defaultParticipantCount,
          totalPrice: _bookingTotalFor(space),
          note: defaultBookingNote,
        ),
      );
      if (booking.id.isEmpty) {
        throw StateError('Created booking response did not include an id.');
      }

      await _cartRepository.createEmptyCartForBooking(booking.id);
      _selectedSlot = slot;
      _pendingBookingId = booking.id;
      await _lookupPendingBooking(space);
      return booking;
    } catch (e) {
      _bookingError = e.toString();
      rethrow;
    } finally {
      _isCreatingBooking = false;
      notifyListeners();
    }
  }

  Future<void> loadSpace(String spaceId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final space = await _spaceRepository.fetchSpaceById(spaceId);
      _space = space;
      await _lookupPendingBooking(space);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  int _bookingTotalFor(BoardSpaceDetail space) {
    return space.pricePerHour.round();
  }

  Future<String?> addGameToCart(BoardGame game, {int quantity = 1}) async {
    final cartId = _pendingCartId;
    if (cartId == null || cartId.isEmpty) {
      return 'Please select a booking time first';
    }

    await _cartRepository.addItemToCart(
      bookingCartId: cartId,
      boardGameId: game.id,
      quantity: quantity,
    );
    return null;
  }

  Future<void> _lookupPendingBooking(BoardSpaceDetail space) async {
    final pendingBookings = await _bookingRepository.lookupPendingBooking(
      userId: CurrentUser.instance.id,
      storeId: space.id,
    );

    _pendingBookings = pendingBookings;

    if (pendingBookings.isEmpty) {
      _pendingBookingId = null;
      _pendingCartId = null;
      _selectedSlot = null;
      return;
    }

    final nearestPendingBooking = pendingBookings.first;
    _setCurrentPendingBooking(
      nearestPendingBooking,
      _findSlotById(space.availableSlots, nearestPendingBooking.slotId),
    );
  }

  PendingBookingLookup? _findPendingBookingBySlotId(String slotId) {
    for (final booking in _pendingBookings) {
      if (booking.slotId == slotId) return booking;
    }

    return null;
  }

  void _setCurrentPendingBooking(
    PendingBookingLookup pendingBooking,
    SpaceSlot? slot,
  ) {
    _pendingBookingId = pendingBooking.bookingId;
    _pendingCartId = pendingBooking.cartId;
    _selectedSlot = slot;
  }

  SpaceSlot? _findSlotById(List<SpaceSlot> slots, String slotId) {
    for (final slot in slots) {
      if (slot.id == slotId) return slot;
    }

    return null;
  }
}
