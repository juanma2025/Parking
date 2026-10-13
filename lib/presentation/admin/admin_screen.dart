import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/motion_utils.dart';
import '../shared/app_card.dart';
import '../shared/app_drawer.dart';
import '../shared/avatar_button.dart';
import '../shared/kpi_card.dart';
import '../shared/section_label.dart';
import '../shared/two_tone_title.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

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
                      'Panel Administrador',
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
                    SectionLabel('SUPERVISIÓN GENERAL'),
                    SizedBox(height: 6),
                    TwoToneTitle(text: 'Control ', highlightText: 'maestro'),
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
                        label: 'USUARIOS ACTIVOS',
                        value: 1420,
                        variant: AppCardVariant.dark,
                        icon: Icon(Icons.people_outline_rounded, color: AppColors.white),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: KpiCard(
                        label: 'PARQUEADEROS',
                        value: 85,
                        variant: AppCardVariant.amber,
                        icon: Icon(Icons.local_parking_rounded, color: AppColors.darkCard),
                      ),
                    ),
                  ],
                ),
                index: 2,
              ),
              const SizedBox(height: 16),

              MotionUtils.staggerEntrance(
                AppCard(
                  variant: AppCardVariant.white,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionLabel('SOLICITUDES PENDIENTES'),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.verified_outlined, color: AppColors.primary),
                        title: const Text('Parqueadero Tequendama', style: TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: const Text('Validación de RUT y Cámara de Comercio'),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkCard),
                          onPressed: () {},
                          child: const Text('Revisar', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
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
}
