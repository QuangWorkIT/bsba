import 'package:flutter/material.dart';
import 'widgets/map_canvas.dart';
import 'widgets/map_location_pin.dart';
import 'widgets/map_search_bar.dart';
import 'widgets/map_zoom_controls.dart';
import 'widgets/store_details_sheet.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MapBody();
  }
}

class _MapBody extends StatelessWidget {
  const _MapBody();

  static const _storeName = 'Downtown Hub';
  static const _distance = '1.2 mi away';
  static const _hours = 'Open until 9:00 PM';
  static const _rating = '4.8';
  static const _description =
      'Our flagship store featuring the largest selection of '
      'board games, miniatures, and a dedicated play area.';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      fit: StackFit.expand,
      children: [
        MapCanvas(colorScheme: colorScheme),
        const MapLocationPin(),
        const Positioned(
          left: 24,
          right: 24,
          top: 24,
          child: MapSearchBar(query: _storeName),
        ),
        const Positioned(right: 24, top: 96, child: MapZoomControls()),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: StoreDetailsSheet(
            storeName: _storeName,
            distance: _distance,
            hours: _hours,
            rating: _rating,
            description: _description,
          ),
        ),
      ],
    );
  }
}
