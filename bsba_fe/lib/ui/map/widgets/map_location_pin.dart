import 'package:flutter/material.dart';

class MapLocationPin extends StatelessWidget {
  const MapLocationPin({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            elevation: 6,
            shadowColor: colorScheme.shadow.withValues(alpha: 0.25),
            color: colorScheme.primary,
            shape: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.location_on,
                color: colorScheme.onPrimary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 4),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.onSurface,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.35),
                  blurRadius: 2,
                ),
              ],
            ),
            child: const SizedBox(width: 16, height: 4),
          ),
        ],
      ),
    );
  }
}
