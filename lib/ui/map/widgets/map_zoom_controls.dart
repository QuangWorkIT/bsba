import 'package:flutter/material.dart';

class MapZoomControls extends StatelessWidget {
  const MapZoomControls({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MapControlButton(icon: Icons.add, onPressed: () {}),
        const SizedBox(height: 8),
        _MapControlButton(icon: Icons.remove, onPressed: () {}),
        const SizedBox(height: 8),
        _MapControlButton(
          icon: Icons.my_location,
          onPressed: () {},
          iconColor: colorScheme.primary,
        ),
      ],
    );
  }
}

class _MapControlButton extends StatelessWidget {
  const _MapControlButton({
    required this.icon,
    required this.onPressed,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      elevation: 1,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.08),
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colorScheme.outline),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            size: 22,
            color: iconColor ?? colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
