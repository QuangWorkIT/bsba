import 'package:flutter/material.dart';
import '../../data/models/board_game.dart';
import '../../data/models/board_space_detail.dart';
import '../../data/repositories/board_space_repository.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/repositories/cart_repository.dart';
import '../../data/services/api_client.dart';
import '../../data/services/booking_service.dart';
import '../../data/services/cart_service.dart';
import '../cart/cart_screen.dart';
import 'game_card.dart';
import 'game_library_screen.dart';
import 'space_detail_viewmodel.dart';

/// Space detail screen.
///
/// Accepts [spaceId] from the router/navigator and loads full detail via
/// [SpaceDetailViewModel].
class SpaceDetailScreen extends StatefulWidget {
  final String spaceId;

  const SpaceDetailScreen({super.key, required this.spaceId});

  @override
  State<SpaceDetailScreen> createState() => _SpaceDetailScreenState();
}

class _SpaceDetailScreenState extends State<SpaceDetailScreen> {
  late final SpaceDetailViewModel _vm;

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient();
    _vm = SpaceDetailViewModel(
      BoardSpaceRepository(apiClient),
      BookingRepository(BookingService(apiClient)),
      CartRepository(CartService(apiClient)),
    );
    _vm.loadSpace(widget.spaceId);
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        if (_vm.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (_vm.error != null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off_rounded, size: 48),
                  const SizedBox(height: 12),
                  Text(_vm.error!),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => _vm.loadSpace(widget.spaceId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (_vm.space == null) {
          return const Scaffold(body: Center(child: Text('Space not found.')));
        }

        final space = _vm.space!;

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: CustomScrollView(
            slivers: [
              // ── App bar with hero image ────────────────────────────────
              _DetailSliverAppBar(space: space),

              // ── Body sections ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info block
                    _SpaceInfoSection(space: space),
                    _Divider(),

                    // Amenities
                    _AmenitiesSection(amenities: space.amenities),
                    _Divider(),

                    // Library highlights
                    _LibrarySection(
                      games: space.libraryHighlights,
                      totalGames: space.totalGames,
                      canAddToCart: _vm.pendingBookingId != null,
                      onAddToCart: (game) => _addGameToCart(context, game),
                      onSeeAll: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => GameLibraryScreen(
                              storeId: space.id,
                              slotId: _vm.selectedSlot?.id,
                              bookingCartId: _vm.pendingCartId,
                              canAddToCart: _vm.pendingBookingId != null,
                            ),
                          ),
                        );
                      },
                    ),

                    // Pricing + booking CTA
                    _BookingBar(
                      pricePerHour: space.pricePerHour,
                      onSelect: () => _showSlotPicker(context, space),
                    ),

                    // Location & hours (now includes host & contact)
                    _LocationSection(space: space),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addGameToCart(BuildContext context, BoardGame game) async {
    try {
      final error = await _vm.addGameToCart(game);
      if (!context.mounted) return;

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${game.name} added to cart'),
          action: SnackBarAction(
            label: 'View Cart',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CartScreen(bookingId: _vm.pendingBookingId),
                ),
              );
            },
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add to cart: $e')));
    }
  }

  void _showSlotPicker(BuildContext context, BoardSpaceDetail space) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _SlotPickerSheet(
        slots: space.availableSlots,
        selectedSlot: _vm.selectedSlot,
        onSlotSelected: (slot) => _selectOrCreateBookingForSlot(context, slot),
      ),
    );
  }

  Future<void> _selectOrCreateBookingForSlot(
    BuildContext context,
    SpaceSlot slot,
  ) async {
    Navigator.pop(context);

    if (_vm.selectPendingBookingForSlot(slot)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selected pending booking for ${slot.startTime}.'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      return;
    }

    await _createBookingForSlot(context, slot);
  }

  Future<void> _createBookingForSlot(
    BuildContext context,
    SpaceSlot slot,
  ) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final booking = await _vm.createPendingBooking(slot);
      if (!context.mounted) return;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${booking.title} booking is pending for ${booking.time}.',
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create booking: $e')),
      );
    }
  }
}

// ── Sliver App Bar ─────────────────────────────────────────────────────────────

class _DetailSliverAppBar extends StatelessWidget {
  final BoardSpaceDetail space;
  const _DetailSliverAppBar({required this.space});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: cs.surface,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: _CircleIconButton(
          icon: Icons.arrow_back_rounded,
          onTap: () => Navigator.maybePop(context),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: _CircleIconButton(
            icon: Icons.ios_share_rounded,
            onTap: () {
              // TODO: share
            },
          ),
        ),
      ],
      title: Text(
        space.name,
        style: TextStyle(
          color: cs.primary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Hero image
            Image.network(
              space.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: cs.primaryContainer,
                child: Icon(Icons.image_outlined, size: 64, color: cs.primary),
              ),
            ),
            // Gradient overlay so app bar icons remain readable
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black26, Colors.transparent],
                  stops: [0.0, 0.5],
                ),
              ),
            ),
            // Rating badge bottom-right
            Positioned(
              bottom: 14,
              right: 14,
              child: _RatingBadge(
                rating: space.rating,
                reviewCount: space.reviewCount,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: Colors.black87),
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final double rating;
  final int reviewCount;
  const _RatingBadge({required this.rating, required this.reviewCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_border_rounded,
            color: Color(0xFFF59E0B),
            size: 17,
          ),
          const SizedBox(width: 4),
          Text(
            '${rating.toStringAsFixed(1)} ($reviewCount reviews)',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Space Info ─────────────────────────────────────────────────────────────────

class _SpaceInfoSection extends StatelessWidget {
  final BoardSpaceDetail space;
  const _SpaceInfoSection({required this.space});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name
          Text(
            space.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 10),

          // Meta row: players · area · price
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              _MetaChip(
                icon: Icons.group_outlined,
                label: 'Up to ${space.maxPlayers} players',
              ),
              _MetaChip(
                icon: Icons.straighten_rounded,
                label: '${space.areaSqFt} sq ft',
              ),
              _MetaChip(
                icon: Icons.payments_outlined,
                label: '${space.pricePerHour.toStringAsFixed(0)} VND / hour',
                color: cs.primary,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Description
          Text(
            space.description,
            style: TextStyle(
              fontSize: 14,
              height: 1.55,
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _MetaChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final effective = color ?? Theme.of(context).colorScheme.onSurface;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: effective),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: effective,
          ),
        ),
      ],
    );
  }
}

// ── Amenities ──────────────────────────────────────────────────────────────────

class _AmenitiesSection extends StatelessWidget {
  final List<Amenity> amenities;
  const _AmenitiesSection({required this.amenities});

  static IconData _iconFor(String name) {
    switch (name) {
      case 'wifi':
        return Icons.wifi_rounded;
      case 'coffee':
        return Icons.coffee_rounded;
      case 'kitchen':
        return Icons.kitchen_rounded;
      case 'tv':
        return Icons.tv_rounded;
      default:
        return Icons.check_circle_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Amenities'),
          const SizedBox(height: 14),
          Wrap(
            spacing: 20,
            runSpacing: 12,
            children: amenities
                .map(
                  (a) =>
                      _AmenityItem(icon: _iconFor(a.iconName), label: a.label),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _AmenityItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _AmenityItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: cs.onSurface.withValues(alpha: 0.6)),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            color: cs.onSurface.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }
}

// ── Library Highlights ─────────────────────────────────────────────────────────

class _LibrarySection extends StatelessWidget {
  final List<BoardGame> games;
  final int totalGames;
  final bool canAddToCart;
  final ValueChanged<BoardGame> onAddToCart;
  final VoidCallback onSeeAll;

  const _LibrarySection({
    required this.games,
    required this.totalGames,
    required this.canAddToCart,
    required this.onAddToCart,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _SectionTitle('Library Highlights'),
                GestureDetector(
                  onTap: onSeeAll,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    child: Text(
                      'See all $totalGames+',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 230,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: games.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) => GameCard(
                game: games[index],
                showAvailability: true,
                onAddToCart: canAddToCart
                    ? () => onAddToCart(games[index])
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ── Booking bar ────────────────────────────────────────────────────────────────

class _BookingBar extends StatelessWidget {
  final double pricePerHour;
  final VoidCallback onSelect;
  const _BookingBar({required this.pricePerHour, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Price
          Flexible(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${pricePerHour.toStringAsFixed(0)} VND',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                  TextSpan(
                    text: ' / hour',
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // CTA button
          Flexible(
            child: FilledButton(
              onPressed: onSelect,
              style: FilledButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Select Time',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Slot Picker Bottom Sheet ───────────────────────────────────────────────────

class _SlotPickerSheet extends StatelessWidget {
  final List<SpaceSlot> slots;
  final SpaceSlot? selectedSlot;
  final ValueChanged<SpaceSlot> onSlotSelected;

  const _SlotPickerSheet({
    required this.slots,
    required this.selectedSlot,
    required this.onSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Available Time Slots',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Today · Select a time to continue',
            style: TextStyle(
              fontSize: 13,
              color: cs.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: slots.map((slot) {
              final selected = slot.id == selectedSlot?.id;
              return GestureDetector(
                onTap: () => onSlotSelected(slot),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? cs.primary : cs.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? cs.primary : cs.outline,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    slot.startTime,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : cs.onSurface,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Location & Hours ───────────────────────────────────────────────────────────

class _LocationSection extends StatelessWidget {
  final BoardSpaceDetail space;
  const _LocationSection({required this.space});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Location & Hours'),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 180,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Map placeholder
                  Expanded(
                    flex: 5,
                    child: Container(
                      color: cs.primaryContainer,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.map_rounded,
                            size: 72,
                            color: cs.primary.withValues(alpha: 0.25),
                          ),
                          Icon(
                            Icons.location_on_rounded,
                            size: 36,
                            color: cs.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Info panel
                  Expanded(
                    flex: 6,
                    child: Container(
                      color: cs.surface,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Address
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 18,
                                color: cs.primary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      space.name,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      space.address,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: cs.onSurface.withValues(
                                          alpha: 0.6,
                                        ),
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    GestureDetector(
                                      onTap: () {
                                        // TODO: open maps
                                      },
                                      child: Text(
                                        'Get Directions',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: cs.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Hours
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 18,
                                color: cs.primary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          'Today',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const Spacer(),
                                        Flexible(
                                          child: Text(
                                            space.openHours,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: cs.onSurface.withValues(
                                                alpha: 0.6,
                                              ),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    GestureDetector(
                                      onTap: () {
                                        // TODO: show all hours
                                      },
                                      child: Text(
                                        'See all hours',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: cs.primary,
                                          fontWeight: FontWeight.w600,
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
                  ),
                ],
              ),
            ), // SizedBox
          ),

          // Contact info
          if (space.phone != null || space.email != null) ...[
            const SizedBox(height: 16),
            if (space.phone != null)
              Row(
                children: [
                  Icon(Icons.phone_outlined, size: 16, color: cs.primary),
                  const SizedBox(width: 8),
                  Text(
                    space.phone!,
                    style: TextStyle(
                      fontSize: 13,
                      color: cs.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            if (space.phone != null && space.email != null)
              const SizedBox(height: 6),
            if (space.email != null)
              Row(
                children: [
                  Icon(Icons.email_outlined, size: 16, color: cs.primary),
                  const SizedBox(width: 8),
                  Text(
                    space.email!,
                    style: TextStyle(
                      fontSize: 13,
                      color: cs.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
          ],
          const SizedBox(height: 16),

          // Host section
          _HostSection(host: space.host),
        ],
      ),
    );
  }
}

// ── Host section ───────────────────────────────────────────────────────────────

class _HostSection extends StatelessWidget {
  final SpaceHost host;
  const _HostSection({required this.host});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 28,
            backgroundColor: cs.primaryContainer,
            backgroundImage: NetworkImage(host.avatarUrl),
          ),
          const SizedBox(width: 14),

          // Name + verified
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hosted by',
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  host.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (host.isVerified) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        Icons.verified_outlined,
                        size: 14,
                        color: cs.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Verified Host',
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Contact button
          OutlinedButton(
            onPressed: () {
              // TODO: Open chat with host
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: cs.outline),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text(
              'Contact',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared helpers ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Theme.of(
        context,
      ).colorScheme.outlineVariant.withValues(alpha: 0.5),
      indent: 16,
      endIndent: 16,
    );
  }
}
