class EnvConfig {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const String osmTileUrl = String.fromEnvironment('OSM_TILE_URL', defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png');
  static final double mapDefaultLat = double.tryParse(const String.fromEnvironment('MAP_DEFAULT_LAT')) ?? 1.2136;
  static final double mapDefaultLng = double.tryParse(const String.fromEnvironment('MAP_DEFAULT_LNG')) ?? -77.2811;
  static final double mapDefaultZoom = double.tryParse(const String.fromEnvironment('MAP_DEFAULT_ZOOM')) ?? 14.5;
  static const String deepLinkScheme = String.fromEnvironment('DEEP_LINK_SCHEME', defaultValue: 'parkingapp');

  static void validate() {
    if (supabaseUrl.isEmpty) {
      throw Exception('Missing SUPABASE_URL in environment configuration. Please provide it via --dart-define-from-file.');
    }
    if (supabaseAnonKey.isEmpty) {
      throw Exception('Missing SUPABASE_ANON_KEY in environment configuration. Please provide it via --dart-define-from-file.');
    }
  }
}
