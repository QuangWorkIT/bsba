import 'package:flutter/material.dart';
import '../shared/navigation.dart';
import 'space_card.dart';
import 'explore_space_filter.dart';
import 'explore_space_viewmodel.dart';
import 'space_detail_screen.dart';

/// Explore screen – lists nearby board game spaces.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final ExploreViewModel _vm = ExploreViewModel();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vm.loadSpaces();
  }

  @override
  void dispose() {
    _vm.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _vm,
          builder: (context, _) {
            return CustomScrollView(
              slivers: [
                // ── App bar ────────────────────────────────────────────────
                SliverAppBar(
                  pinned: true,
                  scrolledUnderElevation: 1,
                  shadowColor: Colors.black12,
                  leading: IconButton(
                    icon: const Icon(Icons.menu_rounded),
                    onPressed: () {},
                  ),
                  title: const Text('BoardNest'),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: GestureDetector(
                        onTap: () {
                          /* TODO: profile */
                        },
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          backgroundImage: const NetworkImage(
                            'https://i.pravatar.cc/150?img=12',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Search ─────────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _SearchBar(
                      controller: _searchController,
                      onChanged: _vm.onSearchChanged,
                    ),
                  ),
                ),

                // ── Filter chips ───────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: _FilterChips(
                      activeFilter: _vm.activeFilter,
                      onSelected: _vm.onFilterChanged,
                    ),
                  ),
                ),

                // ── Content ────────────────────────────────────────────────
                if (_vm.isLoading)
                  SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: colors.primary),
                    ),
                  )
                else if (_vm.error != null)
                  SliverFillRemaining(
                    child: _ErrorState(
                      message: _vm.error!,
                      onRetry: _vm.loadSpaces,
                    ),
                  )
                else if (_vm.spaces.isEmpty)
                  const SliverFillRemaining(child: _EmptyState())
                else
                  SliverPadding(
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final space = _vm.spaces[index];
                        return SpaceCard(
                          space: space,
                          onBookTap: () => _onBookTap(space.id),
                        );
                      }, childCount: _vm.spaces.length),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: Navigation(
        selectedIndex: 0, // Explore tab
        onDestinationSelected: (index) {
          // TODO: handle tab switching (router/navigator)
        },
      ),
    );
  }

  void _onBookTap(String spaceId) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SpaceDetailScreen(spaceId: spaceId)),
    );
  }
}

// ── Search bar ─────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search spaces, games, or vibes...',
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
        fillColor: colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

// ── Filter chips ───────────────────────────────────────────────────────────────

class _FilterChips extends StatelessWidget {
  final ExploreFilter activeFilter;
  final ValueChanged<ExploreFilter> onSelected;

  const _FilterChips({required this.activeFilter, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ExploreFilter.values.map((filter) {
          final selected = filter == activeFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _FilterChip(
              filter: filter,
              selected: selected,
              onTap: () => onSelected(filter),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final ExploreFilter filter;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.filter,
    required this.selected,
    required this.onTap,
  });

  IconData get _icon {
    switch (filter) {
      case ExploreFilter.allSpaces:
        return Icons.grid_view_rounded;
      case ExploreFilter.nearby:
        return Icons.near_me_rounded;
      case ExploreFilter.topRated:
        return Icons.star_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? colors.primary : colors.surface,
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _icon,
              size: 15,
              color: selected ? Colors.white : colors.secondary,
            ),
            const SizedBox(width: 5),
            Text(
              filter.label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : colors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty / error states ───────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

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
            'No spaces found',
            style: TextStyle(
              color: colors.secondary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
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

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 56,
              color: colors.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            Text(
              'Something went wrong',
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.secondary, fontSize: 13.5),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
