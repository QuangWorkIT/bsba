import 'package:flutter/material.dart';
import 'package:project/data/repositories/board_game_repository.dart';
import 'package:project/data/services/api_client.dart';
import 'package:project/data/services/boardgame_service.dart';
import 'package:project/ui/boardgames/staff_games_viewmodel.dart';
import 'package:project/ui/dashboard/widgets/staff_dashboard_tokens.dart';
import 'package:project/ui/dashboard/add_game_screen.dart';


class StaffGamesScreen extends StatefulWidget {
  const StaffGamesScreen({super.key});

  @override
  State<StaffGamesScreen> createState() => _StaffGamesScreenState();
}

class _StaffGamesScreenState extends State<StaffGamesScreen> {
  late final StaffGamesViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = StaffGamesViewModel(
      BoardGameRepository(BoardGameService(ApiClient())),
    );
    _vm.loadGames();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: StaffDashboardColors.background,
          floatingActionButton: FloatingActionButton(
            backgroundColor: StaffDashboardColors.primary,
            foregroundColor: Colors.white,
            tooltip: 'Add New Game',
            onPressed: () async {
              final refresh = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => const AddGameScreen()),
              );
              if (refresh == true) {
                _vm.loadGames();
              }
            },
            child: const Icon(Icons.add_rounded),
          ),
          body: SafeArea(
            top: false,
            child: Container(
              color: StaffDashboardColors.background,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: TextField(
                      onChanged: _vm.setSearchQuery,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.search,
                          color: StaffDashboardColors.muted,
                        ),
                        hintText: 'Search game library...',
                        hintStyle: const TextStyle(color: StaffDashboardColors.muted),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 16,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: StaffDashboardColors.border,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: StaffDashboardColors.border,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showCategoryDialog(context),
                            icon: const Icon(
                              Icons.sort,
                              size: 18,
                              color: StaffDashboardColors.text,
                            ),
                            label: Text(
                              _vm.selectedCategory ?? 'Category',
                              style: const TextStyle(
                                color: StaffDashboardColors.text,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFFF0F2F5),
                              side: const BorderSide(
                                color: StaffDashboardColors.border,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showSortDialog(context),
                            icon: const Icon(
                              Icons.filter_list,
                              size: 18,
                              color: StaffDashboardColors.text,
                            ),
                            label: const Text(
                              'Sort',
                              style: TextStyle(
                                color: StaffDashboardColors.text,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFFF0F2F5),
                              side: const BorderSide(
                                color: StaffDashboardColors.border,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _vm.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _vm.error != null
                            ? Center(child: Text(_vm.error!))
                            : _vm.filteredAndSortedGames.isEmpty
                                ? const Center(child: Text('No games found'))
                                : ListView.separated(
                                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                                    itemCount: _vm.filteredAndSortedGames.length,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(height: 16),
                                    itemBuilder: (context, index) {
                                      final game = _vm.filteredAndSortedGames[index];
                                      return _buildGameCard(game);
                                    },
                                  ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCategoryDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return ListenableBuilder(
          listenable: _vm,
          builder: (context, _) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Filter by Category',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListTile(
                    title: const Text('All Categories'),
                    trailing: _vm.selectedCategory == null
                        ? const Icon(Icons.check, color: StaffDashboardColors.primary)
                        : null,
                    onTap: () {
                      _vm.setCategory(null);
                      Navigator.pop(context);
                    },
                  ),
                  ..._vm.availableCategories.map((category) {
                    return ListTile(
                      title: Text(category),
                      trailing: _vm.selectedCategory == category
                          ? const Icon(Icons.check, color: StaffDashboardColors.primary)
                          : null,
                      onTap: () {
                        _vm.setCategory(category);
                        Navigator.pop(context);
                      },
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSortDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return ListenableBuilder(
          listenable: _vm,
          builder: (context, _) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Sort by',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildSortOption(context, 'Name (A-Z)', SortOption.nameAsc),
                  _buildSortOption(context, 'Name (Z-A)', SortOption.nameDesc),
                  _buildSortOption(context, 'Stock (Low to High)', SortOption.stockAsc),
                  _buildSortOption(context, 'Stock (High to Low)', SortOption.stockDesc),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSortOption(BuildContext context, String title, SortOption option) {
    return ListTile(
      title: Text(title),
      trailing: _vm.sortOption == option
          ? const Icon(Icons.check, color: StaffDashboardColors.primary)
          : null,
      onTap: () {
        _vm.setSortOption(option);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildGameCard(GameItem game) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StaffDashboardColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(11),
                ),
                child: Image.network(
                  game.imageUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              if (game.tag != null)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: game.tagColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      game.tag!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      game.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: StaffDashboardColors.text,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 20,
                          color: StaffDashboardColors.muted,
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: StaffDashboardColors.muted,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 14,
                      color: StaffDashboardColors.muted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      game.players,
                      style: const TextStyle(
                        fontSize: 12,
                        color: StaffDashboardColors.muted,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: StaffDashboardColors.muted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      game.playtime,
                      style: const TextStyle(
                        fontSize: 12,
                        color: StaffDashboardColors.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: StaffDashboardColors.border),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      game.stock > 2 ? 'IN STOCK' : 'LOW STOCK',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: game.stock > 2
                            ? StaffDashboardColors.muted
                            : const Color(0xFF8B779A),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: StaffDashboardColors.border),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => _vm.updateStock(game, -1),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              child: Icon(
                                Icons.remove,
                                size: 16,
                                color: StaffDashboardColors.primary,
                              ),
                            ),
                          ),
                          Container(
                            color: const Color(0xFFF0F2F5),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            child: Text(
                              '${game.stock}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: StaffDashboardColors.text,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => _vm.updateStock(game, 1),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              child: Icon(
                                Icons.add,
                                size: 16,
                                color: StaffDashboardColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
