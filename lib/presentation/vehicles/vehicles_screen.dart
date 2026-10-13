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
import '../shared/two_tone_title.dart';

class VehiclesScreen extends StatelessWidget {
  const VehiclesScreen({super.key});

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
                      'Mis Vehículos',
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
                    SectionLabel('GARAJE VIRTUAL'),
                    SizedBox(height: 6),
                    TwoToneTitle(text: 'Tus ', highlightText: 'vehículos'),
                  ],
                ),
                index: 1,
              ),
              const SizedBox(height: 8),
              Text(
                'Registra tus placas para ingreso automatizado por cámaras LPR.',
                style: AppTypography.body.copyWith(color: AppColors.textSecondaryLight),
              ),
              const SizedBox(height: 22),

              // Vehicle 1: Dark Card (Primary)
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'ABC · 123',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                color: AppColors.darkCard,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const StatusPill(
                            text: 'PRINCIPAL',
                            backgroundColor: Color(0xFF333333),
                            textColor: AppColors.secondary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('Mazda 3 Touring 2022', style: AppTypography.title.copyWith(color: AppColors.white, fontSize: 19)),
                      const SizedBox(height: 4),
                      Text('Sedán • Gris Titanio Metálico', style: AppTypography.caption.copyWith(color: Colors.white60)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildVehicleBadge('SOAT al día', Icons.verified_user_rounded, Colors.greenAccent),
                          const SizedBox(width: 8),
                          _buildVehicleBadge('Tag RFID Activo', Icons.nfc_rounded, Colors.amberAccent),
                        ],
                      ),
                    ],
                  ),
                ),
                index: 2,
              ),
              const SizedBox(height: 16),

              // Vehicle 2: Amber Card
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'XYZ · 789',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                color: AppColors.darkCard,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const StatusPill(
                            text: 'SUV CAMIONETA',
                            backgroundColor: AppColors.white,
                            textColor: AppColors.darkCard,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('Renault Duster Iconic 2023', style: AppTypography.title.copyWith(color: AppColors.darkCard, fontSize: 19)),
                      const SizedBox(height: 4),
                      Text('Camioneta SUV • Blanco Glaciar', style: AppTypography.caption.copyWith(color: AppColors.darkCard.withAlpha(180))),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildVehicleBadge('SOAT al día', Icons.verified_user_rounded, AppColors.darkCard),
                          const SizedBox(width: 8),
                          _buildVehicleBadge('Cupo Grande', Icons.aspect_ratio_rounded, AppColors.darkCard),
                        ],
                      ),
                    ],
                  ),
                ),
                index: 3,
              ),
              const SizedBox(height: 16),

              // Vehicle 3: White Card
              MotionUtils.staggerEntrance(
                AppCard(
                  variant: AppCardVariant.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F0F0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'KLP · 45F',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                color: AppColors.darkCard,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const StatusPill(
                            text: 'MOTOCICLETA',
                            backgroundColor: Color(0xFFE8F5E9),
                            textColor: Color(0xFF2E7D32),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text('Yamaha MT-03 2024', style: AppTypography.title.copyWith(fontSize: 18)),
                      const SizedBox(height: 4),
                      Text('Cilindraje 321cc • Negro Mate • Tarifa 40% OFF', style: AppTypography.caption.copyWith(color: AppColors.textSecondaryLight)),
                    ],
                  ),
                ),
                index: 4,
              ),
              const SizedBox(height: 24),

              MotionUtils.staggerEntrance(
                PillButton(
                  text: 'Registrar nuevo vehículo +',
                  variant: PillButtonVariant.dark,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Formulario de nuevo vehículo abierto')),
                    );
                  },
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

  Widget _buildVehicleBadge(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
