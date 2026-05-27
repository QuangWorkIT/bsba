import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../components/space_card.dart';
import 'explore_space_filter.dart';
import 'explore_space_viewmodel.dart';

/// Explore screen – lists nearby board game spaces.
///
/// Uses [ListenableBuilder] + [ExploreViewModel] (plain ChangeNotifier) so
/// no extra state-management packages are required.
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _vm,
          builder: (context, _) {
            return CustomScrollView(
              slivers: [
                // ── App bar ────────────────────────────────────────────────
                _ExploreAppBar(),

                // ── Search ─────────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                    const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
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
                    const SliverFillRemaining(
                      child: _EmptyState(),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.only(top: 8, bottom: 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            final space = _vm.spaces[index];
                            return SpaceCard(
                              space: space,
                              onBookTap: () => _onBookTap(space.id),
                            );
                          },
                          childCount: _vm.spaces.length,
                        ),
                      ),
                    ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const _BottomNav(),
    );
  }

  void _onBookTap(String spaceId) {
    // TODO: Navigate to booking screen with spaceId.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking space $spaceId…'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

// ── App bar ────────────────────────────────────────────────────────────────────

class _ExploreAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: Colors.black12,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: IconButton(
          icon: const Icon(Icons.menu_rounded,
              color: AppColors.textPrimary, size: 26),
          onPressed: () {},
          tooltip: 'Menu',
        ),
      ),
      title: const Text(
        'Tabletop Haven',
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () {
              // TODO: Navigate to profile.
            },
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryLight,
              backgroundImage: NetworkImage(
                'https://i.pravatar.cc/150?img=12',
              ),
            ),
          ),
        ),
      ],
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
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search spaces, games, or vibes...',
        prefixIcon: const Icon(Icons.search_rounded,
            color: AppColors.textHint, size: 22),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.close_rounded,
              color: AppColors.textHint, size: 20),
          onPressed: () {
            controller.clear();
            onChanged('');
          },
        )
            : null,
        filled: true,
        fillColor: AppColors.surface,
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

  const _FilterChips(
      {required this.activeFilter, required this.onSelected});

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

  const _FilterChip(
      {required this.filter,
        required this.selected,
        required this.onTap});

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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.chipSelected
              : AppColors.chipUnselected,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.chipSelected
                : AppColors.chipBorder,
            width: 1,
          ),
          boxShadow: selected
              ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.25),
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
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 5),
            Text(
              filter.label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: selected
                    ? Colors.white
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom navigation ──────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _NavItem(
                  icon: Icons.search_rounded,
                  label: 'Explore',
                  active: true),
              _NavItem(
                  icon: Icons.map_outlined, label: 'Map'),
              _NavItem(
                  icon: Icons.shopping_cart_outlined,
                  label: 'Cart'),
              _NavItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Inbox'),
              _NavItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _NavItem(
      {required this.icon, required this.label, this.active = false});

  @override
  Widget build(BuildContext context) {
    final color =
    active ? AppColors.navActive : AppColors.navInactive;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            color: color,
            fontWeight:
            active ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

// ── Empty / error states ───────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded,
              size: 56, color: AppColors.textHint),
          SizedBox(height: 12),
          Text(
            'No spaces found',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Try different keywords or filters.',
            style: TextStyle(
                color: AppColors.textHint, fontSize: 13.5),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 56, color: AppColors.textHint),
            const SizedBox(height: 12),
            const Text(
              'Something went wrong',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13.5),
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