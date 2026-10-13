import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/motion_utils.dart';
import '../../domain/entities/domain_entities.dart';
import '../shared/app_card.dart';
import '../shared/app_drawer.dart';
import '../shared/avatar_button.dart';
import '../shared/kpi_card.dart';
import '../shared/section_label.dart';
import '../shared/space_tile.dart';
import '../shared/status_pill.dart';
import '../shared/two_tone_title.dart';
import '../shared/wavy_area_chart.dart';

Widget _buildOwnerHeader(BuildContext context, String title) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppColors.darkCard),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ),
      Text(
        title,
        style: AppTypography.title.copyWith(fontSize: 18),
      ),
      AvatarButton(
        onTap: () => context.go('/profile'),
      ),
    ],
  );
}

// ============================================================================
// OWNER SUMMARY SCREEN
// ============================================================================
class OwnerSummaryScreen extends StatelessWidget {
  const OwnerSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MotionUtils.staggerEntrance(
                _buildOwnerHeader(context, 'Panel de Anfitrión'),
                index: 0,
              ),
              const SizedBox(height: 20),

              MotionUtils.staggerEntrance(
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionLabel('GESTIÓN EN TIEMPO REAL'),
                    SizedBox(height: 6),
                    TwoToneTitle(text: 'Resumen de ', highlightText: 'garaje'),
                  ],
                ),
                index: 1,
              ),
              const SizedBox(height: 20),

              // KPI Cards
              MotionUtils.staggerEntrance(
                const Row(
                  children: [
                    Expanded(
                      child: KpiCard(
                        label: 'OCUPACIÓN',
                        value: 84,
                        suffix: '%',
                        variant: AppCardVariant.dark,
                        icon: Icon(Icons.pie_chart_outline_rounded, color: AppColors.white),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: KpiCard(
                        label: 'INGRESOS HOY',
                        value: 185,
                        prefix: '\$',
                        suffix: 'K',
                        variant: AppCardVariant.amber,
                        icon: Icon(Icons.payments_outlined, color: AppColors.darkCard),
                      ),
                    ),
                  ],
                ),
                index: 2,
              ),
              const SizedBox(height: 18),

              // Wavy Chart Card
              MotionUtils.staggerEntrance(
                const WavyAreaChart(
                  title: 'INGRESOS SEMANALES',
                  subtitle: '\$1.240.000 COP',
                  values: [20, 45, 30, 65, 50, 85, 95],
                  height: 180,
                ),
                index: 3,
              ),
              const SizedBox(height: 18),

              // Active Garage Card
              MotionUtils.staggerEntrance(
                AppCard(
                  variant: AppCardVariant.white,
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.local_parking_rounded, color: AppColors.darkCard, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Parqueadero San José', style: AppTypography.title.copyWith(fontSize: 16)),
                            Text('38 cupos totales • 6 disponibles ahora', style: AppTypography.caption.copyWith(color: AppColors.textSecondaryLight)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined, color: AppColors.darkCard),
                        onPressed: () => context.go('/owner-spaces'),
                      ),
                    ],
                  ),
                ),
                index: 4,
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// OWNER SPACES SCREEN
// ============================================================================
class OwnerSpacesScreen extends StatelessWidget {
  const OwnerSpacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MotionUtils.staggerEntrance(
                _buildOwnerHeader(context, 'Espacios y Cupos'),
                index: 0,
              ),
              const SizedBox(height: 20),

              MotionUtils.staggerEntrance(
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionLabel('MONITOR DE BAHÍAS'),
                    SizedBox(height: 6),
                    TwoToneTitle(text: 'Tus ', highlightText: 'cupos'),
                  ],
                ),
                index: 1,
              ),
              const SizedBox(height: 10),
              Text(
                'Toca cualquier espacio para modificar disponibilidad o ver vehículo asignado.',
                style: AppTypography.body.copyWith(color: AppColors.textSecondaryLight),
              ),
              const SizedBox(height: 20),

              // Grid of SpaceTiles
              MotionUtils.staggerEntrance(
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.15,
                  children: [
                    SpaceTile(
                      spaceNumber: 'A-01',
                      vehicleType: 'Sedán',
                      status: ParkingSpaceStatus.occupied,
                      onTap: () {},
                    ),
                    SpaceTile(
                      spaceNumber: 'A-02',
                      vehicleType: 'Cualquiera',
                      status: ParkingSpaceStatus.available,
                      onTap: () {},
                    ),
                    SpaceTile(
                      spaceNumber: 'A-03',
                      vehicleType: 'Camioneta',
                      status: ParkingSpaceStatus.occupied,
                      onTap: () {},
                    ),
                    SpaceTile(
                      spaceNumber: 'A-04',
                      vehicleType: 'Cualquiera',
                      status: ParkingSpaceStatus.available,
                      onTap: () {},
                    ),
                    SpaceTile(
                      spaceNumber: 'B-01',
                      vehicleType: 'Moto',
                      status: ParkingSpaceStatus.occupied,
                      onTap: () {},
                    ),
                    SpaceTile(
                      spaceNumber: 'B-02',
                      vehicleType: 'Cualquiera',
                      status: ParkingSpaceStatus.available,
                      onTap: () {},
                    ),
                  ],
                ),
                index: 2,
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// OWNER RESERVATIONS SCREEN
// ============================================================================
class OwnerReservationsScreen extends StatelessWidget {
  const OwnerReservationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MotionUtils.staggerEntrance(
                _buildOwnerHeader(context, 'Reservas Recibidas'),
                index: 0,
              ),
              const SizedBox(height: 20),

              MotionUtils.staggerEntrance(
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionLabel('FLUJO DE CLIENTES'),
                    SizedBox(height: 6),
                    TwoToneTitle(text: 'Reservas ', highlightText: 'activas'),
                  ],
                ),
                index: 1,
              ),
              const SizedBox(height: 20),

              MotionUtils.staggerEntrance(
                _buildOwnerReservationCard(
                  plate: 'ABC-123',
                  driver: 'Juan Pérez',
                  spot: 'Cupo A-01',
                  time: '10:30 AM - 12:30 PM',
                  status: 'EN GARAJE',
                  amount: '\$7.000 COP',
                  isOccupied: true,
                ),
                index: 2,
              ),
              const SizedBox(height: 14),

              MotionUtils.staggerEntrance(
                _buildOwnerReservationCard(
                  plate: 'XYZ-789',
                  driver: 'María Gómez',
                  spot: 'Cupo A-03',
                  time: '11:00 AM - 1:00 PM',
                  status: 'EN GARAJE',
                  amount: '\$7.000 COP',
                  isOccupied: true,
                ),
                index: 3,
              ),
              const SizedBox(height: 14),

              MotionUtils.staggerEntrance(
                _buildOwnerReservationCard(
                  plate: 'MNP-456',
                  driver: 'Carlos Rodríguez',
                  spot: 'Cupo B-04',
                  time: '3:00 PM - 5:00 PM',
                  status: 'PROGRAMADA',
                  amount: '\$10.000 COP',
                  isOccupied: false,
                ),
                index: 4,
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOwnerReservationCard({
    required String plate,
    required String driver,
    required String spot,
    required String time,
    required String status,
    required String amount,
    required bool isOccupied,
  }) {
    return AppCard(
      variant: isOccupied ? AppCardVariant.dark : AppCardVariant.white,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusPill(
                text: status,
                backgroundColor: isOccupied ? AppColors.secondary : const Color(0xFFE0E0E0),
                textColor: AppColors.darkCard,
              ),
              Text(
                amount,
                style: AppTypography.bodyBold.copyWith(
                  color: isOccupied ? AppColors.secondary : AppColors.darkCard,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(driver, style: AppTypography.title.copyWith(fontSize: 17, color: isOccupied ? AppColors.white : AppColors.darkCard)),
          const SizedBox(height: 4),
          Text('Placa: $plate • $spot', style: AppTypography.caption.copyWith(color: isOccupied ? Colors.white70 : AppColors.textSecondaryLight)),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 14, color: isOccupied ? Colors.white60 : AppColors.textSecondaryLight),
              const SizedBox(width: 6),
              Text(time, style: AppTypography.caption.copyWith(color: isOccupied ? Colors.white70 : AppColors.textSecondaryLight)),
            ],
          ),
        ],
      ),
    );
  }
}
