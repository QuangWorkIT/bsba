import 'package:flutter/material.dart';
import '../../data/models/board_space.dart';

class SpaceCard extends StatelessWidget {
  final BoardSpace space;
  final VoidCallback? onBookTap;
  final VoidCallback? onChatTap;

  /// Game name that matched the current search, if any — surfaced as a badge so
  /// the user sees which game this store serves.
  final String? matchedGame;

  const SpaceCard({
    super.key,
    required this.space,
    this.onBookTap,
    this.onChatTap,
    this.matchedGame,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero image ──────────────────────────────────────────────────
          _SpaceImage(space: space),

          // ── Card body ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TitleRow(space: space),
                const SizedBox(height: 6),
                Text(
                  space.description,
                  style: TextStyle(
                    color: colors.secondary,
                    fontSize: 13.5,
                    height: 1.45,
                  ),
                ),
                if (space.featuredGames.isNotEmpty || matchedGame != null) ...[
                  const SizedBox(height: 14),
                  _GamesSection(
                    games: space.featuredGames,
                    matchedGame: matchedGame,
                  ),
                ],
                const SizedBox(height: 14),
                Divider(color: colors.outlineVariant, height: 1),
                const SizedBox(height: 12),
                _AvailableSlots(slots: space.availableSlots),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onBookTap,
                        child: const Text('Book Table'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _ChatButton(onTap: onChatTap),
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

// ── Sub-widgets ────────────────────────────────────────────────────────────────

class _GamesSection extends StatelessWidget {
  final List<String> games;

  /// Game matched by the current search; highlighted, and appended if it's not
  /// already among the featured games so a searched game always shows.
  final String? matchedGame;

  const _GamesSection({required this.games, this.matchedGame});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final showExtraMatch =
        matchedGame != null && !games.contains(matchedGame);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'POPULAR GAMES',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            color: colors.secondary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            for (final g in games)
              _GameTag(label: g, highlight: g == matchedGame),
            if (showExtraMatch) _GameTag(label: matchedGame!, highlight: true),
          ],
        ),
      ],
    );
  }
}

class _GameTag extends StatelessWidget {
  final String label;
  final bool highlight;

  const _GameTag({required this.label, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: highlight ? colors.primary.withValues(alpha: 0.1) : colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: highlight ? colors.primary : colors.outline,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.casino_rounded,
            size: 14,
            color: highlight ? colors.primary : colors.secondary,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
              color: highlight ? colors.primary : colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _ChatButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      height: 48,
      width: 48,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          foregroundColor: colors.primary,
          side: BorderSide(color: colors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
      ),
    );
  }
}

class _SpaceImage extends StatelessWidget {
  final BoardSpace space;
  const _SpaceImage({required this.space});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Stack(
        children: [
          Image.network(
            space.imageUrl,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              height: 200,
              color: colors.surface,
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 48,
                color: colors.onSurface.withValues(alpha: 0.4),
              ),
            ),
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return Container(
                height: 200,
                color: colors.surface,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.primary,
                  ),
                ),
              );
            },
          ),
          // Rating badge
          Positioned(
            top: 12,
            right: 12,
            child: _RatingBadge(rating: space.rating),
          ),
        ],
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final double rating;
  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, color: colors.tertiary, size: 15),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _TitleRow extends StatelessWidget {
  final BoardSpace space;
  const _TitleRow({required this.space});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            space.name,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
              letterSpacing: -0.2,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${space.distanceMi.toStringAsFixed(1)} mi',
          style: TextStyle(
            fontSize: 13,
            color: colors.secondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _AvailableSlots extends StatelessWidget {
  final List<String> slots;
  const _AvailableSlots({required this.slots});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AVAILABLE TODAY',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            color: colors.secondary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: slots.map((slot) => _SlotChip(label: slot)).toList(),
        ),
      ],
    );
  }
}

class _SlotChip extends StatelessWidget {
  final String label;
  const _SlotChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outline, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: colors.onSurface,
        ),
      ),
    );
  }
}
