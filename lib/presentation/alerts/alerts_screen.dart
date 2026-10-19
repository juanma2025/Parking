import 'package:flutter/material.dart';
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

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
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
                      'Notificaciones',
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
                    SectionLabel('CENTRO DE MENSAJES'),
                    SizedBox(height: 6),
                    TwoToneTitle(text: 'Tus ', highlightText: 'alertas'),
                  ],
                ),
                index: 1,
              ),
              const SizedBox(height: 16),

              MotionUtils.staggerEntrance(
                TextTabs(
                  tabs: const ['TODAS (3)', 'URGENTES (1)', 'LEÍDAS (2)'],
                  selectedIndex: _selectedTab,
                  onTabSelected: (index) => setState(() => _selectedTab = index),
                ),
                index: 2,
              ),
              const SizedBox(height: 20),

              // Urgent Alert (Dark Card with Red Accent)
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
                            text: 'URGENTE • 15 MIN RESTANTES',
                            backgroundColor: Color(0xFFD32F2F),
                            textColor: AppColors.white,
                          ),
                          Text('Hace 4 min', style: AppTypography.caption.copyWith(color: Colors.white60)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '¡Tiempo de reserva por vencer!',
                        style: AppTypography.title.copyWith(color: AppColors.white, fontSize: 18),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tu reserva en Parqueadero Unicentro Plaza expira a las 12:30 PM para el vehículo ABC-123. Extiende ahora para evitar tarifas de mora.',
                        style: AppTypography.body.copyWith(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: PillButton(
                              text: 'Extender 1 hora',
                              variant: PillButtonVariant.primary,
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Reserva extendida exitosamente')),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: PillButton(
                              text: 'Voy en camino',
                              variant: PillButtonVariant.outline,
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                index: 3,
              ),
              const SizedBox(height: 14),

              // Confirmation Alert (Amber Card)
              MotionUtils.staggerEntrance(
                AppCard(
                  variant: AppCardVariant.amber,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const StatusPill(
                            text: 'CONFIRMADA',
                            backgroundColor: Color(0xFFE5A642),
                            textColor: AppColors.darkCard,
                          ),
                          Text('Hace 1 hora', style: AppTypography.caption.copyWith(color: AppColors.darkCard.withAlpha(180))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('Reserva asegurada en Parqueadero Unicentro Plaza', style: AppTypography.title.copyWith(fontSize: 17, color: AppColors.darkCard)),
                      const SizedBox(height: 4),
                      Text(
                        'Cupo B-08 confirmado para hoy a las 3:00 PM. Presenta tu pase QR en portería para ingresar.',
                        style: AppTypography.body.copyWith(color: AppColors.darkCard.withAlpha(200), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                index: 4,
              ),
              const SizedBox(height: 14),

              // Promo Alert (White Card)
              MotionUtils.staggerEntrance(
                AppCard(
                  variant: AppCardVariant.white,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const StatusPill(
                            text: 'BENEFICIO',
                            backgroundColor: Color(0xFFE3F2FD),
                            textColor: Color(0xFF1976D2),
                          ),
                          Text('Ayer', style: AppTypography.caption.copyWith(color: AppColors.textSecondaryLight)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('Tarifa especial nocturna en Centro de Pasto', style: AppTypography.title.copyWith(fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(
                        'Disfruta de \$2.000/h a partir de las 8:00 PM en parqueaderos afiliados del sector de San Juan de Pasto.',
                        style: AppTypography.body.copyWith(color: AppColors.textSecondaryLight, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                index: 5,
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
