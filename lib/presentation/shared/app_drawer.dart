import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/user_role.dart';
import '../auth/auth_providers.dart';

/// AppDrawer redesigned with Apple iOS Human Interface Guidelines:
/// - iOS Inset Grouped layout (Cupertino Settings aesthetic)
/// - Apple squircle icons with system tint colors
/// - Clean typography and subtle hairline dividers
/// - Default role state without hardcoded profiles or manual mode switchers
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRole = ref.watch(currentUserRoleProvider);
    final isAuth = ref.watch(isAuthenticatedProvider);
    final user = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(currentProfileProvider);

    final String userName;
    final String userEmail;
    final String initialLetter;

    if (isAuth && user != null) {
      final profileName = profileAsync.value?.fullName;
      final metaName = user.userMetadata?['full_name'] as String?;
      userName = (profileName != null && profileName.trim().isNotEmpty)
          ? profileName.trim()
          : (metaName != null && metaName.trim().isNotEmpty)
              ? metaName.trim()
              : (user.email?.split('@').first ?? 'Conductor');
      userEmail = user.email ?? 'Sin correo vinculado';
      initialLetter = userName.isNotEmpty ? userName[0].toUpperCase() : 'C';
    } else {
      userName = 'Modo Exploración';
      userEmail = 'Sin sesión iniciada';
      initialLetter = 'E';
    }

    return Drawer(
      width: 310,
      backgroundColor: const Color(0xFFF2F2F7), // iOS System Grouped Background
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(30)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                children: [
                  // 1. Apple ID / Account Status Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0x0A000000), width: 0.8),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x08000000),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFF2C2C2E), Color(0xFF1C1C1E)],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0x99FBAB56), width: 1.5),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                initialLetter,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF1C1C1E),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    userEmail,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF8E8E93),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F2F7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF34C759), // iOS Green
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  _getRoleBadgeLabel(currentRole),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                    color: Color(0xFF1C1C1E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. Main Services (iOS Inset Grouped List)
                  const Padding(
                    padding: EdgeInsets.only(left: 8, bottom: 8),
                    child: Text(
                      'SERVICIOS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8E8E93),
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0x0A000000), width: 0.8),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x08000000),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        _buildAppleMenuItem(
                          context: context,
                          icon: Icons.explore_rounded,
                          iconColor: const Color(0xFF007AFF), // Apple Blue
                          title: 'Explorar Parqueaderos',
                          subtitle: 'Mapa interactivo y búsqueda',
                          onTap: () {
                            Navigator.pop(context);
                            ref.read(userRoleStateProvider.notifier).setRole(UserRole.vehicleOwner);
                            context.go('/home');
                          },
                        ),
                        const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5EA), indent: 54, endIndent: 12),
                        _buildAppleMenuItem(
                          context: context,
                          icon: Icons.calendar_month_rounded,
                          iconColor: const Color(0xFFFF9500), // Apple Orange
                          title: 'Mis Reservas',
                          subtitle: 'Activas e historial',
                          badge: '1 activa',
                          badgeBgColor: const Color(0xFFFFF3E0),
                          badgeTextColor: const Color(0xFFE65100),
                          onTap: () {
                            Navigator.pop(context);
                            ref.read(userRoleStateProvider.notifier).setRole(UserRole.vehicleOwner);
                            context.go('/my-reservations');
                          },
                        ),
                        const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5EA), indent: 54, endIndent: 12),
                        _buildAppleMenuItem(
                          context: context,
                          icon: Icons.directions_car_rounded,
                          iconColor: const Color(0xFF34C759), // Apple Green
                          title: 'Mis Vehículos',
                          subtitle: 'Placas y categorías',
                          badge: '2 autos',
                          badgeBgColor: const Color(0xFFF2F2F7),
                          badgeTextColor: const Color(0xFF636366),
                          onTap: () {
                            Navigator.pop(context);
                            ref.read(userRoleStateProvider.notifier).setRole(UserRole.vehicleOwner);
                            context.go('/vehicles');
                          },
                        ),
                        const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5EA), indent: 54, endIndent: 12),
                        _buildAppleMenuItem(
                          context: context,
                          icon: Icons.credit_card_rounded,
                          iconColor: const Color(0xFF5856D6), // Apple Indigo
                          title: 'Pagos y Billetera',
                          subtitle: 'Saldo prepago y métodos',
                          onTap: () {
                            Navigator.pop(context);
                            context.go('/payments');
                          },
                        ),
                        const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5EA), indent: 54, endIndent: 12),
                        _buildAppleMenuItem(
                          context: context,
                          icon: Icons.notifications_rounded,
                          iconColor: const Color(0xFFFF3B30), // Apple Red
                          title: 'Alertas y Mensajes',
                          subtitle: 'Novedades y avisos',
                          badge: '3 nuevas',
                          badgeBgColor: const Color(0xFFFF3B30),
                          badgeTextColor: Colors.white,
                          onTap: () {
                            Navigator.pop(context);
                            context.go('/alerts');
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3. Security & Access Group (iOS Style)
                  const Padding(
                    padding: EdgeInsets.only(left: 8, bottom: 8),
                    child: Text(
                      'SEGURIDAD Y ACCESO',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8E8E93),
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0x0A000000), width: 0.8),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x08000000),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isAuth ? const Color(0xFF34C759) : const Color(0xFF1C1C1E),
                                borderRadius: BorderRadius.circular(8.5),
                              ),
                              child: Icon(
                                isAuth ? Icons.verified_user_rounded : Icons.lock_outline_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isAuth ? 'Sesión Protegida' : 'Acceso Seguro',
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1C1C1E),
                                    ),
                                  ),
                                  Text(
                                    isAuth ? 'Datos sincronizados en tiempo real' : 'Sincroniza tus reservas y vehículos',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF8E8E93),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (!isAuth) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1C1C1E),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 11),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.login_rounded, size: 15),
                                  label: const Text(
                                    'Iniciar sesión',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    context.push('/login');
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: const Color(0xFF1C1C1E),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 11),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.person_add_rounded, size: 15),
                                  label: const Text(
                                    'Registrarse',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    context.push('/register');
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 4. Apple iOS Style Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0x0F000000), width: 0.5)),
              ),
              child: isAuth
                  ? InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () async {
                        Navigator.pop(context);
                        try {
                          await ref.read(signOutUseCaseProvider).execute();
                        } catch (_) {}
                        ref.read(userRoleStateProvider.notifier).setRole(UserRole.guest);
                        if (context.mounted) {
                          context.go('/home');
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                        child: Row(
                          children: [
                            Icon(Icons.logout_rounded, color: Color(0xFFFF3B30), size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Cerrar sesión',
                              style: TextStyle(
                                color: Color(0xFFFF3B30),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Spacer(),
                            Text(
                              'v1.0',
                              style: TextStyle(
                                color: Color(0xFF8E8E93),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: Color(0xFF8E8E93), size: 16),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Modo Exploración',
                              style: TextStyle(
                                color: Color(0xFF8E8E93),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              context.push('/login');
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              child: Text(
                                'Entrar',
                                style: TextStyle(
                                  color: Color(0xFF007AFF),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
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

  Widget _buildAppleMenuItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    String? badge,
    Color? badgeBgColor,
    Color? badgeTextColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: const Color(0x0A000000),
        highlightColor: const Color(0x05000000),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(7.5),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: Colors.white, size: 17),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C1C1E),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                  ],
                ),
              ),
              if (badge != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: badgeBgColor ?? const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: badgeTextColor ?? const Color(0xFF1C1C1E),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFC7C7CC), size: 18),
            ],
          ),
        ),
      ),
    );
  }

  String _getRoleBadgeLabel(UserRole role) {
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
