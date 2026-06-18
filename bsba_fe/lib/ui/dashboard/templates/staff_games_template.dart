import 'package:flutter/material.dart';
import 'package:project/data/models/board_game.dart';
import 'package:project/data/services/api_client.dart';
import 'package:project/data/services/boardgame_service.dart';
import 'package:project/data/repositories/board_game_repository.dart';
import '../add_game_screen.dart';

class StaffGamesTemplate extends StatefulWidget {
  const StaffGamesTemplate({super.key});

  @override
  State<StaffGamesTemplate> createState() => _StaffGamesTemplateState();
}

class _StaffGamesTemplateState extends State<StaffGamesTemplate> {
  final _repository = BoardGameRepository(BoardGameService(ApiClient()));
  List<BoardGame>? _games;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final games = await _repository.fetchAllGames();
      setState(() {
        _games = games;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load games: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF005AB4);
    const textGray = Color(0xFF414753);

    return Scaffold(
      backgroundColor: const Color(0xF9F9FFFF),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        tooltip: 'Add New Game',
        onPressed: () async {
          final refresh = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AddGameScreen()),
          );
          if (refresh == true) {
            _loadGames();
          }
        },
        child: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: primaryBlue,
          onRefresh: _loadGames,
          child: _isLoading && (_games == null || _games!.isEmpty)
              ? const Center(child: CircularProgressIndicator(color: primaryBlue))
              : _errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: textGray, fontSize: 14),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
                              onPressed: _loadGames,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _games == null || _games!.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 100),
                            Center(
                              child: Text(
                                'No games in your library yet.\nTap the + button to add one!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: textGray, fontSize: 16, height: 1.4),
                              ),
                            ),
                          ],
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 80),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 16,
                            mainAxisExtent: 210,
                          ),
                          itemCount: _games!.length,
                          itemBuilder: (context, index) {
                            final game = _games![index];
                            return _GameItemTile(game: game);
                          },
                        ),
        ),
      ),
    );
  }
}

class _GameItemTile extends StatelessWidget {
  final BoardGame game;

  const _GameItemTile({required this.game});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF005AB4);
    const borderGray = Color(0xFFC1C6D5);
    const textGray = Color(0xFF414753);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderGray.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Game image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Image.network(
                game.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFECEEF4),
                  child: const Icon(
                    Icons.videogame_asset_outlined,
                    color: primaryBlue,
                    size: 32,
                  ),
                ),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: const Color(0xFFECEEF4),
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: primaryBlue,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Info padding
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textGray,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        game.category,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.people_alt_outlined, size: 12, color: primaryBlue),
                          const SizedBox(width: 4),
                          Text(
                            '${game.minPlayers}-${game.maxPlayers}',
                            style: const TextStyle(fontSize: 11, color: textGray),
                          ),
                        ],
                      ),
                      if (game.playTimeMinutes != null)
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 12, color: primaryBlue),
                            const SizedBox(width: 4),
                            Text(
                              '${game.playTimeMinutes}m',
                              style: const TextStyle(fontSize: 11, color: textGray),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
