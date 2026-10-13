import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/user_role.dart';
import '../auth/auth_providers.dart';
import 'section_label.dart';
import 'status_pill.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRole = ref.watch(currentUserRoleProvider);
    User? user;
    try {
      user = Supabase.instance.client.auth.currentUser;
    } catch (_) {
      user = null;
    }
    final userEmail = user?.email ?? 'juan.manuel@ejemplo.com';
    final userName = user?.userMetadata?['full_name'] as String? ?? 'Juan Manuel';

    return Drawer(
      width: 320,
      backgroundColor: AppColors.lightBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  // 1. Header Profile Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.white, width: 2),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                userName.isNotEmpty ? userName[0].toUpperCase() : 'J',
                                style: const TextStyle(
                                  color: AppColors.darkCard,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.title.copyWith(
                                      color: AppColors.white,
                                      fontSize: 17,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    userEmail,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.caption.copyWith(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            StatusPill(
                              text: _getRoleDisplayName(currentRole),
                              backgroundColor: AppColors.secondary,
                              textColor: AppColors.darkCard,
                              dotColor: AppColors.darkCard,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                context.go('/profile');
                              },
                              child: Text(
                                'Ver perfil →',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. Role Switcher for preview & testing
                  const SectionLabel('CAMBIAR MODO DE VISTA'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        _buildRoleChip(
                          ref: ref,
                          context: context,
                          role: UserRole.vehicleOwner,
                          label: 'Conductor',
                          icon: Icons.directions_car_rounded,
                          isSelected: currentRole == UserRole.vehicleOwner,
                          route: '/home',
                        ),
                        const SizedBox(width: 4),
                        _buildRoleChip(
                          ref: ref,
                          context: context,
                          role: UserRole.parkingOwner,
                          label: 'Anfitrión',
                          icon: Icons.local_parking_rounded,
                          isSelected: currentRole == UserRole.parkingOwner,
                          route: '/owner-summary',
                        ),
                        const SizedBox(width: 4),
                        _buildRoleChip(
                          ref: ref,
                          context: context,
                          role: UserRole.admin,
                          label: 'Admin',
                          icon: Icons.shield_rounded,
                          isSelected: currentRole == UserRole.admin,
                          route: '/admin',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. Navigation Menu Items
                  const SectionLabel('MENÚ PRINCIPAL'),
                  const SizedBox(height: 8),

                  _buildMenuItem(
                    icon: Icons.explore_rounded,
                    title: 'Explorar Parqueaderos',
                    subtitle: 'Mapa interactivo y búsqueda',
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(userRoleStateProvider.notifier).setRole(UserRole.vehicleOwner);
                      context.go('/home');
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.calendar_today_rounded,
                    title: 'Mis Reservas',
                    subtitle: 'Activas e historial',
                    badge: '1 activa',
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(userRoleStateProvider.notifier).setRole(UserRole.vehicleOwner);
                      context.go('/my-reservations');
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.directions_car_filled_rounded,
                    title: 'Mis Vehículos',
                    subtitle: 'Placas y categorías',
                    badge: '2 autos',
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(userRoleStateProvider.notifier).setRole(UserRole.vehicleOwner);
                      context.go('/vehicles');
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.account_balance_wallet_rounded,
                    title: 'Pagos y Billetera',
                    subtitle: 'Saldo prepago y tarjetas',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/payments');
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.notifications_active_rounded,
                    title: 'Alertas y Mensajes',
                    subtitle: 'Novedades y recordatorios',
                    badge: '3 nuevas',
                    badgeColor: AppColors.primary,
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/alerts');
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.person_rounded,
                    title: 'Mi Perfil',
                    subtitle: 'Configuración y seguridad',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/profile');
                    },
                  ),

                  // Conditional items for Owner
                  if (currentRole == UserRole.parkingOwner) ...[
                    const SizedBox(height: 12),
                    const SectionLabel('GESTIÓN DE ANFITRIÓN'),
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      icon: Icons.dashboard_rounded,
                      title: 'Resumen General',
                      subtitle: 'Ocupación e ingresos',
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/owner-summary');
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.local_parking_rounded,
                      title: 'Espacios y Cupos',
                      subtitle: 'Control de disponibilidad',
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/owner-spaces');
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.assignment_rounded,
                      title: 'Reservas Recibidas',
                      subtitle: 'Vehículos en tus garajes',
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/owner-reservations');
                      },
                    ),
                  ],

                  // Conditional items for Admin
                  if (currentRole == UserRole.admin) ...[
                    const SizedBox(height: 12),
                    const SectionLabel('ADMINISTRACIÓN'),
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      icon: Icons.admin_panel_settings_rounded,
                      title: 'Panel Maestro',
                      subtitle: 'Métricas y validaciones',
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/admin');
                      },
                    ),
                  ],

                  const SizedBox(height: 16),

                  // 4. Quick Auth Navigation Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withAlpha(50),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.secondary.withAlpha(120)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ACCESO A LA CUENTA',
                          style: AppTypography.sectionLabel.copyWith(
                            color: AppColors.darkCard,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.darkCard,
                                  foregroundColor: AppColors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                icon: const Icon(Icons.login_rounded, size: 16),
                                label: const Text('Iniciar sesión', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                onPressed: () {
                                  Navigator.pop(context);
                                  ref.read(userRoleStateProvider.notifier).setRole(UserRole.guest);
                                  context.go('/login');
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.darkCard,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                icon: const Icon(Icons.person_add_rounded, size: 16),
                                label: const Text('Registrarse', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                onPressed: () {
                                  Navigator.pop(context);
                                  ref.read(userRoleStateProvider.notifier).setRole(UserRole.guest);
                                  context.go('/register');
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Footer: Logout & version
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.black.withAlpha(15))),
              ),
              child: InkWell(
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await Supabase.instance.client.auth.signOut();
                  } catch (_) {}
                  ref.read(userRoleStateProvider.notifier).setRole(UserRole.guest);
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
                child: Row(
                  children: [
                    const Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Cerrar sesión',
                      style: AppTypography.bodyBold.copyWith(
                        color: AppColors.error,
                        fontSize: 12.5,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'v1.0',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondaryLight,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleChip({
    required WidgetRef ref,
    required BuildContext context,
    required UserRole role,
    required String label,
    required IconData icon,
    required bool isSelected,
    required String route,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(userRoleStateProvider.notifier).setRole(role);
          Navigator.pop(context);
          context.go(route);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.darkCard : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? AppColors.secondary : AppColors.darkCard,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.white : AppColors.darkCard,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    String? badge,
    Color? badgeColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.secondary.withAlpha(60),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.darkCard, size: 20),
        ),
        title: Text(
          title,
          style: AppTypography.bodyBold.copyWith(
            color: AppColors.darkCard,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondaryLight,
            fontSize: 11,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor ?? AppColors.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: badgeColor != null ? AppColors.white : AppColors.darkCard,
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondaryLight, size: 20),
          ],
        ),
      ),
    );
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.guest:
        return 'INVITADO';
      case UserRole.vehicleOwner:
        return 'CONDUCTOR';
      case UserRole.parkingOwner:
        return 'ANFITRIÓN';
      case UserRole.admin:
        return 'ADMINISTRADOR';
    }
  }
}
