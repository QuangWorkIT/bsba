import 'package:flutter/material.dart';
import 'package:project/data/repositories/board_game_repository.dart';
import 'package:project/data/services/api_client.dart';
import 'package:project/data/services/boardgame_service.dart';

class AddGameViewModel extends ChangeNotifier {
  AddGameViewModel({BoardGameRepository? boardGameRepository})
      : _repository = boardGameRepository ?? BoardGameRepository(BoardGameService(ApiClient()));

  final BoardGameRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Selected state values
  String? _selectedAgeRange;
  int _startingStock = 1;
  String? _selectedCategory = 'Strategy';
  String? _imageUrl;

  // Data lists
  final List<String> _categories = [
    'Strategy',
    'Party',
    'Family',
    'RPG',
    'Deck Building',
    'Cooperative',
  ];

  final List<String> _ageRanges = [
    'All Ages',
    '6+',
    '10+',
    '13+',
    '16+',
    '18+',
  ];

  // Pre-configured board game cover image suggestions
  final List<Map<String, String>> _presetImages = [
    {
      'name': 'Wingspan (Bird Art)',
      'url': 'https://images.unsplash.com/photo-1610890716171-6b1bb98ffd09?w=800'
    },
    {
      'name': 'Catan (Hexes & Roads)',
      'url': 'https://images.unsplash.com/photo-1606167668584-78701c57f13d?w=800'
    },
    {
      'name': 'Carcassonne (Castles)',
      'url': 'https://images.unsplash.com/photo-1585504198199-20277593b94f?w=800'
    },
    {
      'name': 'Ticket to Ride (Trains)',
      'url': 'https://images.unsplash.com/photo-1589802829985-817e51171b92?w=800'
    },
  ];

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String? get selectedAgeRange => _selectedAgeRange;
  int get startingStock => _startingStock;
  String? get selectedCategory => _selectedCategory;
  String? get imageUrl => _imageUrl;
  List<String> get categories => _categories;
  List<String> get ageRanges => _ageRanges;
  List<Map<String, String>> get presetImages => _presetImages;

  // Mutators
  void setImageUrl(String? url) {
    _imageUrl = url;
    notifyListeners();
  }

  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void addCategory(String category) {
    if (category.isNotEmpty && !_categories.contains(category)) {
      _categories.add(category);
      _selectedCategory = category;
      notifyListeners();
    }
  }

  void setSelectedAgeRange(String? range) {
    _selectedAgeRange = range;
    notifyListeners();
  }

  void incrementStock() {
    _startingStock++;
    notifyListeners();
  }

  void decrementStock() {
    if (_startingStock > 1) {
      _startingStock--;
      notifyListeners();
    }
  }

  void setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  // Submit action
  Future<bool> submitGame({
    required String title,
    required String description,
    required String minPlayersStr,
    required String maxPlayersStr,
    required String playTimeStr,
  }) async {
    _errorMessage = null;
    _successMessage = null;
    setLoading(true);

    try {
      final minPlayers = int.tryParse(minPlayersStr) ?? 1;
      final maxPlayers = int.tryParse(maxPlayersStr) ?? 4;
      final playTime = int.tryParse(playTimeStr) ?? 60;
      
      // Parse Age requirement (e.g., "10+" -> 10, "All Ages" -> 0)
      int ageReq = 0;
      if (_selectedAgeRange != null && _selectedAgeRange != 'All Ages') {
        ageReq = int.tryParse(_selectedAgeRange!.replaceAll('+', '')) ?? 0;
      }

      await _repository.createGame(
        name: title,
        description: description,
        minPlayers: minPlayers,
        maxPlayers: maxPlayers,
        playTimeMinutes: playTime,
        ageRequirement: ageReq,
        quantity: _startingStock,
        category: _selectedCategory ?? 'Strategy',
        imageUrl: _imageUrl ?? 'https://images.unsplash.com/photo-1610890716171-6b1bb98ffd09?w=800',
      );

      _successMessage = 'Game successfully added to your library!';
      setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      setLoading(false);
      return false;
    }
  }
}
