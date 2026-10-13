import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/config/env_config.dart';

class AppMap extends StatefulWidget {
  const AppMap({super.key});

  @override
  State<AppMap> createState() => _AppMapState();
}

class _AppMapState extends State<AppMap> {
  final MapController _mapController = MapController();
  LatLng _currentCenter = LatLng(EnvConfig.mapDefaultLat, EnvConfig.mapDefaultLng);

  Future<void> _requestLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    
    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentCenter = LatLng(position.latitude, position.longitude);
      _mapController.move(_currentCenter, EnvConfig.mapDefaultZoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentCenter,
            initialZoom: EnvConfig.mapDefaultZoom,
          ),
          children: [
            TileLayer(
              urlTemplate: EnvConfig.osmTileUrl,
              userAgentPackageName: 'com.parkingapp',
            ),
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution('© OpenStreetMap contributors', onTap: () {}),
              ],
            ),
          ],
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            heroTag: 'location_btn',
            onPressed: _requestLocation,
            child: const Icon(Icons.my_location),
          ),
        ),
      ],
    );
  }
}
