import 'package:flutter/foundation.dart';
import '../../data/models/board_game.dart';
import '../../data/models/board_space_detail.dart';

class SpaceDetailViewModel extends ChangeNotifier {
  // ── State ──────────────────────────────────────────────────────────────────

  BoardSpaceDetail? _space;
  bool _isLoading = false;
  String? _error;
  String? _selectedSlot;

  // ── Getters ────────────────────────────────────────────────────────────────

  BoardSpaceDetail? get space => _space;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedSlot => _selectedSlot;

  // ── Actions ────────────────────────────────────────────────────────────────

  void selectSlot(String slot) {
    _selectedSlot = slot;
    notifyListeners();
  }

  Future<void> loadSpace(String spaceId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Replace with real repository call, e.g.:
      // _space = await _repository.getSpaceDetail(spaceId);
      await Future.delayed(const Duration(milliseconds: 500));
      _space = _mockSpace(spaceId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Seed data ──────────────────────────────────────────────────────────────

  static BoardSpaceDetail _mockSpace(String id) => BoardSpaceDetail(
    id: id,
    name: 'The Strategy Hub',
    description:
        'A premium gaming environment featuring custom-built oak tables, '
        'ergonomic seating, and professional-grade lighting. Perfect for '
        'long sessions of Twilight Imperium, Scythe, or large-scale '
        'miniature wargaming.',
    address: '124 Tabletop Way, Suite 200, Ho Chi Minh City',
    imageUrl:
        'https://images.unsplash.com/photo-1611532736597-de2d4265fba3?w=900&q=80',
    rating: 4.9,
    reviewCount: 128,
    maxPlayers: 12,
    areaSqFt: 450,
    pricePerHour: 15,
    availableSlots: [
      '10:00',
      '11:30',
      '13:00',
      '14:30',
      '16:00',
      '17:30',
      '19:00',
      '20:30',
    ],
    amenities: const [
      Amenity(label: 'High-speed WiFi', iconName: 'wifi'),
      Amenity(label: 'Coffee Station', iconName: 'coffee'),
      Amenity(label: 'Mini Fridge', iconName: 'kitchen'),
      Amenity(label: 'Smart TV', iconName: 'tv'),
    ],
    libraryHighlights: const [
      BoardGame(
        id: 'g1',
        name: 'Twilight Imperium',
        category: 'Grand Strategy',
        imageUrl:
            'https://images.unsplash.com/photo-1640461470346-c8b56497850a?w=400&q=80',
        minPlayers: 3,
        maxPlayers: 8,
        difficultyLevel: 5,
        rentalPrice: 5,
      ),
      BoardGame(
        id: 'g2',
        name: 'Scythe',
        category: 'Engine Building',
        imageUrl:
            'https://images.unsplash.com/photo-1559131397-f94da358f7ca?w=400&q=80',
        minPlayers: 1,
        maxPlayers: 5,
        difficultyLevel: 3,
        rentalPrice: 3,
      ),
      BoardGame(
        id: 'g3',
        name: 'Terraforming Mars',
        category: 'Strategy',
        imageUrl:
            'https://images.unsplash.com/photo-1446776858070-70c3d5ed6758?w=400&q=80',
        minPlayers: 1,
        maxPlayers: 5,
        difficultyLevel: 3,
        rentalPrice: 3,
      ),
    ],
    totalGames: 200,
    openHours: '10:00 AM – 11:00 PM',
    host: const SpaceHost(
      name: 'Sarah M.',
      avatarUrl: 'https://i.pravatar.cc/150?img=47',
      isVerified: true,
    ),
  );
}
