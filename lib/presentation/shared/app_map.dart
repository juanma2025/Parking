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
  Marker? _userLocationMarker;

  Future<void> _requestLocationAndMove() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, activa el GPS para usar tu ubicación.')),
        );
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permiso de ubicación denegado.')),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permiso de ubicación denegado permanentemente. Habilítalo en ajustes.')),
        );
      }
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      final newLoc = LatLng(position.latitude, position.longitude);
      
      setState(() {
        _currentCenter = newLoc;
        _userLocationMarker = Marker(
          point: newLoc,
          child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
        );
      });
      _mapController.move(newLoc, EnvConfig.mapDefaultZoom);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No pudimos cargar tu ubicación. Intenta nuevamente.')),
        );
      }
    }
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
              userAgentPackageName: 'com.parking.app', // Replace with exact Application ID if different
            ),
            if (_userLocationMarker != null)
              MarkerLayer(markers: [_userLocationMarker!]),
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution(
                  '© OpenStreetMap contributors',
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: _requestLocationAndMove,
            child: const Icon(Icons.my_location),
          ),
        ),
      ],
    );
  }
}
