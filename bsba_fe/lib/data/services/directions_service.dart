import 'dart:async';
import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:project/core/constants/google_maps_config.dart';
import 'package:project/core/utils/polyline_decoder.dart';
import 'package:project/data/services/api_client.dart';

class DirectionsService {
  DirectionsService({
    this.apiClient,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final ApiClient? apiClient;
  final http.Client _httpClient;

  static const Duration _requestTimeout = Duration(seconds: 30);

  Future<List<LatLng>> getDrivingRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final providers = <Future<List<LatLng>> Function()>[
      if (apiClient != null)
        () => _fetchBackendRoute(origin: origin, destination: destination),
      () => _fetchOsrmRoute(origin: origin, destination: destination),
      () => _fetchGoogleRoute(origin: origin, destination: destination),
    ];

    Object? lastError;
    for (final provider in providers) {
      try {
        return await provider();
      } catch (error) {
        lastError = error;
      }
    }

    throw Exception('All routing providers failed: $lastError');
  }

  Future<List<LatLng>> _fetchBackendRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final client = apiClient;
    if (client == null) {
      throw Exception('Backend API client is not configured');
    }

    final response = await client.get(
      '/map/directions'
      '?originLat=${origin.latitude}'
      '&originLng=${origin.longitude}'
      '&destinationLat=${destination.latitude}'
      '&destinationLng=${destination.longitude}',
    );

    final data = response['data'] as List<dynamic>? ?? [];
    if (data.length < 2) {
      throw Exception('Backend returned an empty route');
    }

    return data
        .map(
          (point) => LatLng(
            (point['latitude'] as num).toDouble(),
            (point['longitude'] as num).toDouble(),
          ),
        )
        .toList(growable: false);
  }

  Future<List<LatLng>> _fetchOsrmRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final path =
        '/route/v1/driving/'
        '${origin.longitude},${origin.latitude};'
        '${destination.longitude},${destination.latitude}';

    final uri = Uri.https(
      'router.project-osrm.org',
      path,
      {'overview': 'full', 'geometries': 'polyline'},
    );

    final response = await _httpClient
        .get(uri, headers: const {'User-Agent': 'BoardNest/1.0'})
        .timeout(_requestTimeout);

    if (response.statusCode != 200) {
      throw Exception('OSRM HTTP ${response.statusCode}');
    }

    final data = _decodeJson(response.body);
    final code = data['code'] as String? ?? '';
    if (code != 'Ok') {
      throw Exception('OSRM status: $code');
    }

    final encoded = data['routes']?[0]?['geometry'] as String?;
    if (encoded == null || encoded.isEmpty) {
      throw Exception('OSRM returned an empty polyline');
    }

    final points = decodeEncodedPolyline(encoded);
    if (points.length < 2) {
      throw Exception('OSRM returned an empty route');
    }

    return points;
  }

  Future<List<LatLng>> _fetchGoogleRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/directions/json',
      {
        'origin': '${origin.latitude},${origin.longitude}',
        'destination': '${destination.latitude},${destination.longitude}',
        'mode': 'driving',
        'key': GoogleMapsConfig.apiKey,
      },
    );

    final response = await _httpClient.get(uri).timeout(_requestTimeout);
    if (response.statusCode != 200) {
      throw Exception('Directions HTTP ${response.statusCode}');
    }

    final data = _decodeJson(response.body);
    final status = data['status'] as String? ?? 'UNKNOWN';
    if (status != 'OK') {
      final message = data['error_message'] as String? ?? status;
      throw Exception('Google Directions: $message');
    }

    final encoded = data['routes']?[0]?['overview_polyline']?['points'] as String?;
    if (encoded == null || encoded.isEmpty) {
      throw Exception('Google Directions returned an empty polyline');
    }

    return decodeEncodedPolyline(encoded);
  }

  Map<String, dynamic> _decodeJson(String body) {
    return jsonDecode(body) as Map<String, dynamic>;
  }
}
