import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/utils/motion_utils.dart';
import '../../domain/entities/user_role.dart';
import '../auth/auth_providers.dart';
import '../owner/spaces_provider.dart';
import '../reservations/reservations_provider.dart';
import '../shared/app_card.dart';
import '../shared/app_drawer.dart';
import '../shared/avatar_button.dart';
import '../shared/pill_button.dart';
import '../shared/section_label.dart';
import '../shared/status_pill.dart';
import '../vehicles/vehicles_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuth = ref.watch(isAuthenticatedProvider);
    final user = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(currentProfileProvider);
    final role = ref.watch(currentUserRoleProvider);
    final themeMode = ref.watch(themeModeProvider);
    final activeReservations = ref.watch(userReservationsProvider);
    final vehicles = ref.watch(userVehiclesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
      initialLetter = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
    } else {
      userName = 'Modo Invitado';
      userEmail = 'Inicia sesión para sincronizar tus datos';
      initialLetter = 'I';
    }

    return Scaffold(
      drawer: isAuth ? const AppDrawer() : null,
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(isDark ? 30 : 8),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: isAuth
                          ? Builder(
                              builder: (ctx) => IconButton(
                                icon: Icon(Icons.menu_rounded, color: isDark ? AppColors.white : AppColors.darkCard),
                                onPressed: () => Scaffold.of(ctx).openDrawer(),
                              ),
                            )
                          : IconButton(
                              icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? AppColors.white : AppColors.darkCard, size: 18),
                              onPressed: () => context.go('/home'),
                            ),
                    ),
                    Text(
                      'Mi Perfil',
                      style: AppTypography.title.copyWith(
                        fontSize: 18,
                        color: isDark ? AppColors.white : AppColors.darkCard,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
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
                          child: IconButton(
                            tooltip: themeMode == ThemeMode.system
                                ? 'Tema: Adaptado al dispositivo'
                                : (themeMode == ThemeMode.dark ? 'Tema: Oscuro' : 'Tema: Claro'),
                            icon: Icon(
                              themeMode == ThemeMode.system
                                  ? Icons.brightness_auto_rounded
                                  : (themeMode == ThemeMode.dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
                              color: AppColors.secondary,
                              size: 20,
                            ),
                            onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Hero(
                          tag: 'user-avatar-hero',
                          child: AvatarButton(
                            initials: initialLetter,
                            onTap: () {},
                          ),
                        ),
                      ],
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
                            child: isAuth
                                ? Text(
                                    initialLetter,
                                    style: const TextStyle(
                                      color: AppColors.darkCard,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )
                                : const Icon(
                                    Icons.person_outline_rounded,
                                    color: AppColors.darkCard,
                                    size: 32,
                                  ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(_getTimeIcon(), size: 13, color: AppColors.secondary),
                                    const SizedBox(width: 5),
                                    Text(
                                      '¡${_getTimeGreeting().toUpperCase()}!',
                                      style: const TextStyle(
                                        fontFamily: AppTypography.fontFamily,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.secondary,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
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
                                StatusPill(
                                  text: isAuth
                                      ? (role == UserRole.parkingOwner ? 'PROPIETARIO VERIFICADO ★' : 'VERIFICADO RUNT ★')
                                      : 'MODO INVITADO',
                                  backgroundColor: const Color(0xFF333333),
                                  textColor: isAuth ? AppColors.secondary : Colors.white70,
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
                            _buildStatItem(isAuth ? '28' : '0', 'RESERVAS'),
                            Container(width: 1, height: 26, color: Colors.white12),
                            _buildStatItem(isAuth ? '64h' : '0h', 'PARQUEADAS'),
                            Container(width: 1, height: 26, color: Colors.white12),
                            _buildStatItem(isAuth ? '\$42.5K' : '\$0', 'AHORRO'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                index: 1,
              ),
              const SizedBox(height: 20),

              // Active Reservation Section (with Cancel Option)
              SectionLabel(
                'ESTANCIAS Y RESERVAS ACTIVAS',
                color: isDark ? AppColors.secondary : null,
              ),
              const SizedBox(height: 10),
              if (activeReservations.isNotEmpty) ...[
                for (final res in activeReservations)
                  MotionUtils.staggerEntrance(
                    _buildActiveReservationCard(context, ref, res, isDark),
                    index: 2,
                  ),
              ] else
                MotionUtils.staggerEntrance(
                  AppCard(
                    variant: AppCardVariant.white,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withAlpha(isDark ? 60 : 45),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.confirmation_number_outlined,
                            color: AppColors.secondary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sin reservas activas',
                                style: AppTypography.bodyBold.copyWith(
                                  fontSize: 14,
                                  color: isDark ? AppColors.white : const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'No tienes estancias en curso en Pasto.',
                                style: AppTypography.caption.copyWith(
                                  color: isDark ? Colors.white60 : AppColors.textSecondaryLight,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/home'),
                          child: Text(
                            'Reservar',
                            style: TextStyle(
                              color: isDark ? AppColors.secondary : AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  index: 2,
                ),

              const SizedBox(height: 20),

              // Menu Settings (White Card)
              SectionLabel(
                'PREFERENCIAS Y CUENTA',
                color: isDark ? AppColors.secondary : null,
              ),
              const SizedBox(height: 10),
              MotionUtils.staggerEntrance(
                AppCard(
                  variant: AppCardVariant.white,
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      _buildProfileOption(
                        Icons.directions_car_rounded,
                        'Mis Vehículos',
                        '${vehicles.length} ${vehicles.length == 1 ? "registrado" : "registrados"}',
                        () => context.go('/vehicles'),
                        isDark: isDark,
                      ),
                      Divider(height: 1, color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                      _buildProfileOption(
                        Icons.confirmation_number_outlined,
                        'Mis Reservas',
                        activeReservations.isNotEmpty ? '${activeReservations.length} activa(s)' : 'Ver historial y pases',
                        () => context.go('/my-reservations'),
                        isDark: isDark,
                      ),
                      Divider(height: 1, color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                      _buildProfileOption(Icons.qr_code_2_rounded, 'Pases y Pagos en Sitio', 'Pago presencial QR', () => context.go('/payments'), isDark: isDark),
                      Divider(height: 1, color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                      _buildProfileOption(
                        themeMode == ThemeMode.system
                            ? Icons.brightness_auto_rounded
                            : (themeMode == ThemeMode.dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
                        'Tema de la Aplicación',
                        themeMode == ThemeMode.system
                            ? 'Adaptado al dispositivo'
                            : (themeMode == ThemeMode.dark ? 'Modo Oscuro' : 'Modo Claro'),
                        () => ref.read(themeModeProvider.notifier).toggleTheme(),
                        isDark: isDark,
                      ),
                      Divider(height: 1, color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                      _buildProfileOption(Icons.notifications_rounded, 'Notificaciones', 'SMS y Push activadas', () => context.go('/alerts'), isDark: isDark),
                      Divider(height: 1, color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                      _buildProfileOption(Icons.security_rounded, 'Seguridad y Clave', 'Protección activa', () {}, isDark: isDark),
                      Divider(height: 1, color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                      _buildProfileOption(Icons.help_outline_rounded, 'Soporte y Ayuda', 'Atención 24/7', () {}, isDark: isDark),
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
                    if (!isAuth)
                      Row(
                        children: [
                          Expanded(
                            child: PillButton(
                              text: 'Iniciar sesión',
                              variant: PillButtonVariant.dark,
                              onPressed: () {
                                context.push('/login');
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: PillButton(
                              text: 'Registrarse',
                              variant: PillButtonVariant.primary,
                              onPressed: () {
                                context.push('/register');
                              },
                            ),
                          ),
                        ],
                      )
                    else
                      GestureDetector(
                        onTap: () async {
                          try {
                            await ref.read(signOutUseCaseProvider).execute();
                          } catch (_) {}
                          ref.read(userRoleStateProvider.notifier).setRole(UserRole.guest);
                          if (context.mounted) {
                            context.go('/home');
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

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Buenos días';
    } else if (hour >= 12 && hour < 19) {
      return 'Buenas tardes';
    } else {
      return 'Buenas noches';
    }
  }

  IconData _getTimeIcon() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return Icons.wb_sunny_rounded;
    } else if (hour >= 12 && hour < 19) {
      return Icons.wb_twilight_rounded;
    } else {
      return Icons.nightlight_round;
    }
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

  Widget _buildProfileOption(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    required bool isDark,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.secondary.withAlpha(isDark ? 60 : 45),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: isDark ? AppColors.secondary : AppColors.darkCard, size: 20),
      ),
      title: Text(
        title,
        style: AppTypography.bodyBold.copyWith(
          fontSize: 14,
          color: isDark ? AppColors.white : const Color(0xFF0F172A),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.caption.copyWith(
          color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
          fontSize: 11,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: isDark ? Colors.white38 : AppColors.textSecondaryLight,
        size: 20,
      ),
    );
  }

  Widget _buildActiveReservationCard(
    BuildContext context,
    WidgetRef ref,
    ActiveReservationItem item,
    bool isDark,
  ) {
    return AppCard(
      variant: AppCardVariant.dark,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusPill(
                text: item.statusText,
                backgroundColor: const Color(0xFF1B5E20),
                textColor: AppColors.white,
                dotColor: const Color(0xFF81C784),
              ),
              Text(
                item.spotNumber,
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.parkingLotName,
            style: AppTypography.title.copyWith(color: AppColors.white, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            item.address,
            style: AppTypography.caption.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF333333),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCardStat('VEHÍCULO', item.vehiclePlate, isLight: true),
                Container(width: 1, height: 24, color: Colors.white24),
                _buildCardStat('HORA ENTRADA', item.entryTime, isLight: true),
                Container(width: 1, height: 24, color: Colors.white24),
                _buildCardStat('TOTAL', item.formattedTotal, isLight: true, highlight: true),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: PillButton(
                  text: 'Ver pase QR',
                  variant: PillButtonVariant.primary,
                  onPressed: () => _showProfileQrModal(context, item.qrCode),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  key: Key('profile_cancel_res_${item.id}'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.cancel_outlined, size: 16),
                  label: const Text(
                    'Cancelar',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  onPressed: () => _confirmCancelReservation(context, ref, item),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showProfileQrModal(BuildContext context, String code) {
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
            Text('Código de Acceso Activo', style: AppTypography.title),
            const SizedBox(height: 8),
            Text('Presenta este código en la entrada o salida del parqueadero', style: AppTypography.body),
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

  void _confirmCancelReservation(
    BuildContext context,
    WidgetRef ref,
    ActiveReservationItem item,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
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
          '¿Deseas cancelar tu reserva en ${item.parkingLotName} (${item.spotNumber})?\n\nTu cupo será liberado inmediatamente para otros conductores y se anulará el pase de acceso generado.',
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
                        color: isDark ? AppColors.secondary : AppColors.darkCard,
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
      );
    },
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
}

