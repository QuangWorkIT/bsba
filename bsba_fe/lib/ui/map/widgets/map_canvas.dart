import 'package:flutter/material.dart';

class MapCanvas extends StatelessWidget {
  const MapCanvas({super.key, required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        image: const DecorationImage(
          image: AssetImage('assets/images/map/map_background.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
