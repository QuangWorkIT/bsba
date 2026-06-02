import 'package:flutter/material.dart';
import 'package:project/data/models/board_game.dart';

/// Game Library screen – browse and rent board games.
///
/// Navigated to from the Explore flow. Shows a searchable, filterable
/// catalogue of board games with pricing and an "Add to Cart" action.
class GameLibraryScreen extends StatefulWidget {
  const GameLibraryScreen({super.key});

  @override
  State<GameLibraryScreen> createState() => _GameLibraryScreenState();
}

class _GameLibraryScreenState extends State<GameLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _activeFilter = 'All Games';

  // ── Mock catalogue ──────────────────────────────────────────────────────
  static const _allGames = [
    BoardGame(
      id: '1',
      title: 'Gloomhaven',
      category: 'RPG',
      imageUrl:
          'https://cf.geekdo-images.com/sZYp_3BTDGjh2unaZfZmuA__opengraph/img/Qev04kJL6lsNMet2VIH4YOAnj5k=/0x0:1571x825/fit-in/1200x630/filters:strip_icc()/pic2437871.jpg',
      minPlayers: 1,
      maxPlayers: 4,
      difficulty: 'Hard',
      rentalPrice: 5.00,
      playDuration: '120+ Min',
    ),
    BoardGame(
      id: '2',
      title: 'Terraforming Mars',
      category: 'Strategy',
      imageUrl:
          'https://cf.geekdo-images.com/wg9oOLcsKvDesSUdZQ4rxw__opengraph/img/BTsLyIX_p9rN3VpZ87VfXJnijXY=/0x0:3352x1760/fit-in/1200x630/filters:strip_icc()/pic3536616.jpg',
      minPlayers: 1,
      maxPlayers: 5,
      difficulty: 'Medium',
      rentalPrice: 4.50,
      playDuration: '90–120 Min',
    ),
    BoardGame(
      id: '3',
      title: 'Catan',
      category: 'Family',
      imageUrl:
          'https://cf.geekdo-images.com/W3Bsga_uLP9kO91gZ7H8yw__opengraph/img/o4p6f88SGE899BTNMzTvERVWZ-M=/0x0:2000x1050/fit-in/1200x630/filters:strip_icc()/pic2419375.jpg',
      minPlayers: 3,
      maxPlayers: 4,
      difficulty: 'Easy',
      rentalPrice: 3.50,
      playDuration: '60–90 Min',
    ),
    BoardGame(
      id: '4',
      title: 'Wingspan',
      category: 'Strategy',
      imageUrl:
          'https://cf.geekdo-images.com/yLZJCVLlIx4c7eJEWUNJ7w__opengraph/img/yC5_M9ORES3CaEiN1gIkMiOBnUc=/0x0:2000x1050/fit-in/1200x630/filters:strip_icc()/pic4458123.jpg',
      minPlayers: 1,
      maxPlayers: 5,
      difficulty: 'Medium',
      rentalPrice: 4.00,
      playDuration: '40–70 Min',
      description:
          'Build your wildlife preserve and attract the most beautiful birds to your habitat.',
    ),
    BoardGame(
      id: '5',
      title: 'Ticket to Ride',
      category: 'Family',
      imageUrl:
          'https://cf.geekdo-images.com/ZWJg0dCdrWHKEEQ5aKYMDA__opengraph/img/EnTYBVg-0-kTqBzPXQlPXc-jrPE=/0x0:2599x1365/fit-in/1200x630/filters:strip_icc()/pic38668.jpg',
      minPlayers: 2,
      maxPlayers: 5,
      difficulty: 'Easy',
      rentalPrice: 3.00,
      playDuration: '30–60 Min',
    ),
    BoardGame(
      id: '6',
      title: 'Pandemic',
      category: 'Strategy',
      imageUrl:
          'https://cf.geekdo-images.com/S3ybV1LAp-8SnHIXSXDTcQ__opengraph/img/nwKD4SKYJ10t-MWnNl1kMqLkjY8=/0x0:1479x777/fit-in/1200x630/filters:strip_icc()/pic1534148.jpg',
      minPlayers: 2,
      maxPlayers: 4,
      difficulty: 'Medium',
      rentalPrice: 3.50,
      playDuration: '45–60 Min',
    ),
    BoardGame(
      id: '7',
      title: 'Dungeons & Dragons',
      category: 'RPG',
      imageUrl:
          'https://cf.geekdo-images.com/vAFRVW4eCWfrf04Mxw2PZA__opengraph/img/pMRdfKQ9_Y3M1-6PVkD_K1AZ5pU=/0x0:1586x833/fit-in/1200x630/filters:strip_icc()/pic7766987.jpg',
      minPlayers: 2,
      maxPlayers: 6,
      difficulty: 'Hard',
      rentalPrice: 6.00,
      playDuration: '120+ Min',
    ),
    BoardGame(
      id: '8',
      title: 'Codenames',
      category: 'Party',
      imageUrl:
          'https://cf.geekdo-images.com/F_KDEu0GjdClml8N7c8Imw__opengraph/img/r9cMzBWWmViAaJvr2m9RGOLIYR0=/0x0:1463x768/fit-in/1200x630/filters:strip_icc()/pic2582929.jpg',
      minPlayers: 2,
      maxPlayers: 8,
      difficulty: 'Easy',
      rentalPrice: 2.50,
      playDuration: '15–30 Min',
    ),
  ];

  static const _filters = ['All Games', 'Strategy', 'Party', 'Family', 'RPG'];

  // Badge-specific colors that look good overlaying images.
  static const _categoryColors = <String, Color>{
    'RPG': Color(0xFFE53935),
    'Strategy': Color(0xFF1275E2),
    'Family': Color(0xFF43A047),
    'Party': Color(0xFF8E24AA),
    'Trending': Color(0xFFF57C00),
  };

  List<BoardGame> get _filteredGames {
    var games = _allGames.toList();

    if (_activeFilter != 'All Games') {
      games = games.where((g) => g.category == _activeFilter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      games = games.where((g) {
        return g.title.toLowerCase().contains(q) ||
            g.category.toLowerCase().contains(q) ||
            (g.description?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    return games;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final games = _filteredGames;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // ── App bar ──────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.primary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Game Library',
          style: TextStyle(
            color: colors.primary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark_outline_rounded, color: colors.primary),
            onPressed: () {
              /* TODO: saved games */
            },
          ),
        ],
      ),

      // ── Body ─────────────────────────────────────────────────────────────
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: _GameSearchBar(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // Filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: _GameFilterChips(
              filters: _filters,
              active: _activeFilter,
              onSelected: (f) => setState(() => _activeFilter = f),
            ),
          ),

          // Game list
          Expanded(
            child: games.isEmpty
                ? _EmptyResults(query: _searchQuery, filter: _activeFilter)
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    itemCount: games.length,
                    itemBuilder: (context, index) {
                      final game = games[index];
                      // Mark the 4th game as "Trending" badge for demo,
                      // matching the screenshot's Wingspan card.
                      final badgeLabel =
                          (index == 3 && _activeFilter == 'All Games')
                          ? 'Trending'
                          : game.category;
                      return _GameLibraryCard(
                        game: game,
                        badgeLabel: badgeLabel,
                        badgeColor:
                            _categoryColors[badgeLabel] ?? colors.primary,
                        onAddToCart: () => _onAddToCart(context, game),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _onAddToCart(BuildContext context, BoardGame game) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${game.title} added to cart'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  Search bar
// ═══════════════════════════════════════════════════════════════════════════════

class _GameSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _GameSearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Search games, mechanics, or themes...',
        hintStyle: TextStyle(
          color: colors.onSurface.withValues(alpha: 0.4),
          fontSize: 14,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: colors.onSurface.withValues(alpha: 0.4),
          size: 22,
        ),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: colors.onSurface.withValues(alpha: 0.4),
                  size: 20,
                ),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.outline.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.outline.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  Filter chips
// ═══════════════════════════════════════════════════════════════════════════════

class _GameFilterChips extends StatelessWidget {
  final List<String> filters;
  final String active;
  final ValueChanged<String> onSelected;

  const _GameFilterChips({
    required this.filters,
    required this.active,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((label) {
          final selected = label == active;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _Chip(
              label: label,
              selected: selected,
              onTap: () => onSelected(label),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? colors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? colors.primary : colors.outline,
            width: 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : colors.onSurface,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  Game library card — full-width card matching the screenshot
// ═══════════════════════════════════════════════════════════════════════════════

class _GameLibraryCard extends StatelessWidget {
  final BoardGame game;
  final String badgeLabel;
  final Color badgeColor;
  final VoidCallback onAddToCart;

  const _GameLibraryCard({
    required this.game,
    required this.badgeLabel,
    required this.badgeColor,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasDescription =
        game.description != null && game.description!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image with category badge ────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Image.network(
                    game.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: colors.primaryContainer,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.primary,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, _, _) => Container(
                      color: colors.primaryContainer,
                      child: Center(
                        child: Icon(
                          Icons.casino_outlined,
                          size: 48,
                          color: colors.primary.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ),
                // Category badge
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // ── Title & Price row ────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  game.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '\$${game.rentalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: colors.primary,
                      ),
                    ),
                    TextSpan(
                      text: '/hr',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: colors.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Description (if present, like Wingspan) ─────────────────────
          if (hasDescription) ...[
            const SizedBox(height: 4),
            Text(
              game.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: colors.onSurface.withValues(alpha: 0.6),
                height: 1.35,
              ),
            ),
          ],

          const SizedBox(height: 6),

          // ── Players & Duration ──────────────────────────────────────────
          Row(
            children: [
              Icon(
                Icons.people_alt_outlined,
                size: 15,
                color: colors.onSurface.withValues(alpha: 0.55),
              ),
              const SizedBox(width: 4),
              Text(
                '${game.minPlayers}–${game.maxPlayers} Players',
                style: TextStyle(
                  fontSize: 12.5,
                  color: colors.onSurface.withValues(alpha: 0.55),
                ),
              ),
              if (game.playDuration != null) ...[
                const SizedBox(width: 12),
                Icon(
                  Icons.access_time_rounded,
                  size: 15,
                  color: colors.onSurface.withValues(alpha: 0.55),
                ),
                const SizedBox(width: 4),
                Text(
                  game.playDuration!,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: colors.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),

          // ── Add to Cart button ──────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAddToCart,
              icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
              label: const Text(
                'Add to Cart',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  Empty results
// ═══════════════════════════════════════════════════════════════════════════════

class _EmptyResults extends StatelessWidget {
  final String query;
  final String filter;

  const _EmptyResults({required this.query, required this.filter});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 56,
            color: colors.primary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            'No games found',
            style: TextStyle(
              color: colors.secondary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try different keywords or filters.',
            style: TextStyle(
              color: colors.onSurface.withValues(alpha: 0.4),
              fontSize: 13.5,
            ),
          ),
        ],
      ),
    );
  }
}
