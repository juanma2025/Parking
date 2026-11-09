import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/utils/motion_utils.dart';
import '../../domain/entities/user_role.dart';
import '../auth/auth_providers.dart';
import '../owner/calendar_provider.dart';
import '../owner/spaces_provider.dart';
import '../payments/payments_provider.dart';
import '../reservations/reservations_provider.dart';
import '../shared/app_card.dart';
import '../shared/app_drawer.dart';
import '../shared/avatar_button.dart';
import '../shared/pill_button.dart';
import '../shared/section_label.dart';
import '../shared/status_pill.dart';
import '../vehicles/vehicles_provider.dart';
import 'user_profile_provider.dart';

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
    final userProfile = ref.watch(userProfileProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOwner = role == UserRole.parkingOwner;
    final parkingConfig = ref.watch(ownerParkingConfigProvider);
    final ownerSpaces = ref.watch(parkingSpacesProvider);
    final ownerAvailableSpaces = ref.watch(availableSpacesCountProvider);
    final ownerOccupiedSpaces = ref.watch(occupiedSpacesCountProvider);
    final ownerCalendar = ref.watch(ownerCalendarProvider);
    final ownerRevenueToday = ref.watch(totalRevenueTodayProvider);
    final String formattedOwnerRevenue = ownerRevenueToday >= 1000
        ? '\$${(ownerRevenueToday / 1000).round()}K'
        : '\$${ownerRevenueToday.toInt()}';

    final String userName;
    final String userEmail;
    final String initialLetter;
    final String? avatarUrl = userProfile.avatarUrl ?? (isAuth ? profileAsync.value?.avatarUrl : null);

    if (isAuth && user != null) {
      final profileName = userProfile.fullName.isNotEmpty
          ? userProfile.fullName
          : profileAsync.value?.fullName;
      final metaName = user.userMetadata?['full_name'] as String?;
      userName = (profileName != null && profileName.trim().isNotEmpty)
          ? profileName.trim()
          : (metaName != null && metaName.trim().isNotEmpty)
              ? metaName.trim()
              : (user.email?.split('@').first ?? 'Conductor');
      userEmail = user.email ?? 'Sin correo vinculado';
      initialLetter = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
    } else {
      userName = userProfile.fullName.isNotEmpty ? userProfile.fullName : 'Modo Invitado';
      userEmail = 'Inicia sesión para sincronizar tus datos';
      initialLetter = userName.isNotEmpty ? userName[0].toUpperCase() : 'I';
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
                            avatarUrl: avatarUrl,
                            initials: initialLetter,
                            onTap: () => _showEditProfileModal(context, ref, isDark, userProfile),
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
                          GestureDetector(
                            onTap: () => _showEditProfileModal(context, ref, isDark, userProfile),
                            child: Stack(
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.white, width: 3),
                                  ),
                                  child: ClipOval(
                                    child: avatarUrl != null && avatarUrl.isNotEmpty
                                        ? (avatarUrl.startsWith('data:image')
                                            ? Image.memory(
                                                base64Decode(avatarUrl.split(',').last),
                                                width: 64,
                                                height: 64,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, _, _) => _buildAvatarFallback(initialLetter, isAuth),
                                              )
                                            : Image.network(
                                                avatarUrl,
                                                width: 64,
                                                height: 64,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, _, _) => _buildAvatarFallback(initialLetter, isAuth),
                                              ))
                                        : _buildAvatarFallback(initialLetter, isAuth),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.darkCard, width: 2),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
                                      size: 12,
                                      color: AppColors.darkCard,
                                    ),
                                  ),
                                ),
                              ],
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
                                Row(
                                  children: [
                                    StatusPill(
                                      text: isAuth
                                          ? (role == UserRole.parkingOwner ? 'PROPIETARIO VERIFICADO ★' : 'VERIFICADO RUNT ★')
                                          : 'MODO INVITADO',
                                      backgroundColor: const Color(0xFF333333),
                                      textColor: isAuth ? AppColors.secondary : Colors.white70,
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () => _showEditProfileModal(context, ref, isDark, userProfile),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withAlpha(25),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: Colors.white24, width: 0.8),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.edit_outlined, size: 11, color: Colors.white70),
                                            SizedBox(width: 4),
                                            Text(
                                              'Editar',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
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
                          children: isOwner
                              ? [
                                  _buildStatItem('${ownerSpaces.length}', 'CUPOS TOTALES'),
                                  Container(width: 1, height: 26, color: Colors.white12),
                                  _buildStatItem('${ownerCalendar.length}', 'RESERVAS'),
                                  Container(width: 1, height: 26, color: Colors.white12),
                                  _buildStatItem(formattedOwnerRevenue, 'INGRESOS HOY'),
                                ]
                              : [
                                  _buildStatItem('${activeReservations.length}', 'RESERVAS'),
                                  Container(width: 1, height: 26, color: Colors.white12),
                                  _buildStatItem('${vehicles.length}', 'VEHÍCULOS'),
                                  Container(width: 1, height: 26, color: Colors.white12),
                                  _buildStatItem(isAuth ? 'ACTIVO' : '\$0', 'ESTADO'),
                                ],
                        ),
                      ),
                    ],
                  ),
                ),
                index: 1,
              ),
              const SizedBox(height: 20),

              if (isOwner) ...[
                // ============================================================
                // PANEL DIFERENCIADO PARA PROPIETARIO DE PARQUEADERO
                // ============================================================
                SectionLabel(
                  'MI PARQUEADERO Y OPERACIÓN',
                  color: isDark ? AppColors.secondary : null,
                ),
                const SizedBox(height: 10),
                MotionUtils.staggerEntrance(
                  AppCard(
                    variant: AppCardVariant.white,
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withAlpha(isDark ? 65 : 50),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.local_parking_rounded,
                                color: AppColors.secondary,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    parkingConfig.name,
                                    style: AppTypography.title.copyWith(
                                      fontSize: 16,
                                      color: isDark ? AppColors.white : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${parkingConfig.address} • ${parkingConfig.openingHours}',
                                    style: AppTypography.caption.copyWith(
                                      color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildCardStat('LIBRES', '$ownerAvailableSpaces', isLight: isDark, highlight: true),
                              Container(width: 1, height: 22, color: isDark ? Colors.white12 : Colors.black12),
                              _buildCardStat('OCUPADOS', '$ownerOccupiedSpaces', isLight: isDark),
                              Container(width: 1, height: 22, color: isDark ? Colors.white12 : Colors.black12),
                              _buildCardStat('TARIFA HORA', '\$${parkingConfig.carHourlyRate.toInt()}', isLight: isDark),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: PillButton(
                                text: 'Editar Parqueadero',
                                variant: PillButtonVariant.dark,
                                onPressed: () => _showEditGarageConfigModal(context, ref, isDark, parkingConfig),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: PillButton(
                                text: 'Gestionar Cupos',
                                variant: PillButtonVariant.primary,
                                onPressed: () => context.go('/owner-spaces'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  index: 2,
                ),
                const SizedBox(height: 20),

                SectionLabel(
                  'GESTIÓN DE PARQUEADERO Y CUENTA',
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
                          Icons.storefront_rounded,
                          'Configuración de mi Parqueadero',
                          '${parkingConfig.name} • ${ownerSpaces.length} cupos configurados',
                          () => _showEditGarageConfigModal(context, ref, isDark, parkingConfig),
                          isDark: isDark,
                        ),
                        Divider(height: 1, color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                        _buildProfileOption(
                          Icons.grid_view_rounded,
                          'Espacios y Tarifas en Vivo',
                          '$ownerAvailableSpaces libres • \$${parkingConfig.carHourlyRate.toInt()}/h carros • \$${parkingConfig.motoHourlyRate.toInt()}/h motos',
                          () => context.go('/owner-spaces'),
                          isDark: isDark,
                        ),
                        Divider(height: 1, color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                        _buildProfileOption(
                          Icons.calendar_month_rounded,
                          'Agenda de Reservas de Clientes',
                          ownerCalendar.isEmpty
                              ? 'Aún no tienes reservas registradas'
                              : '${ownerCalendar.length} reserva(s) en agenda',
                          () => context.go('/owner-reservations'),
                          isDark: isDark,
                        ),
                        Divider(height: 1, color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                        _buildProfileOption(
                          Icons.point_of_sale_rounded,
                          'Control de Taquilla y Recaudo',
                          'Cobros en efectivo, Nequi y QR presencial',
                          () => context.go('/payments'),
                          isDark: isDark,
                        ),
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
                        _buildProfileOption(
                          Icons.notifications_active_rounded,
                          'Alertas de Operación',
                          'Avisos de llegada y ocupación',
                          () => context.go('/alerts'),
                          isDark: isDark,
                        ),
                        Divider(height: 1, color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                        _buildProfileOption(
                          Icons.security_rounded,
                          'Seguridad y Clave',
                          'Protección de cuenta de anfitrión',
                          () => _showSecurityAndPasswordModal(context, isDark),
                          isDark: isDark,
                        ),
                        Divider(height: 1, color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                        _buildProfileOption(
                          Icons.support_agent_rounded,
                          'Soporte para Anfitriones',
                          'Atención prioritaria 24/7 en Pasto',
                          () => _showSupportModal(context, isDark),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  index: 3,
                ),
              ] else ...[
                // ============================================================
                // PANEL PARA CONDUCTOR
                // ============================================================
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
                        _buildProfileOption(Icons.security_rounded, 'Seguridad y Clave', 'Protección activa', () => _showSecurityAndPasswordModal(context, isDark), isDark: isDark),
                        Divider(height: 1, color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                        _buildProfileOption(Icons.help_outline_rounded, 'Soporte y Ayuda', 'Atención 24/7', () => _showSupportModal(context, isDark), isDark: isDark),
                      ],
                    ),
                  ),
                  index: 3,
                ),
              ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkCard : AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black26,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Código de Acceso Activo',
                style: AppTypography.title.copyWith(
                  color: isDark ? AppColors.white : AppColors.darkCard,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Presenta este código en la entrada o salida del parqueadero',
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(
                  color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.secondary.withAlpha(100),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.qr_code_2_rounded,
                  size: 160,
                  color: AppColors.darkCard,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'ID: $code',
                style: AppTypography.bodyBold.copyWith(
                  color: isDark ? AppColors.white : AppColors.darkCard,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
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

  Widget _buildAvatarFallback(String initialLetter, bool isAuth) {
    return Container(
      color: AppColors.secondary,
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
    );
  }

  void _showEditProfileModal(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    UserProfileState userProfile,
  ) {
    final nameCtrl = TextEditingController(text: userProfile.fullName);
    final phoneCtrl = TextEditingController(text: userProfile.phone);
    final urlCtrl = TextEditingController(text: userProfile.avatarUrl ?? '');
    String? selectedAvatar = userProfile.avatarUrl;

    final presetAvatars = [
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200',
      'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=200',
    ];

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkCard : AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (modalContext, setModalState) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.black26,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Editar Perfil y Foto',
                      style: AppTypography.title.copyWith(
                        color: isDark ? AppColors.white : AppColors.darkCard,
                        fontSize: 19,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tu foto e información se conservarán aunque cierres sesión.',
                      style: AppTypography.caption.copyWith(
                        color: isDark ? Colors.white60 : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 18),

                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primary, width: 3),
                            ),
                            child: ClipOval(
                              child: (selectedAvatar != null && selectedAvatar!.isNotEmpty)
                                  ? (selectedAvatar!.startsWith('data:image')
                                      ? Image.memory(
                                          base64Decode(selectedAvatar!.split(',').last),
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) => const Icon(Icons.person, size: 40),
                                        )
                                      : Image.network(
                                          selectedAvatar!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) => const Icon(Icons.person, size: 40),
                                        ))
                                  : const Icon(Icons.person, size: 40),
                            ),
                          ),
                          if (selectedAvatar != null && selectedAvatar!.isNotEmpty)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    selectedAvatar = null;
                                    urlCtrl.clear();
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.error,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Fotos recomendadas (Toca para elegir):',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white70 : AppColors.darkCard,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final preset in presetAvatars)
                            GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  selectedAvatar = preset;
                                  urlCtrl.text = preset;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selectedAvatar == preset ? AppColors.primary : Colors.transparent,
                                    width: 2.5,
                                  ),
                                ),
                                child: ClipOval(
                                  child: Image.network(
                                    preset,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => const Icon(Icons.person, size: 24),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: urlCtrl,
                      style: TextStyle(color: isDark ? AppColors.white : AppColors.darkCard),
                      onChanged: (val) {
                        setModalState(() {
                          selectedAvatar = val.trim().isNotEmpty ? val.trim() : null;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'O pega la URL de una foto',
                        hintText: 'https://ejemplo.com/mifoto.jpg',
                        prefixIcon: const Icon(Icons.link_rounded, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: nameCtrl,
                      style: TextStyle(color: isDark ? AppColors.white : AppColors.darkCard),
                      decoration: InputDecoration(
                        labelText: 'Nombre completo',
                        prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(color: isDark ? AppColors.white : AppColors.darkCard),
                      decoration: InputDecoration(
                        labelText: 'Teléfono / WhatsApp',
                        prefixIcon: const Icon(Icons.phone_iphone_rounded, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.darkCard,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          final newName = nameCtrl.text.trim();
                          final newPhone = phoneCtrl.text.trim();
                          final newAvatar = selectedAvatar?.trim();

                          ref.read(userProfileProvider.notifier).updateProfile(
                                fullName: newName.isNotEmpty ? newName : null,
                                phone: newPhone.isNotEmpty ? newPhone : null,
                                avatarUrl: newAvatar,
                              );

                          Navigator.pop(ctx);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: AppColors.darkCard,
                              content: Text(
                                '✓ Perfil y foto actualizados. Tus datos se conservarán siempre.',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Guardar Cambios',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditGarageConfigModal(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    OwnerParkingConfig currentConfig,
  ) {
    final nameCtrl = TextEditingController(text: currentConfig.name);
    final addressCtrl = TextEditingController(text: currentConfig.address);
    final carSpacesCtrl = TextEditingController(text: '${currentConfig.carSpaces}');
    final motoSpacesCtrl = TextEditingController(text: '${currentConfig.motoSpaces}');
    final carRateCtrl = TextEditingController(text: '${currentConfig.carHourlyRate.toInt()}');
    final motoRateCtrl = TextEditingController(text: '${currentConfig.motoHourlyRate.toInt()}');
    bool is24Hours = currentConfig.openTime.contains('12:00 AM') ||
        currentConfig.closeTime.contains('11:59 PM') ||
        currentConfig.openingHours.contains('24');

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkCard : AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (modalContext, setModalState) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.black26,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Configurar Parqueadero y Cupos',
                      style: AppTypography.title.copyWith(
                        color: isDark ? AppColors.white : AppColors.darkCard,
                        fontSize: 19,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Actualiza tus cupos, tarifas y dirección en Pasto. Se reflejarán inmediatamente en el mapa y sugerencias.',
                      style: AppTypography.caption.copyWith(
                        color: isDark ? Colors.white60 : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: nameCtrl,
                      style: TextStyle(color: isDark ? AppColors.white : AppColors.darkCard),
                      decoration: InputDecoration(
                        labelText: 'Nombre del parqueadero',
                        prefixIcon: const Icon(Icons.local_parking_rounded, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: addressCtrl,
                      style: TextStyle(color: isDark ? AppColors.white : AppColors.darkCard),
                      decoration: InputDecoration(
                        labelText: 'Dirección en Pasto',
                        prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: carSpacesCtrl,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: isDark ? AppColors.white : AppColors.darkCard),
                            decoration: InputDecoration(
                              labelText: 'Cupos Carro',
                              prefixIcon: const Icon(Icons.directions_car_rounded, size: 20),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: motoSpacesCtrl,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: isDark ? AppColors.white : AppColors.darkCard),
                            decoration: InputDecoration(
                              labelText: 'Cupos Moto',
                              prefixIcon: const Icon(Icons.two_wheeler_rounded, size: 20),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: carRateCtrl,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: isDark ? AppColors.white : AppColors.darkCard),
                            decoration: InputDecoration(
                              labelText: 'Tarifa Carro / h',
                              prefixIcon: const Icon(Icons.attach_money_rounded, size: 20),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: motoRateCtrl,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: isDark ? AppColors.white : AppColors.darkCard),
                            decoration: InputDecoration(
                              labelText: 'Tarifa Moto / h',
                              prefixIcon: const Icon(Icons.attach_money_rounded, size: 20),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Atención 24 Horas',
                        style: AppTypography.bodyBold.copyWith(
                          color: isDark ? AppColors.white : AppColors.darkCard,
                        ),
                      ),
                      subtitle: Text(
                        is24Hours ? 'Abierto las 24 horas' : 'Horario diurno (6:00 AM - 10:00 PM)',
                        style: AppTypography.caption.copyWith(
                          color: isDark ? Colors.white60 : AppColors.textSecondaryLight,
                        ),
                      ),
                      value: is24Hours,
                      activeThumbColor: AppColors.secondary,
                      onChanged: (val) => setModalState(() => is24Hours = val),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.darkCard,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          final name = nameCtrl.text.trim().isNotEmpty
                              ? nameCtrl.text.trim()
                              : currentConfig.name;
                          final address = addressCtrl.text.trim().isNotEmpty
                              ? addressCtrl.text.trim()
                              : currentConfig.address;
                          final carSpaces = int.tryParse(carSpacesCtrl.text.trim()) ?? currentConfig.carSpaces;
                          final motoSpaces = int.tryParse(motoSpacesCtrl.text.trim()) ?? currentConfig.motoSpaces;
                          final carRate = double.tryParse(
                                carRateCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''),
                              ) ??
                              currentConfig.carHourlyRate;
                          final motoRate = double.tryParse(
                                motoRateCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''),
                              ) ??
                              currentConfig.motoHourlyRate;

                          ref.read(ownerParkingConfigProvider.notifier).configureParkingLot(
                                name: name,
                                address: address,
                                openTime: is24Hours ? '12:00 AM' : '06:00 AM',
                                closeTime: is24Hours ? '11:59 PM' : '10:00 PM',
                                carSpaces: carSpaces,
                                motoSpaces: motoSpaces,
                                carHourlyRate: carRate,
                                motoHourlyRate: motoRate,
                              );

                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.darkCard,
                              content: Text(
                                '✓ Parqueadero "$name" actualizado (${carSpaces + motoSpaces} cupos).',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Guardar Configuración',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSecurityAndPasswordModal(BuildContext context, bool isDark) {
    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkCard : AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (modalContext, setModalState) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.black26,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(50),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.lock_reset_rounded, color: AppColors.secondary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Seguridad y Clave',
                                style: AppTypography.title.copyWith(
                                  color: isDark ? AppColors.white : AppColors.darkCard,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                'Cambia tu contraseña de acceso',
                                style: AppTypography.caption.copyWith(
                                  color: isDark ? Colors.white60 : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    TextField(
                      controller: currentPassCtrl,
                      obscureText: true,
                      style: TextStyle(color: isDark ? AppColors.white : AppColors.darkCard),
                      decoration: InputDecoration(
                        labelText: 'Contraseña Actual',
                        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: newPassCtrl,
                      obscureText: true,
                      style: TextStyle(color: isDark ? AppColors.white : AppColors.darkCard),
                      decoration: InputDecoration(
                        labelText: 'Nueva Contraseña (mínimo 8 caracteres)',
                        prefixIcon: const Icon(Icons.key_rounded, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextField(
                      controller: confirmPassCtrl,
                      obscureText: true,
                      style: TextStyle(color: isDark ? AppColors.white : AppColors.darkCard),
                      decoration: InputDecoration(
                        labelText: 'Confirmar Nueva Contraseña',
                        prefixIcon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.darkCard,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          final currentPass = currentPassCtrl.text.trim();
                          final newPass = newPassCtrl.text.trim();
                          final confirmPass = confirmPassCtrl.text.trim();

                          if (currentPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Por favor completa todos los campos de contraseña.')),
                            );
                            return;
                          }

                          if (newPass.length < 8) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('La nueva contraseña debe tener al menos 8 caracteres.')),
                            );
                            return;
                          }

                          if (newPass != confirmPass) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('La nueva contraseña y su confirmación no coinciden.')),
                            );
                            return;
                          }

                          // Alerta de confirmación para conservar la nueva clave y eliminar la antigua
                          showDialog(
                            context: context,
                            builder: (dialogCtx) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              title: const Row(
                                children: [
                                  Icon(Icons.security_update_good_rounded, color: AppColors.secondary, size: 24),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '¿Confirmar cambio de clave?',
                                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              content: const Text(
                                'Se eliminará tu contraseña antigua de acceso y se conservará la nueva clave que acabas de definir. ¿Deseas aplicar el cambio?',
                                style: TextStyle(fontSize: 14, height: 1.4),
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
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: AppColors.darkCard,
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(dialogCtx);
                                          Navigator.pop(ctx);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              backgroundColor: AppColors.darkCard,
                                              content: Text(
                                                '✓ Contraseña actualizada con éxito. Tu nueva clave está activa.',
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          'Conservar nueva clave',
                                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Center(
                                        child: TextButton(
                                          onPressed: () => Navigator.pop(dialogCtx),
                                          child: Text(
                                            'Mantener contraseña anterior',
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
                            ),
                          );
                        },
                        child: const Text(
                          'Actualizar Contraseña',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSupportModal(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkCard : AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black26,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF34C759).withAlpha(45),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.support_agent_rounded, color: Color(0xFF34C759), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Soporte y Ayuda 24/7',
                          style: AppTypography.title.copyWith(
                            color: isDark ? AppColors.white : AppColors.darkCard,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Atención al usuario en San Juan de Pasto',
                          style: AppTypography.caption.copyWith(
                            color: isDark ? Colors.white60 : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildSupportChannel(
                icon: Icons.chat_bubble_rounded,
                iconColor: const Color(0xFF34C759),
                title: 'WhatsApp Soporte Pasto',
                subtitle: '+57 312 890 1234 • Respuesta en menos de 5 min',
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Conectando con asesor de soporte en WhatsApp...')),
                  );
                },
                isDark: isDark,
              ),
              const SizedBox(height: 10),

              _buildSupportChannel(
                icon: Icons.phone_in_talk_rounded,
                iconColor: const Color(0xFF007AFF),
                title: 'Línea de Atención Telefónica',
                subtitle: '(602) 720 0000 • Central de operaciones Pasto',
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Llamando a la central de atención en Pasto...')),
                  );
                },
                isDark: isDark,
              ),
              const SizedBox(height: 10),

              _buildSupportChannel(
                icon: Icons.email_rounded,
                iconColor: const Color(0xFFFF9500),
                title: 'Correo Electrónico Oficial',
                subtitle: 'soporte@parkingpasto.com • PQRS y sugerencias',
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Correo de soporte: soporte@parkingpasto.com')),
                  );
                },
                isDark: isDark,
              ),
              const SizedBox(height: 10),

              _buildSupportChannel(
                icon: Icons.help_center_rounded,
                iconColor: const Color(0xFF5856D6),
                title: 'Preguntas Frecuentes',
                subtitle: 'Guía de reservas, pases QR y tarifas en COP',
                onTap: () {
                  Navigator.pop(ctx);
                  context.go('/home');
                },
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportChannel({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withAlpha(isDark ? 50 : 35),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 11.5,
                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.white38 : Colors.black26,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

