import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/utils/motion_utils.dart';
import '../../data/datasources/pasto_landmarks_data.dart';
import '../../domain/entities/domain_entities.dart';
import '../auth/auth_providers.dart';
import '../shared/animated_auth_actions.dart';
import '../shared/app_card.dart';
import '../shared/app_drawer.dart';
import '../shared/app_map.dart';
import '../shared/avatar_button.dart';
import '../shared/pill_button.dart';
import '../shared/status_pill.dart';
import '../shared/two_tone_title.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _parkingLots = [];
  bool _isLoading = true;
  String _userName = 'CONDUCTOR';
  int _selectedRoleTab = 0; // 0: Conductor, 1: Parqueadero

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final profile = await Supabase.instance.client
            .from('profiles')
            .select('full_name')
            .eq('id', user.id)
            .maybeSingle();

        if (profile != null && profile['full_name'] != null && (profile['full_name'] as String).isNotEmpty) {
          final fullName = profile['full_name'] as String;
          _userName = fullName.split(' ').first.toUpperCase();
        }
      }

      // Fetch active parking lots from Supabase or default to San Juan de Pasto lots
      final response = await Supabase.instance.client
          .from('parking_lots')
          .select()
          .eq('status', 'active')
          .limit(10);

      if (response.isNotEmpty) {
        _parkingLots = List<Map<String, dynamic>>.from(response);
      } else {
        _parkingLots = _getPastoDefaultParkingLots();
      }
      setState(() => _isLoading = false);
    } catch (_) {
      _parkingLots = _getPastoDefaultParkingLots();
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Map<String, dynamic>> _getPastoDefaultParkingLots() {
    return PastoDataService.getAllParkingLots().map((p) => {
      'id': p.id,
      'name': p.name,
      'address': p.address,
      'price_per_hour': p.pricePerHour,
      'car_spaces': p.carSpaces,
      'moto_spaces': p.motoSpaces,
      'distance': p.distanceMeters,
    }).toList();
  }

  String _getDisplayName(User? user, AsyncValue<Profile?> profileAsync) {
    final profileName = profileAsync.value?.fullName;
    if (profileName != null && profileName.trim().isNotEmpty) {
      return profileName.trim().split(' ').first.toUpperCase();
    }
    final metaName = user?.userMetadata?['full_name'] as String?;
    if (metaName != null && metaName.trim().isNotEmpty) {
      return metaName.trim().split(' ').first.toUpperCase();
    }
    if (user?.email != null && user!.email!.isNotEmpty) {
      return user.email!.split('@').first.toUpperCase();
    }
    return _userName;
  }

  String _getUserInitials(User? user, AsyncValue<Profile?> profileAsync) {
    final profileName = profileAsync.value?.fullName;
    if (profileName != null && profileName.trim().isNotEmpty) {
      return profileName.trim()[0].toUpperCase();
    }
    final metaName = user?.userMetadata?['full_name'] as String?;
    if (metaName != null && metaName.trim().isNotEmpty) {
      return metaName.trim()[0].toUpperCase();
    }
    if (user?.email != null && user!.email!.isNotEmpty) {
      return user.email![0].toUpperCase();
    }
    return 'C';
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

  Widget _buildThemeToggleButton(ThemeMode themeMode, bool isDark) {
    IconData icon;
    String tooltip;
    if (themeMode == ThemeMode.system) {
      icon = Icons.brightness_auto_rounded;
      tooltip = 'Tema: Adaptado al dispositivo';
    } else if (themeMode == ThemeMode.dark) {
      icon = Icons.dark_mode_rounded;
      tooltip = 'Tema: Oscuro';
    } else {
      icon = Icons.light_mode_rounded;
      tooltip = 'Tema: Claro';
    }

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 10),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 18,
        tooltip: tooltip,
        icon: Icon(icon, color: AppColors.secondary),
        onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAuth = ref.watch(isAuthenticatedProvider);
    final user = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(currentProfileProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: isAuth ? const AppDrawer() : null,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadInitialData,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top App Bar (Hamburger + Avatar if Auth; Logo Hero + AnimatedAuthActions if Unauth)
                MotionUtils.staggerEntrance(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (isAuth) ...[
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : AppColors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(8),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Builder(
                            builder: (scaffoldContext) => IconButton(
                              icon: Icon(Icons.menu_rounded, color: isDark ? AppColors.white : AppColors.darkCard),
                              onPressed: () {
                                Scaffold.of(scaffoldContext).openDrawer();
                              },
                            ),
                          ),
                        ),
                        Text(
                          'Explore Parking',
                          style: AppTypography.title.copyWith(fontSize: 18),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildThemeToggleButton(themeMode, isDark),
                            const SizedBox(width: 8),
                            Hero(
                              tag: 'user-avatar-hero',
                              child: AvatarButton(
                                initials: _getUserInitials(user, profileAsync),
                                onTap: () => context.go('/profile'),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        // Guest mode: Left brand (Logo + Name) & Right compact actions with Theme Toggle
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Hero(
                                tag: 'app-official-logo',
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.darkCard : AppColors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(10),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.asset(
                                      'assets/images/app_logo.png',
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.local_parking_rounded,
                                          color: AppColors.darkCard,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Explore Parking',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.title.copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildThemeToggleButton(themeMode, isDark),
                            const SizedBox(width: 6),
                            const AnimatedAuthActions(),
                          ],
                        ),
                      ],
                    ],
                  ),
                  index: 0,
                ),
                const SizedBox(height: 18),

                // 2. Animated Switcher between Landing View (Unauthenticated) & Dashboard View (Authenticated)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  switchInCurve: Curves.easeInOutCubic,
                  switchOutCurve: Curves.easeInOutCubic,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                  child: isAuth
                      ? _buildAuthenticatedContent(context, user, profileAsync)
                      : _buildLandingContent(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // AUTHENTICATED DASHBOARD: Map + Quick Pasto Chips + Search + Recommendations
  // ============================================================================
  Widget _buildAuthenticatedContent(
    BuildContext context,
    User? user,
    AsyncValue<Profile?> profileAsync,
  ) {
    return Column(
      key: const ValueKey('authenticated_content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Greeting & Title
        MotionUtils.staggerEntrance(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_getTimeIcon(), size: 14, color: AppColors.secondary),
                  const SizedBox(width: 6),
                  Text(
                    '¡${_getTimeGreeting().toUpperCase()}, ${_getDisplayName(user, profileAsync)}!',
                    style: AppTypography.sectionLabel.copyWith(
                      color: AppColors.secondary,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const TwoToneTitle(
                text: 'Encuentra tu ',
                highlightText: 'parqueadero',
              ),
            ],
          ),
          index: 1,
        ),
        const SizedBox(height: 18),

        // Pill Search Bar
        MotionUtils.staggerEntrance(
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(6),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: AppTypography.body,
                    decoration: InputDecoration(
                      hintText: 'Buscar por dirección o zona en Pasto...',
                      hintStyle: AppTypography.body.copyWith(
                        color: AppColors.textSecondaryLight.withAlpha(160),
                      ),
                      fillColor: Colors.transparent,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.mic_none_rounded, color: AppColors.textSecondaryLight),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          index: 2,
        ),
        const SizedBox(height: 18),

        // Landmarks Quick Access Bar (San Juan de Pasto)
        MotionUtils.staggerEntrance(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(
                    child: Text(
                      'PUNTOS CLAVE EN PASTO',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AppColors.secondary,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(45),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Toca para ver cupos',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkCard,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: PastoDataService.getLandmarks().map((landmark) {
                    final isMall = landmark.category == LandmarkCategory.shoppingMall;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: MotionUtils.pressable(
                        onTap: () => AppMap.showLandmarkDetails(context, landmark),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isMall ? AppColors.primary.withAlpha(120) : const Color(0xFFFF3B30).withAlpha(100),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(6),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                landmark.icon,
                                size: 15,
                                color: isMall ? AppColors.darkCard : const Color(0xFFFF3B30),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                landmark.shortName,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isMall ? AppColors.darkCard : const Color(0xFFC92A2A),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: isMall ? AppColors.primary : const Color(0xFFFFECEB),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${landmark.nearbyParkingLots.length} P',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: isMall ? AppColors.darkCard : const Color(0xFFFF3B30),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          index: 3,
        ),
        const SizedBox(height: 18),

        // OpenStreetMap View (San Juan de Pasto)
        MotionUtils.staggerEntrance(
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Container(
              height: 290,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.black.withAlpha(15), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const AppMap(
                height: 290,
                showControls: true,
              ),
            ),
          ),
          index: 4,
        ),
        const SizedBox(height: 24),

        // Recommended Parking Lots Cards
        MotionUtils.staggerEntrance(
          _buildRecommendationsSection(),
          index: 5,
        ),
        const SizedBox(height: 80), // Padding for BottomBar5
      ],
    );
  }

  // ============================================================================
  // UNAUTHENTICATED LANDING VIEW: Informative Platform Showcase
  // (No map, no bottom bar, only platform features, options and how it works)
  // ============================================================================
  Widget _buildLandingContent(BuildContext context) {
    return Column(
      key: const ValueKey('landing_content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Hero Header Badge & Title
        MotionUtils.staggerEntrance(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_getTimeIcon(), size: 14, color: AppColors.secondary),
                  const SizedBox(width: 6),
                  Text(
                    '¡${_getTimeGreeting().toUpperCase()}! • SAN JUAN DE PASTO',
                    style: const TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.secondary,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const StatusPill(
                text: 'SMART PARKING • PASTO',
                backgroundColor: Color(0xFFFFF2DF),
                textColor: Color(0xFFB46500),
                dotColor: AppColors.primary,
              ),
              const SizedBox(height: 10),
              const TwoToneTitle(
                text: 'Tu parqueadero en Pasto, ',
                highlightText: 'fácil y seguro',
              ),
              const SizedBox(height: 10),
              Text(
                'Conectamos conductores con parqueaderos verificados en tiempo real. Encuentra cupo rápido en zonas comerciales y médicas de San Juan de Pasto.',
                style: AppTypography.body.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withAlpha(200)
                      : AppColors.textSecondaryLight,
                  height: 1.45,
                ),
              ),
            ],
          ),
          index: 1,
        ),
        const SizedBox(height: 22),

        // 2. Section: ¿QUÉ OPCIONES TIENES? with Apple Segmented Control
        MotionUtils.staggerEntrance(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '¿QUÉ OPCIONES TIENES?',
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.textSecondaryLight,
                      fontSize: 11,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(40),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Elige tu perfil',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkCard,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Apple HIG Segmented Pill Selector
              Container(
                height: 44,
                padding: const EdgeInsets.all(3.5),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withAlpha(25), width: 1),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: MotionUtils.pressable(
                        onTap: () => setState(() => _selectedRoleTab = 0),
                        borderRadius: BorderRadius.circular(18),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeInOutCubic,
                          decoration: BoxDecoration(
                            color: _selectedRoleTab == 0 ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: _selectedRoleTab == 0
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withAlpha(80),
                                      blurRadius: 6,
                                      offset: const Offset(0, 1),
                                    )
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.directions_car_filled_rounded,
                                size: 15,
                                color: _selectedRoleTab == 0 ? AppColors.darkCard : Colors.white70,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Conductor',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: _selectedRoleTab == 0 ? AppColors.darkCard : Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: MotionUtils.pressable(
                        onTap: () => setState(() => _selectedRoleTab = 1),
                        borderRadius: BorderRadius.circular(18),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeInOutCubic,
                          decoration: BoxDecoration(
                            color: _selectedRoleTab == 1 ? AppColors.secondary : Colors.transparent,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: _selectedRoleTab == 1
                                ? [
                                    BoxShadow(
                                      color: AppColors.secondary.withAlpha(80),
                                      blurRadius: 6,
                                      offset: const Offset(0, 1),
                                    )
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_parking_rounded,
                                size: 15,
                                color: _selectedRoleTab == 1 ? AppColors.darkCard : Colors.white70,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Parqueadero',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: _selectedRoleTab == 1 ? AppColors.darkCard : Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Animated Profile Card
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                switchInCurve: Curves.easeInOutCubic,
                switchOutCurve: Curves.easeInOutCubic,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                child: _selectedRoleTab == 0
                    ? _buildConductorCard(context)
                    : _buildOwnerCard(context),
              ),
            ],
          ),
          index: 2,
        ),
        const SizedBox(height: 28),

        // 3. Section: ¿CÓMO FUNCIONA? - 3 Clear Steps with High-Contrast Highlighted Titles
        MotionUtils.staggerEntrance(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿CÓMO FUNCIONA?',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.textSecondaryLight,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 6),
              const TwoToneTitle(
                text: 'Fácil en ',
                highlightText: '3 pasos',
              ),
              const SizedBox(height: 14),

              _buildStepItem(
                stepNumber: '01',
                title: 'Crea tu cuenta gratis',
                description: 'Elige tu rol (Conductor o Parqueadero) en menos de 1 minuto sin trámites complicados.',
                icon: Icons.person_add_alt_1_rounded,
              ),
              const SizedBox(height: 12),

              _buildStepItem(
                stepNumber: '02',
                title: 'Accede al mapa en vivo de Pasto',
                description: 'Al iniciar sesión, se desbloquea el mapa satelital con los parqueaderos cercanos, centros comerciales, hospitales y tarifas en COP.',
                icon: Icons.map_rounded,
              ),
              const SizedBox(height: 12),

              _buildStepItem(
                stepNumber: '03',
                title: 'Reserva y asegura tu espacio',
                description: 'Confirma las horas de tu estancia y obtén un código de acceso digital para ingresar de inmediato sin filas.',
                icon: Icons.qr_code_2_rounded,
              ),
            ],
          ),
          index: 3,
        ),
        const SizedBox(height: 28),

        // 4. Section: ZONAS ESTRATÉGICAS EN SAN JUAN DE PASTO
        MotionUtils.staggerEntrance(
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(6),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(45),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.location_on_rounded, color: AppColors.darkCard, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'COBERTURA EN SAN JUAN DE PASTO',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              color: Color(0xFFB46500),
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            'Puntos clave integrados',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamily,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    _LocationPill(text: '🛍️ Unicentro Pasto'),
                    _LocationPill(text: '🛍️ C.C. Único Outlet'),
                    _LocationPill(text: '🛍️ Pasaje Nova Centro'),
                    _LocationPill(text: '🛍️ C.C. Belalcázar'),
                    _LocationPill(text: '🏥 Hosp. Departamental HUDN'),
                    _LocationPill(text: '🏥 Hospital San Pedro'),
                    _LocationPill(text: '🏥 Hospital Infantil'),
                    _LocationPill(text: '🏥 Clínica Pasto'),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.lock_outline_rounded, size: 16, color: Color(0xFF0F172A)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'El mapa interactivo y la reserva de cupos se activan al iniciar sesión.',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            color: Color(0xFF1E293B),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          index: 4,
        ),
        const SizedBox(height: 28),

        // 5. Final CTA Action Buttons
        MotionUtils.staggerEntrance(
          Column(
            children: [
              PillButton(
                text: 'Iniciar Sesión',
                variant: PillButtonVariant.dark,
                icon: const Icon(Icons.login_rounded, size: 18, color: Colors.white),
                onPressed: () => context.push('/login'),
              ),
              const SizedBox(height: 12),
              PillButton(
                text: 'Crear Cuenta Gratis',
                variant: PillButtonVariant.primary,
                icon: const Icon(Icons.app_registration_rounded, size: 18, color: AppColors.darkCard),
                onPressed: () => context.push('/register'),
              ),
            ],
          ),
          index: 5,
        ),
        const SizedBox(height: 36),
      ],
    );
  }

  // Focused Card: Conductor Mode
  Widget _buildConductorCard(BuildContext context) {
    return AppCard(
      key: const ValueKey('conductor_card'),
      variant: AppCardVariant.dark,
      padding: const EdgeInsets.all(18),
      onTap: () => context.push('/login'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.directions_car_filled_rounded,
                  color: AppColors.darkCard,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const StatusPill(
                      text: 'PARA CONDUCTORES',
                      backgroundColor: Color(0xFF333333),
                      textColor: AppColors.secondary,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Encuentra y Reserva Cupo',
                      style: AppTypography.title.copyWith(
                        color: AppColors.white,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildBenefitRow(
            icon: Icons.location_on_outlined,
            title: 'Zonas estratégicas en Pasto',
            subtitle: 'Cerca a Unicentro, Único, Nova Centro y Hospitales.',
            isDark: true,
          ),
          const SizedBox(height: 10),
          _buildBenefitRow(
            icon: Icons.timer_outlined,
            title: 'Cero filas ni esperas',
            subtitle: 'Conoce disponibilidad de autos y motos en tiempo real.',
            isDark: true,
          ),
          const SizedBox(height: 10),
          _buildBenefitRow(
            icon: Icons.verified_user_outlined,
            title: 'Parqueaderos vigilados',
            subtitle: 'Tarifas transparentes por hora en COP sin sorpresas.',
            isDark: true,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Toca para ingresar',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withAlpha(140),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                flex: 2,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Explorar como Conductor',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.secondary),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Focused Card: Parking Owner Mode
  Widget _buildOwnerCard(BuildContext context) {
    return AppCard(
      key: const ValueKey('owner_card'),
      variant: AppCardVariant.amber,
      padding: const EdgeInsets.all(18),
      onTap: () => context.push('/register'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'P',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const StatusPill(
                      text: 'PARA PROPIETARIOS',
                      backgroundColor: Color(0xFFF7BD69),
                      textColor: AppColors.darkCard,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Monetiza tus Espacios',
                      style: AppTypography.title.copyWith(
                        color: AppColors.darkCard,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildBenefitRow(
            icon: Icons.trending_up_rounded,
            title: 'Más clientes diarios',
            subtitle: 'Conecta con conductores activos que buscan cupo en Pasto.',
            isDark: false,
          ),
          const SizedBox(height: 10),
          _buildBenefitRow(
            icon: Icons.two_wheeler_rounded,
            title: 'Control Carros y Motos',
            subtitle: 'Actualiza cupos disponibles y tarifas al instante.',
            isDark: false,
          ),
          const SizedBox(height: 10),
          _buildBenefitRow(
            icon: Icons.payments_outlined,
            title: 'Ingresos sin intermediarios',
            subtitle: 'Reportes claros de ocupación y cobros por estancia.',
            isDark: false,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Registro en 1 minuto',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.darkCard.withAlpha(160),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                flex: 2,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Registrar mi Parqueadero',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.darkCard,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.darkCard),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF333333) : const Color(0xFFF7BD69),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 15,
            color: isDark ? AppColors.secondary : AppColors.darkCard,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.darkCard,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w400,
                  color: isDark ? Colors.white70 : AppColors.darkCard.withAlpha(190),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 3-step item with high-contrast highlighted title and crisp typography
  Widget _buildStepItem({
    required String stepNumber,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              stepNumber,
              style: const TextStyle(
                fontFamily: AppTypography.fontFamily,
                color: AppColors.secondary,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Highlighted, high-contrast title that stands out boldly against white card!
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A), // Slate-900: High-contrast, bold, crisp on white!
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 5),
                // Crisp description
                Text(
                  description,
                  style: const TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    color: Color(0xFF475569), // Slate-600
                    height: 1.35,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    if (_isLoading) {
      return const Row(
        children: [
          Expanded(child: AppCard(variant: AppCardVariant.dark, height: 160, child: SizedBox())),
          SizedBox(width: 14),
          Expanded(child: AppCard(variant: AppCardVariant.amber, height: 160, child: SizedBox())),
        ],
      );
    }

    final lot1 = _parkingLots.isNotEmpty ? _parkingLots[0] : null;
    final lot2 = _parkingLots.length > 1 ? _parkingLots[1] : null;

    final name1 = lot1?['name'] as String? ?? 'Parqueadero Unicentro Plaza';
    final price1 = lot1 != null ? '\$${lot1['price_per_hour']}/h' : '\$2.500/h';
    final id1 = lot1?['id'] as String? ?? 'pasto-unicentro-1';
    final spaces1 = lot1?['car_spaces'] ?? 24;
    final dist1 = lot1?['distance'] ?? 60;

    final name2 = lot2?['name'] as String? ?? 'Parqueadero Plaza Belalcázar';
    final price2 = lot2 != null ? '\$${lot2['price_per_hour']}/h' : '\$2.500/h';
    final id2 = lot2?['id'] as String? ?? 'pasto-belalcazar-1';
    final spaces2 = lot2?['car_spaces'] ?? 18;
    final dist2 = lot2?['distance'] ?? 30;

    return Row(
      children: [
        // Dark Card
        Expanded(
          child: AppCard(
            variant: AppCardVariant.dark,
            padding: const EdgeInsets.all(16),
            onTap: () => context.go('/parking/$id1'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusPill(
                      text: '$spaces1 cupos',
                      backgroundColor: const Color(0xFF333333),
                      textColor: AppColors.white,
                      dotColor: AppColors.primary,
                    ),
                    Text(
                      '$dist1 m',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white60,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  name1,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.title.copyWith(
                    color: AppColors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      price1,
                      style: AppTypography.bodyBold.copyWith(
                        color: AppColors.secondary,
                        fontSize: 15,
                      ),
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFF333333),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),

        // Amber Card
        Expanded(
          child: AppCard(
            variant: AppCardVariant.amber,
            padding: const EdgeInsets.all(16),
            onTap: () => context.go('/parking/$id2'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusPill(
                      text: '$spaces2 cupos',
                      backgroundColor: const Color(0xFFF7BD69),
                      textColor: AppColors.darkCard,
                      dotColor: AppColors.darkCard,
                    ),
                    Text(
                      '$dist2 m',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.darkCard.withAlpha(160),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  name2,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.title.copyWith(
                    color: AppColors.darkCard,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      price2,
                      style: AppTypography.bodyBold.copyWith(
                        color: AppColors.darkCard,
                        fontSize: 15,
                      ),
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(200),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.darkCard,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LocationPill extends StatelessWidget {
  final String text;
  const _LocationPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.darkCard,
        ),
      ),
    );
  }
}
