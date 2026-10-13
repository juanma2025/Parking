import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/motion_utils.dart';
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
                      'Mis Reservas',
                      style: AppTypography.title.copyWith(fontSize: 18),
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
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionLabel('GESTIÓN DE ESTANCIAS'),
                    SizedBox(height: 6),
                    TwoToneTitle(
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
                  tabs: const ['ACTIVAS (2)', 'HISTORIAL (3)'],
                  selectedIndex: _selectedTab,
                  onTabSelected: (index) => setState(() => _selectedTab = index),
                ),
                index: 2,
              ),
              const SizedBox(height: 20),

              if (_selectedTab == 0) ...[
                // Card 1: Active In-Progress (Dark Stitch Card)
                MotionUtils.staggerEntrance(
                  AppCard(
                    variant: AppCardVariant.dark,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const StatusPill(
                              text: 'EN CURSO • 42 MIN',
                              backgroundColor: Color(0xFF2E7D32),
                              textColor: AppColors.white,
                              dotColor: Color(0xFF81C784),
                            ),
                            Text(
                              'A 120 m',
                              style: AppTypography.caption.copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Parqueadero San José',
                          style: AppTypography.title.copyWith(color: AppColors.white, fontSize: 20),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Cra. 13 #72-40 • Chapinero Central',
                          style: AppTypography.caption.copyWith(color: Colors.white60),
                        ),
                        const SizedBox(height: 18),

                        // Metric Pills Row
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF333333),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildCardStat('CUPO', '#A-14', isLight: true),
                              Container(width: 1, height: 26, color: Colors.white24),
                              _buildCardStat('ENTRADA', '10:30 AM', isLight: true),
                              Container(width: 1, height: 26, color: Colors.white24),
                              _buildCardStat('ACUMULADO', '\$7.000 COP', isLight: true, highlight: true),
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
                                onPressed: () => _showQrModal(context, 'RES-84920'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  index: 3,
                ),
                const SizedBox(height: 16),

                // Card 2: Upcoming Reservation (Amber Card)
                MotionUtils.staggerEntrance(
                  AppCard(
                    variant: AppCardVariant.amber,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const StatusPill(
                              text: 'PROGRAMADA • HOY 3:00 PM',
                              backgroundColor: Color(0xFFE5A642),
                              textColor: AppColors.darkCard,
                              dotColor: AppColors.darkCard,
                            ),
                            Text(
                              'Cupo B-08',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.darkCard,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Clínica del Country - Garaje B',
                          style: AppTypography.title.copyWith(color: AppColors.darkCard, fontSize: 19),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Cra. 16 #82-29 • Chicó Norte',
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
                              _buildCardStat('VEHÍCULO', 'ABC-123'),
                              Container(width: 1, height: 26, color: Colors.black12),
                              _buildCardStat('TOTAL', '\$12.000 COP', highlight: true),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        PillButton(
                          text: 'Ver detalles de llegada',
                          variant: PillButtonVariant.dark,
                          onPressed: () => context.go('/confirmation'),
                        ),
                      ],
                    ),
                  ),
                  index: 4,
                ),
              ] else ...[
                // History Tab Cards
                MotionUtils.staggerEntrance(
                  _buildHistoryCard(
                    context,
                    title: 'Centro Comercial Andino',
                    date: 'Ayer, 4:15 PM',
                    duration: '2h 15m',
                    cost: '\$15.000 COP',
                    spot: 'Sótano 2 • #14',
                  ),
                  index: 3,
                ),
                const SizedBox(height: 14),
                MotionUtils.staggerEntrance(
                  _buildHistoryCard(
                    context,
                    title: 'Parque de la 93 Parking',
                    date: '10 Oct 2026',
                    duration: '4h 00m',
                    cost: '\$24.000 COP',
                    spot: 'Piso 1 • #03',
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

  Widget _buildHistoryCard(
    BuildContext context, {
    required String title,
    required String date,
    required String duration,
    required String cost,
    required String spot,
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
              const StatusPill(
                text: 'FINALIZADA',
                backgroundColor: Color(0xFFEEEEEE),
                textColor: Color(0xFF666666),
              ),
              Text(
                date,
                style: AppTypography.caption.copyWith(color: AppColors.textSecondaryLight),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: AppTypography.title.copyWith(fontSize: 17)),
          const SizedBox(height: 4),
          Text(spot, style: AppTypography.caption.copyWith(color: AppColors.textSecondaryLight)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tiempo: $duration', style: AppTypography.body),
              Text(
                cost,
                style: AppTypography.bodyBold.copyWith(color: AppColors.darkCard, fontSize: 16),
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
}
