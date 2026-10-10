class EnvConfig {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const String osmTileUrl = String.fromEnvironment('OSM_TILE_URL', defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png');
  static double get mapDefaultLat => double.tryParse(const String.fromEnvironment('MAP_DEFAULT_LAT', defaultValue: '4.6097')) ?? 4.6097;
  static double get mapDefaultLng => double.tryParse(const String.fromEnvironment('MAP_DEFAULT_LNG', defaultValue: '-74.0817')) ?? -74.0817;
  static double get mapDefaultZoom => double.tryParse(const String.fromEnvironment('MAP_DEFAULT_ZOOM', defaultValue: '15.0')) ?? 15.0;
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
