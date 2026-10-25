import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/motion_utils.dart';
import '../owner/spaces_provider.dart';
import 'reservations_provider.dart';
import '../shared/app_card.dart';
import '../shared/app_drawer.dart';
import '../shared/avatar_button.dart';
import '../shared/pill_button.dart';
import '../shared/section_label.dart';
import '../shared/status_pill.dart';
import '../shared/text_tabs.dart';
import '../shared/two_tone_title.dart';

class MyReservationsScreen extends ConsumerStatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  ConsumerState<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends ConsumerState<MyReservationsScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final activeReservations = ref.watch(userReservationsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: const AppDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              MotionUtils.staggerEntrance(
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Builder(
                        builder: (ctx) => IconButton(
                          icon: Icon(Icons.menu_rounded, color: isDark ? AppColors.white : AppColors.darkCard),
                          onPressed: () => Scaffold.of(ctx).openDrawer(),
                        ),
                      ),
                    ),
                    Text(
                      'Mis Reservas',
                      style: AppTypography.title.copyWith(
                        fontSize: 18,
                        color: isDark ? AppColors.white : AppColors.darkCard,
                      ),
                    ),
                    AvatarButton(
                      onTap: () => context.go('/profile'),
                    ),
                  ],
                ),
                index: 0,
              ),
              const SizedBox(height: 20),

              MotionUtils.staggerEntrance(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionLabel(
                      'GESTIÓN DE ESTANCIAS',
                      color: isDark ? AppColors.secondary : null,
                    ),
                    const SizedBox(height: 6),
                    const TwoToneTitle(
                      text: 'Tus ',
                      highlightText: 'reservas',
                    ),
                  ],
                ),
                index: 1,
              ),
              const SizedBox(height: 16),

              MotionUtils.staggerEntrance(
                TextTabs(
                  tabs: ['ACTIVAS (${activeReservations.length})', 'HISTORIAL (3)'],
                  selectedIndex: _selectedTab,
                  onTabSelected: (index) => setState(() => _selectedTab = index),
                ),
                index: 2,
              ),
              const SizedBox(height: 20),

              if (_selectedTab == 0) ...[
                if (activeReservations.isEmpty)
                  MotionUtils.staggerEntrance(
                    AppCard(
                      variant: AppCardVariant.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                      child: Center(
                        child: Column(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withAlpha(isDark ? 60 : 50),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.confirmation_number_outlined, size: 30, color: AppColors.secondary),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Sin reservas activas',
                              style: AppTypography.title.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Aún no tienes estancias activas en San Juan de Pasto. Selecciona un parqueadero (Unicentro, Nova Centro, Único Outlet) para reservar tu cupo y generar tu pase QR.',
                              textAlign: TextAlign.center,
                              style: AppTypography.body.copyWith(
                                color: isDark ? Colors.white.withAlpha(200) : AppColors.textSecondaryLight,
                                fontSize: 13.5,
                              ),
                            ),
                            const SizedBox(height: 20),
                            PillButton(
                              text: 'Explorar parqueaderos en Pasto',
                              variant: isDark ? PillButtonVariant.primary : PillButtonVariant.dark,
                              onPressed: () => context.go('/home'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    index: 3,
                  )
                else
                  for (int i = 0; i < activeReservations.length; i++) ...[
                    MotionUtils.staggerEntrance(
                      _buildActiveReservationCard(context, activeReservations[i]),
                      index: 3 + i,
                    ),
                    const SizedBox(height: 16),
                  ],
              ] else ...[
                // History Tab Cards (Pasto)
                MotionUtils.staggerEntrance(
                  _buildHistoryCard(
                    context,
                    title: 'Parqueadero Unicentro Plaza',
                    date: 'Ayer, 4:15 PM',
                    duration: '2h',
                    cost: '\$5.000 COP',
                    spot: 'Av. Panamericana • Cupo #14',
                    isDark: isDark,
                  ),
                  index: 3,
                ),
                const SizedBox(height: 14),
                MotionUtils.staggerEntrance(
                  _buildHistoryCard(
                    context,
                    title: 'Parqueadero Pasaje Nova',
                    date: '14 Oct 2026',
                    duration: '3h',
                    cost: '\$9.000 COP',
                    spot: 'Calle 19 # 25-22 • Cupo #12',
                    isDark: isDark,
                  ),
                  index: 4,
                ),
              ],
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveReservationCard(BuildContext context, ActiveReservationItem item) {
    final isAmber = item.id == 'RES-31940';

    if (isAmber) {
      return AppCard(
        variant: AppCardVariant.amber,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusPill(
                  text: item.statusText,
                  backgroundColor: const Color(0xFFE5A642),
                  textColor: AppColors.darkCard,
                  dotColor: AppColors.darkCard,
                ),
                Text(
                  item.spotNumber,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.darkCard,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              item.parkingLotName,
              style: AppTypography.title.copyWith(color: AppColors.darkCard, fontSize: 19),
            ),
            const SizedBox(height: 4),
            Text(
              item.address,
              style: AppTypography.caption.copyWith(color: AppColors.darkCard.withAlpha(180)),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.white.withAlpha(200),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCardStat('ESTANCIA', '3:00 - 5:00 PM'),
                  Container(width: 1, height: 26, color: Colors.black12),
                  _buildCardStat('VEHÍCULO', item.vehiclePlate),
                  Container(width: 1, height: 26, color: Colors.black12),
                  _buildCardStat('TOTAL', item.formattedTotal, highlight: true),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: PillButton(
                    text: 'Ver detalles de llegada',
                    variant: PillButtonVariant.dark,
                    onPressed: () => context.go('/confirmation'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton.icon(
                key: Key('cancel_reservation_${item.id}'),
                onPressed: () => _confirmCancelReservation(context, item),
                icon: const Icon(Icons.cancel_outlined, size: 16, color: AppColors.darkCard),
                label: const Text(
                  'Cancelar reserva',
                  style: TextStyle(
                    color: AppColors.darkCard,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Active in-progress or newly made reservation: Dark Card
    return AppCard(
      variant: AppCardVariant.dark,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusPill(
                text: item.statusText,
                backgroundColor: item.isRecent ? const Color(0xFF1B5E20) : const Color(0xFF2E7D32),
                textColor: AppColors.white,
                dotColor: const Color(0xFF81C784),
              ),
              Text(
                item.isRecent ? 'Confirmada hoy' : 'A 120 m',
                style: AppTypography.caption.copyWith(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            item.parkingLotName,
            style: AppTypography.title.copyWith(color: AppColors.white, fontSize: 20),
          ),
          const SizedBox(height: 4),
          Text(
            item.address,
            style: AppTypography.caption.copyWith(color: Colors.white60),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF333333),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCardStat('CUPO', item.spotNumber, isLight: true),
                Container(width: 1, height: 26, color: Colors.white24),
                _buildCardStat('HORA', item.entryTime, isLight: true),
                Container(width: 1, height: 26, color: Colors.white24),
                _buildCardStat('TOTAL', item.formattedTotal, isLight: true, highlight: true),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: PillButton(
                  text: 'Extender tiempo (+1h)',
                  variant: PillButtonVariant.primary,
                  onPressed: () {
                    ref.read(userReservationsProvider.notifier).extendReservation(item.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tiempo extendido con éxito (+1 hora)')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF333333),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IconButton(
                  icon: const Icon(Icons.qr_code_2_rounded, color: AppColors.secondary),
                  onPressed: () => _showQrModal(context, item.qrCode),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              key: Key('cancel_reservation_${item.id}'),
              onPressed: () => _confirmCancelReservation(context, item),
              icon: const Icon(Icons.cancel_outlined, size: 16, color: AppColors.error),
              label: const Text(
                'Cancelar reserva',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context, {
    required String title,
    required String date,
    required String duration,
    required String cost,
    required String spot,
    required bool isDark,
  }) {
    return AppCard(
      variant: AppCardVariant.white,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusPill(
                text: 'FINALIZADA',
                backgroundColor: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFEEEEEE),
                textColor: isDark ? Colors.white70 : const Color(0xFF666666),
              ),
              Text(
                date,
                style: AppTypography.caption.copyWith(
                  color: isDark ? Colors.white60 : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTypography.title.copyWith(
              fontSize: 17,
              color: isDark ? AppColors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            spot,
            style: AppTypography.caption.copyWith(
              color: isDark ? Colors.white60 : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tiempo: $duration',
                style: AppTypography.body.copyWith(
                  color: isDark ? Colors.white70 : AppColors.darkCard,
                ),
              ),
              Text(
                cost,
                style: AppTypography.bodyBold.copyWith(
                  color: isDark ? AppColors.secondary : AppColors.darkCard,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardStat(String label, String value, {bool isLight = false, bool highlight = false}) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isLight ? Colors.white60 : AppColors.darkCard.withAlpha(160),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.bodyBold.copyWith(
            fontSize: 13,
            color: highlight
                ? (isLight ? AppColors.secondary : AppColors.primary)
                : (isLight ? AppColors.white : AppColors.darkCard),
          ),
        ),
      ],
    );
  }

  void _showQrModal(BuildContext context, String code) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.lightBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text('Código de Acceso', style: AppTypography.title),
            const SizedBox(height: 8),
            Text('Presenta este código en la entrada o talanquera', style: AppTypography.body),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(24)),
              child: const Icon(Icons.qr_code_2_rounded, size: 160, color: AppColors.darkCard),
            ),
            const SizedBox(height: 16),
            Text('ID: $code', style: AppTypography.bodyBold),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _confirmCancelReservation(BuildContext context, ActiveReservationItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.cancel_outlined, color: AppColors.error, size: 26),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                '¿Cancelar reserva?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          '¿Deseas cancelar tu reserva en ${item.parkingLotName} (${item.spotNumber})?\n\nTu cupo será liberado de inmediato para otros conductores y no se generará ningún cobro por estancia.',
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        actions: [
          SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    // Libera el espacio en el provider de parqueaderos si aplica
                    final spaceKey = item.spotNumber.replaceAll('#', '').replaceAll('P-', 'A-');
                    ref.read(parkingSpacesProvider.notifier).freeSpace(spaceKey);

                    // Cancela la reserva en el provider
                    ref.read(userReservationsProvider.notifier).cancelReservation(item.id);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.darkCard,
                        content: Text(
                          'Reserva en ${item.parkingLotName} cancelada. Cupo liberado.',
                          style: const TextStyle(color: AppColors.white),
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Sí, cancelar',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(
                      'Mantener reserva',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.secondary
                            : AppColors.darkCard,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

