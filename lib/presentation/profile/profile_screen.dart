import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/motion_utils.dart';
import '../../domain/entities/user_role.dart';
import '../auth/auth_providers.dart';
import '../shared/app_card.dart';
import '../shared/app_drawer.dart';
import '../shared/avatar_button.dart';
import '../shared/pill_button.dart';
import '../shared/section_label.dart';
import '../shared/status_pill.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    User? user;
    try {
      user = Supabase.instance.client.auth.currentUser;
    } catch (_) {
      user = null;
    }
    final userName = user?.userMetadata?['full_name'] as String? ?? 'Juan Manuel';
    final userEmail = user?.email ?? 'juan.manuel@ejemplo.com';

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
                      'Mi Perfil',
                      style: AppTypography.title.copyWith(fontSize: 18),
                    ),
                    AvatarButton(
                      onTap: () {},
                    ),
                  ],
                ),
                index: 0,
              ),
              const SizedBox(height: 20),

              // Profile Card (Dark)
              MotionUtils.staggerEntrance(
                AppCard(
                  variant: AppCardVariant.dark,
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.white, width: 3),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              userName.isNotEmpty ? userName[0].toUpperCase() : 'J',
                              style: const TextStyle(
                                color: AppColors.darkCard,
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: AppTypography.title.copyWith(color: AppColors.white, fontSize: 20),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  userEmail,
                                  style: AppTypography.caption.copyWith(color: Colors.white70),
                                ),
                                const SizedBox(height: 6),
                                const StatusPill(
                                  text: 'VERIFICADO RUNT ★',
                                  backgroundColor: Color(0xFF333333),
                                  textColor: AppColors.secondary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2C2C),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('28', 'RESERVAS'),
                            Container(width: 1, height: 26, color: Colors.white12),
                            _buildStatItem('64h', 'PARQUEADAS'),
                            Container(width: 1, height: 26, color: Colors.white12),
                            _buildStatItem('\$42.5K', 'AHORRO'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                index: 1,
              ),
              const SizedBox(height: 20),

              const SizedBox(height: 10),

              // Menu Settings (White Card)
              const SectionLabel('PREFERENCIAS Y CUENTA'),
              const SizedBox(height: 10),
              MotionUtils.staggerEntrance(
                AppCard(
                  variant: AppCardVariant.white,
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      _buildProfileOption(Icons.directions_car_rounded, 'Mis Vehículos', '2 registrados', () => context.go('/vehicles')),
                      const Divider(height: 1),
                      _buildProfileOption(Icons.account_balance_wallet_rounded, 'Billetera y Métodos', '\$48.500 COP', () => context.go('/payments')),
                      const Divider(height: 1),
                      _buildProfileOption(Icons.notifications_rounded, 'Notificaciones', 'SMS y Push activadas', () => context.go('/alerts')),
                      const Divider(height: 1),
                      _buildProfileOption(Icons.security_rounded, 'Seguridad y Clave', 'Protección activa', () {}),
                      const Divider(height: 1),
                      _buildProfileOption(Icons.help_outline_rounded, 'Soporte y Ayuda', 'Atención 24/7', () {}),
                    ],
                  ),
                ),
                index: 3,
              ),
              const SizedBox(height: 20),

              // Auth Action Buttons
              MotionUtils.staggerEntrance(
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: PillButton(
                            text: 'Iniciar sesión',
                            variant: PillButtonVariant.dark,
                            onPressed: () {
                              ref.read(userRoleStateProvider.notifier).setRole(UserRole.guest);
                              context.go('/login');
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: PillButton(
                            text: 'Registrarse',
                            variant: PillButtonVariant.primary,
                            onPressed: () {
                              ref.read(userRoleStateProvider.notifier).setRole(UserRole.guest);
                              context.go('/register');
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: () async {
                        try {
                          await Supabase.instance.client.auth.signOut();
                        } catch (_) {}
                        ref.read(userRoleStateProvider.notifier).setRole(UserRole.guest);
                        if (context.mounted) {
                          context.go('/login');
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        alignment: Alignment.center,
                        child: Text(
                          'Cerrar sesión en este dispositivo',
                          style: AppTypography.bodyBold.copyWith(
                            color: AppColors.error,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
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



  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(count, style: AppTypography.title.copyWith(color: AppColors.white, fontSize: 18)),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.caption.copyWith(color: Colors.white60, fontSize: 10)),
      ],
    );
  }

  Widget _buildProfileOption(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.secondary.withAlpha(50),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.darkCard, size: 20),
      ),
      title: Text(title, style: AppTypography.bodyBold.copyWith(fontSize: 14)),
      subtitle: Text(subtitle, style: AppTypography.caption.copyWith(color: AppColors.textSecondaryLight, fontSize: 11)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondaryLight, size: 20),
    );
  }
}
