import 'package:flutter/foundation.dart';
import '../../data/models/booking_summary.dart';
import '../../data/models/board_space_detail.dart';
import '../../data/models/booking.dart';
import '../../data/repositories/board_space_repository.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/services/current_user.dart';

class SpaceDetailViewModel extends ChangeNotifier {
  static const int defaultParticipantCount = 2;
  static const String defaultBookingNote = 'Optional note';

  final BoardSpaceRepository _spaceRepository;
  final BookingRepository _bookingRepository;

  SpaceDetailViewModel(this._spaceRepository, this._bookingRepository);

  // ── State ──────────────────────────────────────────────────────────────────

  BoardSpaceDetail? _space;
  bool _isLoading = false;
  bool _isCreatingBooking = false;
  String? _error;
  String? _bookingError;
  SpaceSlot? _selectedSlot;

  // ── Getters ────────────────────────────────────────────────────────────────

  BoardSpaceDetail? get space => _space;
  bool get isLoading => _isLoading;
  bool get isCreatingBooking => _isCreatingBooking;
  String? get error => _error;
  String? get bookingError => _bookingError;
  SpaceSlot? get selectedSlot => _selectedSlot;

  // ── Actions ────────────────────────────────────────────────────────────────

  void selectSlot(SpaceSlot slot) {
    _selectedSlot = slot;
    notifyListeners();
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
      _selectedSlot = slot;
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
      _space = await _spaceRepository.fetchSpaceById(spaceId);
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
}
