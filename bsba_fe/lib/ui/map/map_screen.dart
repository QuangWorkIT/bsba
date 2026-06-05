import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project/data/repositories/store_repository.dart';
import 'package:project/data/services/api_client.dart';
import 'package:project/data/services/map_service.dart';
import 'package:provider/provider.dart';

import 'map_viewmodel.dart';
import 'widgets/map_search_bar.dart';
import 'widgets/map_zoom_controls.dart';
import 'widgets/store_details_sheet.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MapViewModel(
        StoreRepository(MapService(ApiClient())),
      )..load(),
      child: const _MapBody(),
    );
  }
}

class _MapBody extends StatelessWidget {
  const _MapBody();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MapViewModel>();
    final selectedStore = viewModel.selectedStore;

    return Stack(
      fit: StackFit.expand,
      children: [
        GoogleMap(
          initialCameraPosition: MapViewModel.initialCameraPosition,
          onMapCreated: viewModel.onMapCreated,
          markers: _markersFor(viewModel),
          polylines: _polylinesFor(context, viewModel),
          myLocationEnabled: viewModel.hasUserLocation,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: false,
        ),
        Positioned(
          left: 24,
          right: 24,
          top: 24,
          child: MapSearchBar(
            query: viewModel.query,
            hasQuery: viewModel.query.isNotEmpty,
            onChanged: viewModel.onSearchChanged,
            onSubmitted: (_) => viewModel.submitSearch(),
            onClear: viewModel.clearSearch,
          ),
        ),
        Positioned(
          right: 24,
          top: 96,
          child: MapZoomControls(
            onZoomIn: viewModel.zoomIn,
            onZoomOut: viewModel.zoomOut,
            onLocate: viewModel.locateUser,
            isLocating: viewModel.isLocating,
          ),
        ),
        if (viewModel.isLoading)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0x66FFFFFF),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        if (viewModel.loadError != null)
          Positioned(
            left: 24,
            right: 24,
            top: 96,
            child: _MapMessage(
              message: viewModel.loadError!,
              actionLabel: 'Retry',
              onAction: viewModel.load,
            ),
          ),
        if (viewModel.locationError != null)
          Positioned(
            left: 24,
            right: 24,
            top: 228,
            child: _MapMessage(message: viewModel.locationError!),
          ),
        if (!viewModel.isLoading &&
            viewModel.loadError == null &&
            viewModel.stores.isEmpty)
          const Positioned(
            left: 24,
            right: 24,
            top: 96,
            child: _MapMessage(message: 'No board-game spaces found.'),
          ),
        if (selectedStore != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: StoreDetailsSheet(
              store: selectedStore,
              distance: viewModel.distanceLabelFor(selectedStore),
              onStartRoute: viewModel.showRouteToSelectedStore,
              onBookmark: () {},
            ),
          ),
      ],
    );
  }

  Set<Marker> _markersFor(MapViewModel viewModel) {
    return viewModel.stores.map((store) {
      final isSelected = store == viewModel.selectedStore;
      return Marker(
        markerId: MarkerId(store.id),
        position: LatLng(store.latitude, store.longitude),
        infoWindow: InfoWindow(title: store.name, snippet: store.address),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          isSelected ? BitmapDescriptor.hueAzure : BitmapDescriptor.hueRed,
        ),
        onTap: () => viewModel.selectStore(store),
      );
    }).toSet();
  }

  Set<Polyline> _polylinesFor(BuildContext context, MapViewModel viewModel) {
    final points = viewModel.routePoints;
    if (points.length < 2) return const {};

    return {
      Polyline(
        polylineId: const PolylineId('selected-store-route'),
        points: points,
        color: Theme.of(context).colorScheme.primary,
        width: 5,
      ),
    };
  }
}

class _MapMessage extends StatelessWidget {
  const _MapMessage({
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      elevation: 2,
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(width: 12),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
