import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/board_game.dart';
import '../../data/repositories/board_game_repository.dart';
import '../../data/services/api_client.dart';
import '../../data/services/boardgame_service.dart';
import 'game_library_viewmodel.dart';

class GameLibraryScreen extends StatelessWidget {
  final String? storeId;
  final String? slotId;
  final String? bookingCartId;
  final bool canAddToCart;

  const GameLibraryScreen({
    super.key,
    this.storeId,
    this.slotId,
    this.bookingCartId,
    this.canAddToCart = true,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final apiClient = ApiClient();
        return GameLibraryViewModel(
          BoardGameRepository(BoardGameService(apiClient)),
        )..loadGames(storeId: storeId);
      },
      child: _GameLibraryView(
        storeId: storeId,
        slotId: slotId,
        bookingCartId: bookingCartId,
        canAddToCart: canAddToCart,
      ),
    );
  }
}

class _GameLibraryView extends StatefulWidget {
  final String? storeId;
  final String? slotId;
  final String? bookingCartId;
  final bool canAddToCart;

  const _GameLibraryView({
    this.storeId,
    this.slotId,
    this.bookingCartId,
    required this.canAddToCart,
  });

  @override
  State<_GameLibraryView> createState() => _GameLibraryViewState();
}

class _GameLibraryViewState extends State<_GameLibraryView> {
  final TextEditingController _searchController = TextEditingController();

  static const _categoryColors = <String, Color>{
    'RPG': Color(0xFFE53935),
    'Strategy': Color(0xFF1275E2),
    'Family': Color(0xFF43A047),
    'Party': Color(0xFF8E24AA),
    'Trending': Color(0xFFF57C00),
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GameLibraryViewModel>();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
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
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark_outline_rounded, color: colors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: _GameSearchBar(
              controller: _searchController,
              onChanged: vm.onSearchChanged,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: _GameFilterChips(
              active: vm.activeFilter,
              onSelected: vm.onFilterChanged,
            ),
          ),
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.error != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        vm.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => vm.loadGames(storeId: widget.storeId),
                        child: const Text('Retry'),
                      ),
                    ],
                  )
                : vm.filteredGames.isEmpty
                ? _EmptyResults(
                    query: _searchController.text,
                    filter: vm.activeFilter.label,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    itemCount: vm.filteredGames.length,
                    itemBuilder: (context, index) {
                      final game = vm.filteredGames[index];
                      return _GameLibraryCard(
                        game: game,
                        badgeLabel: game.category,
                        badgeColor:
                            _categoryColors[game.category] ?? colors.primary,
                        onAddToCart: widget.canAddToCart
                            ? () => _onAddToCart(context, game)
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _onAddToCart(BuildContext context, BoardGame game) async {
    if (widget.storeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a space first to start a booking'),
        ),
      );
      return;
    }

    if (widget.slotId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a booking time first')),
      );
      return;
    }

    final vm = context.read<GameLibraryViewModel>();
    final String? error = await vm.addToCart(
      game,
      bookingCartId: widget.bookingCartId,
    );

    if (context.mounted) {
      final message = error ?? '${game.name} added to cart';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: error == null ? null : Colors.red,
        ),
      );
    }
  }
}

// Sub-widgets follow... (copied from original with minor updates)
class _GameSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _GameSearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search games, mechanics, or themes...',
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _GameFilterChips extends StatelessWidget {
  final GameLibraryFilter active;
  final ValueChanged<GameLibraryFilter> onSelected;
  const _GameFilterChips({required this.active, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: GameLibraryFilter.values.map((filter) {
          final selected = filter == active;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter.label),
              selected: selected,
              onSelected: (_) => onSelected(filter),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _GameLibraryCard extends StatelessWidget {
  final BoardGame game;
  final String badgeLabel;
  final Color badgeColor;
  final VoidCallback? onAddToCart;

  const _GameLibraryCard({
    required this.game,
    required this.badgeLabel,
    required this.badgeColor,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Image.network(
            game.imageUrl,
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const Icon(Icons.casino),
          ),
          ListTile(
            title: Text(game.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${game.category} • ${game.minPlayers}-${game.maxPlayers} players',
                ),
                if (game.storeDescription != null &&
                    game.storeDescription!.isNotEmpty)
                  Text(
                    game.storeDescription!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
            trailing: Text(
              '${game.rentalPrice} VND/hr',
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (onAddToCart != null)
            ElevatedButton(
              onPressed: onAddToCart,
              child: const Text('Add to Cart'),
            ),
        ],
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  final String query;
  final String filter;
  const _EmptyResults({required this.query, required this.filter});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('No games found'));
  }
}
