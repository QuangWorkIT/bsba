import 'package:flutter/foundation.dart';
import '../../data/models/board_space_detail.dart';
import '../../data/repositories/board_space_repository.dart';

class SpaceDetailViewModel extends ChangeNotifier {
  final BoardSpaceRepository _repository;

  SpaceDetailViewModel(this._repository);

  // ── State ──────────────────────────────────────────────────────────────────

  BoardSpaceDetail? _space;
  bool _isLoading = false;
  String? _error;
  SpaceSlot? _selectedSlot;

  // ── Getters ────────────────────────────────────────────────────────────────

  BoardSpaceDetail? get space => _space;
  bool get isLoading => _isLoading;
  String? get error => _error;
  SpaceSlot? get selectedSlot => _selectedSlot;

  // ── Actions ────────────────────────────────────────────────────────────────

  void selectSlot(SpaceSlot slot) {
    _selectedSlot = slot;
    notifyListeners();
  }

  Future<void> loadSpace(String spaceId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _space = await _repository.fetchSpaceById(spaceId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
