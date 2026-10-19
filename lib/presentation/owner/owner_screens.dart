import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/motion_utils.dart';
import '../payments/payments_provider.dart';
import '../shared/app_card.dart';
import '../shared/app_drawer.dart';
import '../shared/avatar_button.dart';
import '../shared/kpi_card.dart';
import '../shared/pill_button.dart';
import '../shared/section_label.dart';
import '../shared/space_tile.dart';
import '../shared/status_pill.dart';
import '../shared/two_tone_title.dart';
import '../shared/wavy_area_chart.dart';
import 'calendar_provider.dart';
import 'spaces_provider.dart';

Widget _buildOwnerHeader(BuildContext context, String title) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 30 : 8),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Builder(
          builder: (ctx) => IconButton(
            icon: Icon(Icons.menu_rounded, color: isDark ? AppColors.white : AppColors.darkCard),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ),
      Text(
        title,
        style: AppTypography.title.copyWith(
          fontSize: 18,
          color: isDark ? AppColors.white : AppColors.darkCard,
        ),
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
class OwnerSummaryScreen extends ConsumerWidget {
  const OwnerSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final occupancyPercent = ref.watch(occupancyPercentageProvider);
    final totalRevenue = ref.watch(totalRevenueTodayProvider);
    final cashRevenue = ref.watch(cashRevenueTodayProvider);
    final nequiRevenue = ref.watch(nequiRevenueTodayProvider);
    final transferRevenue = ref.watch(transferRevenueTodayProvider);
    final availableCount = ref.watch(availableSpacesCountProvider);
    final occupiedCount = ref.watch(occupiedSpacesCountProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Format revenue for KPI (e.g. 185K)
    final revenueInThousands = (totalRevenue / 1000).round();

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

              // KPI Cards with Interactive onTap
              MotionUtils.staggerEntrance(
                Row(
                  children: [
                    Expanded(
                      child: KpiCard(
                        label: 'OCUPACIÓN',
                        value: occupancyPercent,
                        suffix: '%',
                        variant: AppCardVariant.dark,
                        icon: const Icon(Icons.pie_chart_outline_rounded, color: AppColors.white),
                        onTap: () => _showOccupancyBreakdownModal(
                          context,
                          occupiedCount: occupiedCount,
                          availableCount: availableCount,
                          occupancyPercent: occupancyPercent,
                          isDark: isDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: KpiCard(
                        label: 'INGRESOS HOY',
                        value: revenueInThousands,
                        prefix: '\$',
                        suffix: 'K',
                        variant: AppCardVariant.amber,
                        icon: const Icon(Icons.payments_outlined, color: AppColors.darkCard),
                        onTap: () => _showRevenueBreakdownModal(
                          context,
                          totalRevenue: totalRevenue,
                          cashRevenue: cashRevenue,
                          nequiRevenue: nequiRevenue,
                          transferRevenue: transferRevenue,
                          isDark: isDark,
                        ),
                      ),
                    ),
                  ],
                ),
                index: 2,
              ),
              const SizedBox(height: 18),

              // Wavy Chart Card with Interactive onTap
              MotionUtils.staggerEntrance(
                WavyAreaChart(
                  title: 'INGRESOS SEMANALES',
                  subtitle: '\$1.240.000 COP',
                  values: const [20, 45, 30, 65, 50, 85, 95],
                  height: 180,
                  onTap: () => _showWeeklyChartModal(context, isDark: isDark),
                ),
                index: 3,
              ),
              const SizedBox(height: 18),

              // Active Garage Card with Interactive onTap
              MotionUtils.staggerEntrance(
                AppCard(
                  variant: AppCardVariant.white,
                  padding: const EdgeInsets.all(18),
                  onTap: () => _showGarageDetailsModal(context, isDark: isDark),
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
                            Text(
                              'Parqueadero Pasaje Nova Centro',
                              style: AppTypography.title.copyWith(fontSize: 16),
                            ),
                            Text(
                              '38 cupos totales • Calle 19 # 25-22, Pasto',
                              style: AppTypography.caption.copyWith(color: AppColors.textSecondaryLight),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.secondary, size: 24),
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

  void _showOccupancyBreakdownModal(
    BuildContext context, {
    required int occupiedCount,
    required int availableCount,
    required int occupancyPercent,
    required bool isDark,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const TwoToneTitle(text: 'Estado de ', highlightText: 'bahías'),
            const SizedBox(height: 8),
            Text(
              'Ocupación actual del $occupancyPercent% en el garaje Pasaje Nova Centro.',
              style: AppTypography.body.copyWith(
                color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.secondary, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CUPOS LIBRES', style: AppTypography.sectionLabel.copyWith(color: AppColors.secondary)),
                        const SizedBox(height: 4),
                        Text('$availableCount', style: AppTypography.display.copyWith(fontSize: 26, color: isDark ? Colors.white : AppColors.darkCard)),
                        Text('Disponibles ahora', style: AppTypography.caption.copyWith(color: isDark ? Colors.white60 : AppColors.textSecondaryLight)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.white24 : const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CUPOS OCUPADOS', style: AppTypography.sectionLabel.copyWith(color: const Color(0xFFE65100))),
                        const SizedBox(height: 4),
                        Text('$occupiedCount', style: AppTypography.display.copyWith(fontSize: 26, color: isDark ? Colors.white : AppColors.darkCard)),
                        Text('Vehículos en bahía', style: AppTypography.caption.copyWith(color: isDark ? Colors.white60 : AppColors.textSecondaryLight)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            PillButton(
              text: 'Gestionar bahías y cupos',
              variant: PillButtonVariant.primary,
              onPressed: () {
                Navigator.pop(ctx);
                context.go('/owner-spaces');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showRevenueBreakdownModal(
    BuildContext context, {
    required double totalRevenue,
    required double cashRevenue,
    required double nequiRevenue,
    required double transferRevenue,
    required bool isDark,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const TwoToneTitle(text: 'Arqueo de ', highlightText: 'hoy'),
            const SizedBox(height: 8),
            Text(
              'Total recaudado: \$${totalRevenue.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} COP',
              style: AppTypography.title.copyWith(fontSize: 16, color: AppColors.secondary),
            ),
            const SizedBox(height: 18),
            _buildBreakdownItem(
              icon: Icons.payments_rounded,
              iconColor: const Color(0xFF2E7D32),
              title: 'Efectivo en Caja',
              amount: cashRevenue,
              isDark: isDark,
            ),
            const Divider(height: 20),
            _buildBreakdownItem(
              icon: Icons.qr_code_2_rounded,
              iconColor: const Color(0xFF7B1FA2),
              title: 'Nequi Directo',
              amount: nequiRevenue,
              isDark: isDark,
            ),
            const Divider(height: 20),
            _buildBreakdownItem(
              icon: Icons.account_balance_rounded,
              iconColor: const Color(0xFF0288D1),
              title: 'Transferencias (Bancolombia/Daviplata)',
              amount: transferRevenue,
              isDark: isDark,
            ),
            const SizedBox(height: 24),
            PillButton(
              text: 'Registrar nuevo pago en taquilla',
              variant: PillButtonVariant.primary,
              onPressed: () {
                Navigator.pop(ctx);
                context.go('/payments');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  static Widget _buildBreakdownItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required double amount,
    required bool isDark,
  }) {
    final formatted = '\$${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} COP';
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconColor.withAlpha(30),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: AppTypography.bodyBold.copyWith(
              color: isDark ? Colors.white : AppColors.darkCard,
            ),
          ),
        ),
        Text(
          formatted,
          style: AppTypography.title.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.secondary : AppColors.darkCard,
          ),
        ),
      ],
    );
  }

  void _showWeeklyChartModal(BuildContext context, {required bool isDark}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const TwoToneTitle(text: 'Rendimiento ', highlightText: 'semanal'),
            const SizedBox(height: 6),
            Text(
              'Total de la semana: \$1.240.000 COP (+18% vs semana anterior)',
              style: AppTypography.body.copyWith(
                color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 18),
            const WavyAreaChart(
              title: 'TENDENCIA DE FACTURACIÓN',
              subtitle: '7 DÍAS',
              values: [20, 45, 30, 65, 50, 85, 95],
              height: 140,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Día de mayor afluencia:', style: AppTypography.caption.copyWith(color: isDark ? Colors.white70 : AppColors.textSecondaryLight)),
                  Text('Viernes (\$260.000 COP)', style: AppTypography.bodyBold.copyWith(color: AppColors.secondary)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            PillButton(
              text: 'Cerrar detalle',
              variant: PillButtonVariant.dark,
              onPressed: () => Navigator.pop(ctx),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showGarageDetailsModal(BuildContext context, {required bool isDark}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_parking_rounded, color: AppColors.darkCard, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Parqueadero Pasaje Nova Centro',
                        style: AppTypography.title.copyWith(fontSize: 17, color: isDark ? Colors.white : AppColors.darkCard),
                      ),
                      Text(
                        'Calle 19 # 25-22, Pasto, Nariño',
                        style: AppTypography.caption.copyWith(color: isDark ? Colors.white60 : AppColors.textSecondaryLight),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildGarageInfoRow(icon: Icons.access_time_rounded, label: 'Horario', value: '06:00 AM - 10:00 PM (Lun a Sáb)', isDark: isDark),
            const SizedBox(height: 10),
            _buildGarageInfoRow(icon: Icons.directions_car_rounded, label: 'Tarifa Carros', value: '\$2.800 COP / hora', isDark: isDark),
            const SizedBox(height: 10),
            _buildGarageInfoRow(icon: Icons.two_wheeler_rounded, label: 'Tarifa Motos', value: '\$1.400 COP / hora', isDark: isDark),
            const SizedBox(height: 10),
            _buildGarageInfoRow(icon: Icons.verified_user_outlined, label: 'Seguridad', value: 'Cámaras 24/7 y póliza todo riesgo', isDark: isDark),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: PillButton(
                    text: 'Ver en Mapa',
                    variant: PillButtonVariant.dark,
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.go('/home');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PillButton(
                    text: 'Cupos en vivo',
                    variant: PillButtonVariant.primary,
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.go('/owner-spaces');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  static Widget _buildGarageInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.secondary),
        const SizedBox(width: 10),
        Text('$label: ', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700, color: isDark ? Colors.white70 : AppColors.darkCard)),
        Expanded(
          child: Text(
            value,
            style: AppTypography.caption.copyWith(color: isDark ? Colors.white : AppColors.darkCard),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// OWNER SPACES SCREEN (MONITOR DE BAHÍAS INTERACTIVO)
// ============================================================================
class OwnerSpacesScreen extends ConsumerStatefulWidget {
  const OwnerSpacesScreen({super.key});

  @override
  ConsumerState<OwnerSpacesScreen> createState() => _OwnerSpacesScreenState();
}

class _OwnerSpacesScreenState extends ConsumerState<OwnerSpacesScreen> {
  String _filter = 'TODOS'; // 'TODOS', 'LIBRES', 'OCUPADOS'

  @override
  Widget build(BuildContext context) {
    final spaces = ref.watch(parkingSpacesProvider);
    final availableCount = ref.watch(availableSpacesCountProvider);
    final occupiedCount = ref.watch(occupiedSpacesCountProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredSpaces = spaces.where((s) {
      if (_filter == 'LIBRES') return s.isAvailable;
      if (_filter == 'OCUPADOS') return s.isOccupied;
      return true;
    }).toList();

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
                    SectionLabel('MONITOR DE BAHÍAS EN TIEMPO REAL'),
                    SizedBox(height: 6),
                    TwoToneTitle(text: 'Tus ', highlightText: 'cupos'),
                  ],
                ),
                index: 1,
              ),
              const SizedBox(height: 8),
              Text(
                'Toca cualquier espacio para modificar disponibilidad, liberar bahía o registrar salida.',
                style: AppTypography.body.copyWith(
                  color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 16),

              // Filter Chips + Quick Stats
              MotionUtils.staggerEntrance(
                Row(
                  children: [
                    _buildFilterChip('TODOS (${spaces.length})', 'TODOS', isDark),
                    const SizedBox(width: 8),
                    _buildFilterChip('LIBRES ($availableCount)', 'LIBRES', isDark),
                    const SizedBox(width: 8),
                    _buildFilterChip('OCUPADOS ($occupiedCount)', 'OCUPADOS', isDark),
                  ],
                ),
                index: 2,
              ),
              const SizedBox(height: 18),

              // Grid of Interactive SpaceTiles
              MotionUtils.staggerEntrance(
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.15,
                  children: [
                    for (final space in filteredSpaces)
                      SpaceTile(
                        spaceNumber: space.spaceNumber,
                        vehicleType: space.vehicleType,
                        status: space.status,
                        onTap: () => _handleSpaceTap(context, space, isDark),
                      ),
                  ],
                ),
                index: 3,
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, bool isDark) {
    final isSelected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondary
              : (isDark ? AppColors.darkCard : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.secondary : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? AppColors.darkCard : (isDark ? Colors.white70 : AppColors.darkCard),
          ),
        ),
      ),
    );
  }

  void _handleSpaceTap(BuildContext context, OwnerSpaceItem space, bool isDark) {
    if (space.isOccupied) {
      _showOccupiedSpaceModal(context, space, isDark);
    } else {
      _showAvailableSpaceModal(context, space, isDark);
    }
  }

  /// Modal para habilitar/liberar un espacio ocupado
  void _showOccupiedSpaceModal(BuildContext context, OwnerSpaceItem space, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TwoToneTitle(text: 'Cupo ', highlightText: space.spaceNumber),
                const StatusPill(
                  text: 'OCUPADO',
                  backgroundColor: Color(0xFFE65100),
                  textColor: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Vehicle & Stay Details Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Vehículo / Placa:', space.plate ?? 'ABC-123', isDark),
                  const Divider(height: 16),
                  _buildDetailRow('Tipo:', space.vehicleType, isDark),
                  const Divider(height: 16),
                  _buildDetailRow('Conductor:', space.driverName ?? 'Conductor asignado', isDark),
                  const Divider(height: 16),
                  _buildDetailRow('Hora de Ingreso:', space.entryTime ?? '10:30 AM', isDark),
                  const Divider(height: 16),
                  _buildDetailRow('Tarifa por Hora:', '\$${space.hourlyRate.toInt()} COP', isDark),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Primary Action: Habilitar / Liberar Espacio
            PillButton(
              text: '✓ Habilitar espacio (Marcar como LIBRE)',
              variant: PillButtonVariant.primary,
              onPressed: () {
                ref.read(parkingSpacesProvider.notifier).freeSpace(space.spaceNumber);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✓ Cupo ${space.spaceNumber} habilitado como LIBRE. Registro actualizado.'),
                    backgroundColor: const Color(0xFF2E7D32),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const SizedBox(height: 10),

            // Secondary Action: Cobrar en Taquilla y Liberar
            PillButton(
              text: 'Cobrar en taquilla y liberar bahía',
              variant: PillButtonVariant.dark,
              onPressed: () {
                ref.read(parkingSpacesProvider.notifier).freeSpace(space.spaceNumber);
                Navigator.pop(ctx);
                context.go('/payments');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// Modal para ocupar manualmente un espacio disponible
  void _showAvailableSpaceModal(BuildContext context, OwnerSpaceItem space, bool isDark) {
    final plateCtrl = TextEditingController();
    final driverCtrl = TextEditingController();
    String vehicleType = 'Sedán';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TwoToneTitle(text: 'Cupo ', highlightText: space.spaceNumber),
                  const StatusPill(
                    text: 'LIBRE',
                    backgroundColor: AppColors.secondary,
                    textColor: AppColors.darkCard,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Este espacio está disponible. Puedes asignar un vehículo que ingrese al garaje.',
                style: AppTypography.caption.copyWith(
                  color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: plateCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Placa del vehículo (ej: ABC-123)',
                  filled: true,
                  fillColor: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.pin_rounded, color: AppColors.secondary),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: driverCtrl,
                decoration: InputDecoration(
                  labelText: 'Nombre del conductor (opcional)',
                  filled: true,
                  fillColor: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.secondary),
                ),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: vehicleType,
                items: const [
                  DropdownMenuItem(value: 'Sedán', child: Text('Carro / Sedán')),
                  DropdownMenuItem(value: 'Camioneta', child: Text('Camioneta / SUV')),
                  DropdownMenuItem(value: 'Moto', child: Text('Motocicleta')),
                ],
                onChanged: (val) {
                  if (val != null) setModalState(() => vehicleType = val);
                },
                decoration: InputDecoration(
                  labelText: 'Tipo de Vehículo',
                  filled: true,
                  fillColor: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.directions_car_rounded, color: AppColors.secondary),
                ),
              ),
              const SizedBox(height: 20),

              PillButton(
                text: 'Asignar y Ocupar Espacio',
                variant: PillButtonVariant.primary,
                onPressed: () {
                  final plate = plateCtrl.text.trim();
                  if (plate.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Por favor ingresa la placa del vehículo')),
                    );
                    return;
                  }

                  ref.read(parkingSpacesProvider.notifier).occupySpace(
                        space.spaceNumber,
                        plate: plate,
                        vehicleType: vehicleType,
                        driverName: driverCtrl.text.trim().isNotEmpty ? driverCtrl.text.trim() : null,
                      );

                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✓ Cupo ${space.spaceNumber} asignado al vehículo $plate.'),
                      backgroundColor: const Color(0xFF2E7D32),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildDetailRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.caption.copyWith(color: isDark ? Colors.white60 : AppColors.textSecondaryLight)),
        Text(value, style: AppTypography.bodyBold.copyWith(color: isDark ? Colors.white : AppColors.darkCard)),
      ],
    );
  }
}

// ============================================================================
// OWNER RESERVATIONS SCREEN (PANEL DE CALENDARIO ESPECIAL)
// ============================================================================
class OwnerReservationsScreen extends ConsumerStatefulWidget {
  const OwnerReservationsScreen({super.key});

  @override
  ConsumerState<OwnerReservationsScreen> createState() => _OwnerReservationsScreenState();
}

class _OwnerReservationsScreenState extends ConsumerState<OwnerReservationsScreen> {
  String _statusFilter = 'TODAS'; // 'TODAS', 'EN GARAJE', 'POR LLEGAR', 'FINALIZADA'
  int _selectedDayOffset = 0; // 0: Hoy, 1: Mañana, 2: +2d, etc.

  @override
  Widget build(BuildContext context) {
    final calendarItems = ref.watch(ownerCalendarProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredItems = calendarItems.where((item) {
      if (_statusFilter == 'EN GARAJE') return item.status == OwnerReservationState.enGaraje;
      if (_statusFilter == 'POR LLEGAR') return item.status == OwnerReservationState.porLlegar;
      if (_statusFilter == 'FINALIZADA') return item.status == OwnerReservationState.finalizada;
      return true;
    }).toList();

    return Scaffold(
      drawer: const AppDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MotionUtils.staggerEntrance(
                _buildOwnerHeader(context, 'Agenda y Calendario'),
                index: 0,
              ),
              const SizedBox(height: 20),

              MotionUtils.staggerEntrance(
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionLabel('GESTIÓN DE CITAS Y CUPOS'),
                        SizedBox(height: 6),
                        TwoToneTitle(text: 'Agenda de ', highlightText: 'reservas'),
                      ],
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.add_rounded, color: AppColors.darkCard, size: 22),
                      ),
                      tooltip: 'Agendar nueva reserva',
                      onPressed: () => _showAddReservationModal(context, isDark),
                    ),
                  ],
                ),
                index: 1,
              ),
              const SizedBox(height: 16),

              // Calendar Days Horizontal Bar
              MotionUtils.staggerEntrance(
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (int idx = 0; idx < 7; idx++) ...[
                        GestureDetector(
                          onTap: () => setState(() => _selectedDayOffset = idx),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 58,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedDayOffset == idx
                                  ? AppColors.secondary
                                  : (isDark ? AppColors.darkCard : Colors.white),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _selectedDayOffset == idx
                                    ? AppColors.secondary
                                    : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _getDayShortName(DateTime.now().add(Duration(days: idx)).weekday, idx),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: _selectedDayOffset == idx
                                        ? AppColors.darkCard
                                        : (isDark ? Colors.white60 : AppColors.textSecondaryLight),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${DateTime.now().add(Duration(days: idx)).day}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: _selectedDayOffset == idx
                                        ? AppColors.darkCard
                                        : (isDark ? Colors.white : AppColors.darkCard),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (idx < 6) const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
                index: 2,
              ),
              const SizedBox(height: 16),

              // Status Filter Tabs
              MotionUtils.staggerEntrance(
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatusFilterChip('TODAS (${calendarItems.length})', 'TODAS', isDark),
                      const SizedBox(width: 8),
                      _buildStatusFilterChip(
                        'EN GARAJE (${calendarItems.where((i) => i.status == OwnerReservationState.enGaraje).length})',
                        'EN GARAJE',
                        isDark,
                      ),
                      const SizedBox(width: 8),
                      _buildStatusFilterChip(
                        'POR LLEGAR (${calendarItems.where((i) => i.status == OwnerReservationState.porLlegar).length})',
                        'POR LLEGAR',
                        isDark,
                      ),
                      const SizedBox(width: 8),
                      _buildStatusFilterChip(
                        'FINALIZADAS (${calendarItems.where((i) => i.status == OwnerReservationState.finalizada).length})',
                        'FINALIZADA',
                        isDark,
                      ),
                    ],
                  ),
                ),
                index: 3,
              ),
              const SizedBox(height: 16),

              // QR Scanner Banner for Parking Operator
              MotionUtils.staggerEntrance(
                AppCard(
                  variant: AppCardVariant.amber,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.darkCard,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.secondary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Escanear QR de Conductor',
                              style: AppTypography.title.copyWith(fontSize: 15, color: AppColors.darkCard),
                            ),
                            Text(
                              'Valida el ingreso o egreso de vehículos',
                              style: AppTypography.caption.copyWith(color: AppColors.darkCard.withAlpha(200)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      PillButton(
                        text: 'Escanear',
                        width: 96,
                        variant: PillButtonVariant.dark,
                        onPressed: () => _showScanQrDialog(context),
                      ),
                    ],
                  ),
                ),
                index: 4,
              ),
              const SizedBox(height: 16),

              // List of Reservations Cards
              if (filteredItems.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      'No hay reservas para el filtro seleccionado',
                      style: AppTypography.body.copyWith(color: isDark ? Colors.white60 : AppColors.textSecondaryLight),
                    ),
                  ),
                )
              else
                for (int i = 0; i < filteredItems.length; i++) ...[
                  MotionUtils.staggerEntrance(
                    _buildInteractiveReservationCard(context, filteredItems[i], isDark),
                    index: 5 + i,
                  ),
                  const SizedBox(height: 12),
                ],

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilterChip(String label, String value, bool isDark) {
    final isSelected = _statusFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _statusFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkCard : (isDark ? AppColors.darkCard : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.secondary : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? AppColors.secondary : (isDark ? Colors.white70 : AppColors.darkCard),
          ),
        ),
      ),
    );
  }

  static String _getDayShortName(int weekday, int offset) {
    if (offset == 0) return 'Hoy';
    if (offset == 1) return 'Mañ';
    switch (weekday) {
      case DateTime.monday: return 'Lun';
      case DateTime.tuesday: return 'Mar';
      case DateTime.wednesday: return 'Mié';
      case DateTime.thursday: return 'Jue';
      case DateTime.friday: return 'Vie';
      case DateTime.saturday: return 'Sáb';
      case DateTime.sunday: return 'Dom';
      default: return 'Día';
    }
  }

  Widget _buildInteractiveReservationCard(
    BuildContext context,
    OwnerCalendarItem item,
    bool isDark,
  ) {
    final isEnGaraje = item.status == OwnerReservationState.enGaraje;
    final isPorLlegar = item.status == OwnerReservationState.porLlegar;

    Color badgeBgColor;
    Color badgeTextColor;
    if (isEnGaraje) {
      badgeBgColor = AppColors.secondary;
      badgeTextColor = AppColors.darkCard;
    } else if (isPorLlegar) {
      badgeBgColor = const Color(0xFF0288D1);
      badgeTextColor = Colors.white;
    } else {
      badgeBgColor = const Color(0xFF757575);
      badgeTextColor = Colors.white;
    }

    return AppCard(
      variant: isDark ? AppCardVariant.dark : (isEnGaraje ? AppCardVariant.dark : AppCardVariant.white),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusPill(
                text: item.statusLabel,
                backgroundColor: badgeBgColor,
                textColor: badgeTextColor,
              ),
              Text(
                item.formattedAmount,
                style: AppTypography.bodyBold.copyWith(
                  color: (isDark || isEnGaraje) ? AppColors.secondary : AppColors.darkCard,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.driver,
            style: AppTypography.title.copyWith(
              fontSize: 17,
              color: (isDark || isEnGaraje) ? AppColors.white : AppColors.darkCard,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Placa: ${item.plate} • ${item.spot} • ${item.vehicleType}',
            style: AppTypography.caption.copyWith(
              color: (isDark || isEnGaraje) ? Colors.white70 : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 14,
                color: (isDark || isEnGaraje) ? Colors.white60 : AppColors.textSecondaryLight,
              ),
              const SizedBox(width: 6),
              Text(
                item.timeRange,
                style: AppTypography.caption.copyWith(
                  color: (isDark || isEnGaraje) ? Colors.white70 : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Action Buttons depending on status
          if (isPorLlegar)
            Row(
              children: [
                Expanded(
                  child: PillButton(
                    text: 'Dar Entrada (Check-In)',
                    variant: PillButtonVariant.primary,
                    onPressed: () {
                      ref.read(ownerCalendarProvider.notifier).checkIn(item.id);
                      final spaceNum = item.spot.replaceAll('Cupo ', '');
                      ref.read(parkingSpacesProvider.notifier).occupySpace(
                            spaceNum,
                            plate: item.plate,
                            vehicleType: item.vehicleType,
                            driverName: item.driver,
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('✓ Check-In exitoso: Vehículo ${item.plate} ingresó a ${item.spot}.'),
                          backgroundColor: const Color(0xFF2E7D32),
                        ),
                      );
                    },
                  ),
                ),
              ],
            )
          else if (isEnGaraje)
            Row(
              children: [
                Expanded(
                  child: PillButton(
                    text: 'Dar Salida y Registrar Pago',
                    variant: PillButtonVariant.primary,
                    onPressed: () {
                      ref.read(ownerCalendarProvider.notifier).checkOut(item.id);
                      final spaceNum = item.spot.replaceAll('Cupo ', '');
                      ref.read(parkingSpacesProvider.notifier).freeSpace(spaceNum);
                      context.go('/payments');
                    },
                  ),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Servicio finalizado y liquidado',
                    style: TextStyle(color: Color(0xFF2E7D32), fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showAddReservationModal(BuildContext context, bool isDark) {
    final plateCtrl = TextEditingController();
    final driverCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String spot = 'Cupo A-02';
    String vehicleType = 'Sedán';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const TwoToneTitle(text: 'Agendar nueva ', highlightText: 'reserva'),
              const SizedBox(height: 8),
              Text(
                'Registra un cupo reservado por llamada o anticipado para el garaje.',
                style: AppTypography.caption.copyWith(color: isDark ? Colors.white70 : AppColors.textSecondaryLight),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: plateCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Placa (ej: XYZ-992)',
                  filled: true,
                  fillColor: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.pin_rounded, color: AppColors.secondary),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: driverCtrl,
                decoration: InputDecoration(
                  labelText: 'Nombre del Conductor',
                  filled: true,
                  fillColor: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.secondary),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Teléfono de contacto',
                  filled: true,
                  fillColor: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.secondary),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: spot,
                      items: const [
                        DropdownMenuItem(value: 'Cupo A-02', child: Text('Cupo A-02')),
                        DropdownMenuItem(value: 'Cupo A-04', child: Text('Cupo A-04')),
                        DropdownMenuItem(value: 'Cupo B-02', child: Text('Cupo B-02')),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => spot = val);
                      },
                      decoration: InputDecoration(
                        labelText: 'Bahía',
                        filled: true,
                        fillColor: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: vehicleType,
                      items: const [
                        DropdownMenuItem(value: 'Sedán', child: Text('Sedán')),
                        DropdownMenuItem(value: 'Camioneta', child: Text('Camioneta')),
                        DropdownMenuItem(value: 'Moto', child: Text('Moto')),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => vehicleType = val);
                      },
                      decoration: InputDecoration(
                        labelText: 'Tipo',
                        filled: true,
                        fillColor: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              PillButton(
                text: 'Confirmar y Guardar Reserva',
                variant: PillButtonVariant.primary,
                onPressed: () {
                  final plate = plateCtrl.text.trim();
                  final driver = driverCtrl.text.trim();
                  if (plate.isEmpty || driver.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Por favor completa placa y nombre del conductor')),
                    );
                    return;
                  }

                  ref.read(ownerCalendarProvider.notifier).addReservation(
                        plate: plate,
                        driver: driver,
                        spot: spot,
                        timeRange: 'Próxima llegada hoy',
                        amount: 5600.0,
                        vehicleType: vehicleType,
                        date: DateTime.now(),
                        phone: phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : null,
                      );

                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✓ Reserva para $driver ($plate) agendada en $spot.'),
                      backgroundColor: const Color(0xFF2E7D32),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showScanQrDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const TwoToneTitle(text: 'Escanear pase ', highlightText: 'QR'),
            const SizedBox(height: 8),
            Text(
              'Apunta la cámara al pase QR del conductor para verificar su estancia y liquidar el cobro en taquilla.',
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: AppColors.textSecondaryLight),
            ),
            const SizedBox(height: 24),
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.secondary, width: 2),
              ),
              child: const Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.qr_code_scanner_rounded, size: 70, color: AppColors.secondary),
                  Positioned(
                    bottom: 12,
                    child: Text(
                      'Visor de Cámara',
                      style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            PillButton(
              text: 'Validar y registrar cobro en taquilla',
              variant: PillButtonVariant.dark,
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✓ Pase QR verificado. Cobro registrado exitosamente en taquilla.'),
                    backgroundColor: Color(0xFF2E7D32),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
