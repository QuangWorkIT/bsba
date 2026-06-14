import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Google Maps platform API key (also configured in AndroidManifest / AppDelegate).
class GoogleMapsConfig {
  GoogleMapsConfig._();

  static String get apiKey =>
      dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
}
