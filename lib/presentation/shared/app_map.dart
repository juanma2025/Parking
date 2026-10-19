import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/env_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/datasources/pasto_landmarks_data.dart';
import 'status_pill.dart';

class AppMap extends StatefulWidget {
  final double? height;
  final bool showControls;
  final Function(Landmark landmark)? onLandmarkSelected;
  final Function(PastoParkingLot lot)? onParkingLotSelected;

  const AppMap({
    super.key,
    this.height,
    this.showControls = true,
    this.onLandmarkSelected,
    this.onParkingLotSelected,
  });

  static void showLandmarkDetails(BuildContext context, Landmark landmark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => LandmarkDetailsSheet(landmark: landmark),
    );
  }

  static void showParkingDetails(BuildContext context, PastoParkingLot lot) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => ParkingLotDetailsSheet(lot: lot),
    );
  }

  @override
  State<AppMap> createState() => _AppMapState();
}

class _AppMapState extends State<AppMap> {
  final MapController _mapController = MapController();
  late LatLng _currentCenter;
  String _activeFilter = 'all'; // 'all', 'malls', 'hospitals', 'parking'

  @override
  void initState() {
    super.initState();
    _currentCenter = LatLng(EnvConfig.mapDefaultLat, EnvConfig.mapDefaultLng);
  }

  Future<void> _requestLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentCenter = LatLng(position.latitude, position.longitude);
        _mapController.move(_currentCenter, 15.5);
      });
    } catch (_) {}
  }

  void _centerOnPasto() {
    setState(() {
      _currentCenter = LatLng(1.2136, -77.2811);
      _mapController.move(_currentCenter, 14.5);
    });
  }

  List<Marker> _buildMarkers(BuildContext context) {
    final List<Marker> markers = [];
    final landmarks = PastoDataService.getLandmarks();

    // 1. Add Landmark Markers (Centros Comerciales y Hospitales)
    for (final landmark in landmarks) {
      final isMall = landmark.category == LandmarkCategory.shoppingMall;
      final isHospital = landmark.category == LandmarkCategory.hospital;

      if (_activeFilter == 'malls' && !isMall) continue;
      if (_activeFilter == 'hospitals' && !isHospital) continue;
      if (_activeFilter == 'parking') continue;

      markers.add(
        Marker(
          point: LatLng(landmark.latitude, landmark.longitude),
          width: 80,
          height: 68,
          child: GestureDetector(
            onTap: () {
              _mapController.move(LatLng(landmark.latitude, landmark.longitude), 16.0);
              if (widget.onLandmarkSelected != null) {
                widget.onLandmarkSelected!(landmark);
              } else {
                AppMap.showLandmarkDetails(context, landmark);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: isMall ? AppColors.primary : const Color(0xFFFF3B30),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    landmark.icon,
                    size: 20,
                    color: isMall ? AppColors.darkCard : Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard.withAlpha(230),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      landmark.shortName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 2. Add Parking Lots Markers
    if (_activeFilter == 'all' || _activeFilter == 'parking') {
      final parkingLots = PastoDataService.getAllParkingLots();
      for (final lot in parkingLots) {
        markers.add(
          Marker(
            point: LatLng(lot.latitude, lot.longitude),
            width: 75,
            height: 48,
            child: GestureDetector(
              onTap: () {
                _mapController.move(LatLng(lot.latitude, lot.longitude), 16.5);
                if (widget.onParkingLotSelected != null) {
                  widget.onParkingLotSelected!(lot);
                } else {
                  AppMap.showParkingDetails(context, lot);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.secondary, width: 1.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x40000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'P',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '\$${(lot.pricePerHour / 1000).toStringAsFixed(1)}k',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 3,
                    height: 4,
                    color: AppColors.darkCard,
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final mapWidget = Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentCenter,
            initialZoom: EnvConfig.mapDefaultZoom,
            minZoom: 12.0,
            maxZoom: 18.0,
          ),
          children: [
            TileLayer(
              urlTemplate: EnvConfig.osmTileUrl,
              userAgentPackageName: 'com.parkingapp',
            ),
            MarkerLayer(
              markers: _buildMarkers(context),
            ),
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution('© OpenStreetMap contributors • Pasto, Nariño', onTap: () {}),
              ],
            ),
          ],
        ),

        // Quick Category Filter Bar at the Top of the Map
        if (widget.showControls)
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', '📍 Todos'),
                  const SizedBox(width: 6),
                  _buildFilterChip('malls', '🛍️ C. Comerciales'),
                  const SizedBox(width: 6),
                  _buildFilterChip('hospitals', '🏥 Hospitales'),
                  const SizedBox(width: 6),
                  _buildFilterChip('parking', '🅿️ Parqueaderos'),
                ],
              ),
            ),
          ),

        // Bottom Left: City Badge
        if (widget.showControls)
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(235),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF34C759),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    'San Juan de Pasto, Nariño',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkCard,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Re-center on Pasto GPS buttons at bottom right
        if (widget.showControls)
          Positioned(
            bottom: 12,
            right: 12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))],
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    tooltip: 'Centrar en San Juan de Pasto',
                    icon: const Icon(Icons.location_city_rounded, color: AppColors.darkCard, size: 20),
                    onPressed: _centerOnPasto,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))],
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    tooltip: 'Mi ubicación',
                    icon: const Icon(Icons.my_location_rounded, color: AppColors.darkCard, size: 20),
                    onPressed: _requestLocation,
                  ),
                ),
              ],
            ),
          ),
      ],
    );

    if (widget.height != null) {
      return SizedBox(
        height: widget.height,
        width: double.infinity,
        child: mapWidget,
      );
    }

    return mapWidget;
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _activeFilter == key;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeFilter = key;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkCard : Colors.white.withAlpha(235),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.white,
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: isSelected ? AppColors.secondary : AppColors.darkCard,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// LANDMARK DETAILS SHEET
// ============================================================================
class LandmarkDetailsSheet extends StatelessWidget {
  final Landmark landmark;

  const LandmarkDetailsSheet({super.key, required this.landmark});

  @override
  Widget build(BuildContext context) {
    final isMall = landmark.category == LandmarkCategory.shoppingMall;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D1D6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Landmark Header
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isMall ? AppColors.secondary.withAlpha(80) : const Color(0xFFFFECEB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isMall ? AppColors.primary : const Color(0xFFFF3B30),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      landmark.icon,
                      color: isMall ? AppColors.darkCard : const Color(0xFFFF3B30),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StatusPill(
                          text: landmark.badgeText,
                          backgroundColor: isMall ? AppColors.secondary.withAlpha(60) : const Color(0xFFFFECEB),
                          textColor: isMall ? AppColors.darkCard : const Color(0xFFFF3B30),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          landmark.name,
                          style: AppTypography.title.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          landmark.address,
                          style: AppTypography.caption.copyWith(color: AppColors.textSecondaryLight),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                landmark.description,
                style: AppTypography.caption.copyWith(fontSize: 12, color: Colors.black87),
              ),
              const SizedBox(height: 18),

              // Section Label for Nearby Parking Lots
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PARQUEADEROS CERCANOS',
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${landmark.nearbyParkingLots.length} disponibles',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Nearby Parking Lots Cards
              ...landmark.nearbyParkingLots.map((lot) => NearbyParkingCard(lot: lot)),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// NEARBY PARKING CARD
// ============================================================================
class NearbyParkingCard extends StatelessWidget {
  final PastoParkingLot lot;

  const NearbyParkingCard({super.key, required this.lot});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x14000000), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'P',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lot.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      lot.address,
                      style: AppTypography.caption.copyWith(fontSize: 11, color: AppColors.textSecondaryLight),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    lot.formattedPrice,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.directions_walk_rounded, size: 11, color: Color(0xFF2E7D32)),
                        const SizedBox(width: 2),
                        Text(
                          '${lot.distanceMeters} m',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black12, width: 0.6),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '🚗 ${lot.carSpaces} carros • 🛵 ${lot.motoSpaces} motos',
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF3A3A3C)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/parking/${lot.id}');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6.5),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Ver y Reservar',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkCard,
                          ),
                        ),
                        SizedBox(width: 3),
                        Icon(Icons.arrow_forward_rounded, size: 12, color: AppColors.darkCard),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// PARKING LOT DETAILS SHEET
// ============================================================================
class ParkingLotDetailsSheet extends StatelessWidget {
  final PastoParkingLot lot;

  const ParkingLotDetailsSheet({super.key, required this.lot});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D1D6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'P',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const StatusPill(
                              text: 'ABIERTO AHORA',
                              backgroundColor: Color(0xFFE8F5E9),
                              textColor: Color(0xFF2E7D32),
                            ),
                            const SizedBox(width: 6),
                            Text('★ ${lot.rating}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lot.name,
                          style: AppTypography.title.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text('${lot.address} • San Juan de Pasto', style: AppTypography.caption.copyWith(color: AppColors.textSecondaryLight)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(lot.formattedPrice, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF1C1C1E))),
                        const Text('Tarifa por hora', style: TextStyle(fontSize: 10, color: Color(0xFF8E8E93))),
                      ],
                    ),
                    Container(width: 1, height: 26, color: Colors.black12),
                    Column(
                      children: [
                        Text('${lot.totalSpaces} cupos', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF1C1C1E))),
                        Text('${lot.carSpaces} carros • ${lot.motoSpaces} motos', style: const TextStyle(fontSize: 10, color: Color(0xFF8E8E93))),
                      ],
                    ),
                    Container(width: 1, height: 26, color: Colors.black12),
                    Column(
                      children: [
                        Text('${lot.distanceMeters} m', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF1C1C1E))),
                        const Text('Distancia a pie', style: TextStyle(fontSize: 10, color: Color(0xFF8E8E93))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkCard,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/parking/${lot.id}');
                },
                child: const Text('Reservar cupo en este parqueadero  →', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
