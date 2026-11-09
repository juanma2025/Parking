import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/utils/motion_utils.dart';
import '../../data/datasources/pasto_landmarks_data.dart';
import '../../domain/entities/domain_entities.dart';
import '../auth/auth_providers.dart';
import '../profile/user_profile_provider.dart';
import '../shared/animated_auth_actions.dart';
import '../shared/app_card.dart';
import '../shared/app_drawer.dart';
import '../shared/app_map.dart';
import '../shared/avatar_button.dart';
import '../shared/glass_container.dart';
import '../shared/primary_button.dart';
import '../shared/section_label.dart';
import '../shared/stat_counter.dart';
import '../shared/status_pill.dart';
import '../shared/step_carousel.dart';
import '../shared/two_tone_title.dart';
import '../shared/zone_chip.dart';
import 'widgets/ai_assistant_card.dart';
import 'widgets/guest_map_explorer_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  List<Map<String, dynamic>> _parkingLots = [];
  bool _isLoading = true;
  String _userName = 'CONDUCTOR';
  int _selectedRoleTab = 0; // 0: Conductor, 1: Parqueadero
  bool _isGuaranteesExpanded = false;
  double _scrollOffset = 0.0;

  static const List<StepCarouselItemData> _howItWorksSteps = [
    StepCarouselItemData(
      stepNumber: '01',
      icon: Icons.map_outlined,
      title: 'Explora el mapa en vivo',
      subtitle: 'Consulta cupos y tarifas en Pasto sin registrarte.',
    ),
    StepCarouselItemData(
      stepNumber: '02',
      icon: Icons.touch_app_outlined,
      title: 'Elige tu zona favorita',
      subtitle: 'Compara parqueaderos cerca a clínicas y comercios.',
    ),
    StepCarouselItemData(
      stepNumber: '03',
      icon: Icons.qr_code_2_rounded,
      title: 'Reserva y entra con QR',
      subtitle: 'Crea tu cuenta al reservar e ingresa sin filas.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  void _onScroll() {
    if (!mounted) return;
    final nextOffset = _scrollController.offset.clamp(0.0, 220.0);
    if ((nextOffset - _scrollOffset).abs() > 1.0) {
      setState(() => _scrollOffset = nextOffset);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
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

        if (profile != null &&
            profile['full_name'] != null &&
            (profile['full_name'] as String).isNotEmpty) {
          final fullName = profile['full_name'] as String;
          _userName = fullName.split(' ').first.toUpperCase();
        }
      }

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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      _parkingLots = _getPastoDefaultParkingLots();
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Map<String, dynamic>> _getPastoDefaultParkingLots() {
    return PastoDataService.getAllParkingLots()
        .map((p) => {
              'id': p.id,
              'name': p.name,
              'address': p.address,
              'price_per_hour': p.pricePerHour,
              'car_spaces': p.carSpaces,
              'moto_spaces': p.motoSpaces,
              'distance': p.distanceMeters,
            })
        .toList();
  }

  int get _totalAvailableSpots {
    if (_parkingLots.isEmpty) {
      return PastoDataService.getAllParkingLots()
          .fold<int>(0, (sum, lot) => sum + lot.totalSpaces);
    }
    return _parkingLots.fold<int>(
      0,
      (sum, lot) =>
          sum +
          ((lot['car_spaces'] as num?)?.toInt() ?? 15) +
          ((lot['moto_spaces'] as num?)?.toInt() ?? 10),
    );
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
      return Icons.wb_sunny_outlined;
    } else if (hour >= 12 && hour < 19) {
      return Icons.wb_twilight_rounded;
    } else {
      return Icons.nightlight_outlined;
    }
  }

  Widget _buildThemeToggleButton(ThemeMode themeMode, bool isDark) {
    IconData icon;
    String tooltip;
    if (themeMode == ThemeMode.system) {
      icon = Icons.brightness_auto_outlined;
      tooltip = 'Tema: Adaptado al dispositivo';
    } else if (themeMode == ThemeMode.dark) {
      icon = Icons.dark_mode_outlined;
      tooltip = 'Tema: Oscuro';
    } else {
      icon = Icons.light_mode_outlined;
      tooltip = 'Tema: Claro';
    }

    return MotionUtils.pressable(
      onTap: () => ref.read(themeModeProvider.notifier).toggleTheme(),
      haptic: HapticType.selectionClick,
      semanticLabel: tooltip,
      borderRadius: BorderRadius.circular(14),
      child: Tooltip(
        message: tooltip,
        child: Container(
          constraints: const BoxConstraints(
            minWidth: DesignTokens.minTouchTarget,
            minHeight: DesignTokens.minTouchTarget,
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: DesignTokens.surfaceElevated(isDark),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: DesignTokens.outline(isDark),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: DesignTokens.accentText(isDark),
          ),
        ),
      ),
    );
  }

  void _openGuestMap({Landmark? landmark, String? heroTag}) {
    GuestMapExplorerSheet.show(
      context,
      initialLandmark: landmark,
      heroTag: heroTag,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAuth = ref.watch(isAuthenticatedProvider);
    final user = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(currentProfileProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userProfile = ref.watch(userProfileProvider);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: DesignTokens.clampedTextScaler(context),
      ),
      child: Scaffold(
        drawer: isAuth ? const AppDrawer() : null,
        bottomNavigationBar: !isAuth ? _buildStickyExploreCta(isDark) : null,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompactPhone = constraints.maxWidth < 360;
              final isTablet = constraints.maxWidth >= 600;
              final horizontalPadding = isCompactPhone
                  ? DesignTokens.spacingSm
                  : (isTablet ? 28.0 : DesignTokens.spacingLg);

              return RefreshIndicator(
                onRefresh: _loadInitialData,
                color: DesignTokens.brandAccent,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 10.0,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 680),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // a. Header: Logo + "Parking" completo a la izquierda, acciones limpias a la derecha
                          MotionUtils.staggerEntrance(
                            _buildHeader(
                              context: context,
                              isAuth: isAuth,
                              isDark: isDark,
                              themeMode: themeMode,
                              user: user,
                              profileAsync: profileAsync,
                              avatarUrl: userProfile.avatarUrl,
                              isCompactPhone: isCompactPhone,
                            ),
                            index: 0,
                          ),
                          const SizedBox(height: 14),

                          // Transición fluida entre Landing (Invitado) y Dashboard (Autenticado)
                          AnimatedSwitcher(
                            duration: DesignTokens.durationNormal,
                            switchInCurve: DesignTokens.springCurve,
                            switchOutCurve: Curves.easeOutCubic,
                            transitionBuilder: (child, animation) =>
                                FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                            child: isAuth
                                ? _buildAuthenticatedContent(
                                    context, user, profileAsync, isDark)
                                : _buildLandingContent(
                                    context, isDark, isCompactPhone),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // a. HEADER (Liquid Glass limpio, altura 56-64 dp, padding 16-20, sin truncar "Parking")
  // ============================================================================
  Widget _buildHeader({
    required BuildContext context,
    required bool isAuth,
    required bool isDark,
    required ThemeMode themeMode,
    required User? user,
    required AsyncValue<Profile?> profileAsync,
    required String? avatarUrl,
    required bool isCompactPhone,
  }) {
    if (isAuth) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: DesignTokens.minTouchTarget,
            height: DesignTokens.minTouchTarget,
            decoration: BoxDecoration(
              color: DesignTokens.surface(isDark),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: DesignTokens.outline(isDark),
              ),
            ),
            child: Builder(
              builder: (scaffoldContext) => IconButton(
                tooltip: 'Abrir menú',
                icon: Icon(
                  Icons.menu_rounded,
                  color: DesignTokens.onSurface(isDark),
                ),
                onPressed: () {
                  MotionUtils.triggerHaptic(HapticType.lightImpact);
                  Scaffold.of(scaffoldContext).openDrawer();
                },
              ),
            ),
          ),
          Text(
            'Explore Parking',
            style: DesignTokens.headline(isDark),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeToggleButton(themeMode, isDark),
              const SizedBox(width: DesignTokens.spacingXs),
              Hero(
                tag: 'user-avatar-hero',
                child: AvatarButton(
                  avatarUrl: avatarUrl,
                  initials: _getUserInitials(user, profileAsync),
                  onTap: () => context.go('/profile'),
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Un único contenedor Liquid Glass limpio, sin cajas anidadas ni bordes dobles,
    // altura 60 dp (rango 56-64 dp), padding horizontal 16-20 dp y separación >= 12 dp.
    return GlassContainer(
      borderRadius: DesignTokens.radiusCard,
      padding: EdgeInsets.symmetric(
        horizontal: isCompactPhone ? 16.0 : 20.0,
        vertical: 6.0,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 48.0, // Con 6.0 * 2 de padding vertical => 60 dp de altura total (56-64 dp)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Izquierda: Logo + nombre completo "Parking" (nunca truncado, área táctil >= 48x48 dp)
            MotionUtils.pressable(
              haptic: HapticType.lightImpact,
              semanticLabel: 'Parking inicio',
              onTap: () {
                if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                    0,
                    duration: DesignTokens.durationNormal,
                    curve: DesignTokens.springCurve,
                  );
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: DesignTokens.minTouchTarget,
                  minWidth: DesignTokens.minTouchTarget,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Hero(
                      tag: 'app-official-logo',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/images/app_logo.png',
                          width: 28,
                          height: 28,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: DesignTokens.brandAccent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.local_parking_rounded,
                              color: DesignTokens.onBrandAccent,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Parking',
                        maxLines: 1,
                        style: TextStyle(
                          fontFamily: DesignTokens.fontFamily,
                          fontSize: 17.0,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: DesignTokens.onSurface(isDark),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Derecha: TextButton discreto "Iniciar sesión" + único botón primario "Registro"
            const Flexible(
              child: AnimatedAuthActions(),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // STICKY PRIMARY CTA AT BOTTOM (Fase 1.4, Fase 2.4, Fase 3.1)
  // ============================================================================
  Widget _buildStickyExploreCta(bool isDark) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          DesignTokens.spacingMd,
          6,
          DesignTokens.spacingMd,
          10,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: GlassContainer(
            borderRadius: DesignTokens.radiusCard,
            padding: const EdgeInsets.all(DesignTokens.spacingXs),
            child: PrimaryButton(
              label: 'Explorar mapa',
              icon: Icons.explore_rounded,
              badgeText: 'Sin registro',
              heroTag: 'hero-explore-map-cta',
              onPressed: () => _openGuestMap(heroTag: 'hero-explore-map-cta'),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // UNAUTHENTICATED LANDING VIEW (Fases 1 a 4)
  // ============================================================================
  Widget _buildLandingContent(
    BuildContext context,
    bool isDark,
    bool isCompactPhone,
  ) {
    final reduceMotion = MotionUtils.reduceMotion(context);
    final parallaxOffset = reduceMotion ? 0.0 : -(_scrollOffset * 0.12);
    final landmarks = PastoDataService.getLandmarks();

    return Column(
      key: const ValueKey('landing_content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // b. HERO: Titular de máximo 6 palabras + una sola línea de apoyo + Parallax sutil + StatCounter
        MotionUtils.staggerEntrance(
          Transform.translate(
            offset: Offset(0, parallaxOffset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: DesignTokens.spacingXs,
                  runSpacing: DesignTokens.spacingXs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: DesignTokens.surface(isDark),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? DesignTokens.darkOutline
                              : DesignTokens.brandAccent.withAlpha(90),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getTimeIcon(),
                            size: 14,
                            color: DesignTokens.accentText(isDark),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${_getTimeGreeting().toUpperCase()} · PASTO',
                            style: DesignTokens.overline(isDark),
                          ),
                        ],
                      ),
                    ),
                    StatCounter(
                      value: _totalAvailableSpots,
                      label: 'cupos hoy',
                      isLoading: _isLoading,
                      onTap: () =>
                          _openGuestMap(heroTag: 'hero-explore-map-cta'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Titular de máximo 6 palabras ("Parquea en Pasto, sin dar vueltas")
                const TwoToneTitle(
                  text: 'Parquea en Pasto, ',
                  highlightText: 'sin dar vueltas',
                ),
                const SizedBox(height: 6),
                // Una sola línea de apoyo (máximo 2 líneas en pantallas pequeñas)
                Text(
                  'Cupos en tiempo real cerca a clínicas y centros comerciales.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: DesignTokens.body(isDark),
                ),
              ],
            ),
          ),
          index: 1,
        ),
        const SizedBox(height: DesignTokens.spacingMd),

        // c. SELECTOR CONDUCTOR / PARQUEADERO (Segmented Control) + 3 Garantías Fusionadas + Acordeón "Ver más"
        MotionUtils.staggerEntrance(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel(
                '¿QUÉ OPCIONES TIENES?',
                color: DesignTokens.accentText(isDark),
              ),
              const SizedBox(height: DesignTokens.spacingXs),
              _buildSegmentedRoleSelector(isDark),
              const SizedBox(height: 10),
              AnimatedSwitcher(
                duration: DesignTokens.durationNormal,
                switchInCurve: DesignTokens.springCurve,
                switchOutCurve: Curves.easeOutCubic,
                transitionBuilder: (child, animation) {
                  if (reduceMotion) {
                    return FadeTransition(opacity: animation, child: child);
                  }
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(
                        begin: 0.96,
                        end: 1.0,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _selectedRoleTab == 0
                    ? _buildConductorRoleCard(context, isDark)
                    : _buildOwnerRoleCard(context, isDark),
              ),
            ],
          ),
          index: 2,
        ),
        const SizedBox(height: DesignTokens.spacingLg),

        // d. "CÓMO FUNCIONA": Carrusel horizontal de 3 pasos con indicador de página
        MotionUtils.staggerEntrance(
          StepCarousel(
            steps: _howItWorksSteps,
            isLoading: _isLoading,
          ),
          index: 3,
        ),
        const SizedBox(height: DesignTokens.spacingLg),

        // e. CHIPS DE ZONAS TAPPABLES: Al tocar abren el mapa centrado en esa zona
        MotionUtils.staggerEntrance(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: SectionLabel(
                      'ZONAS EN SAN JUAN DE PASTO',
                      color: DesignTokens.accentText(isDark),
                    ),
                  ),
                  Text(
                    'Toca para abrir mapa',
                    style: DesignTokens.caption(isDark),
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.spacingXs),
              Wrap(
                spacing: DesignTokens.spacingXs,
                runSpacing: DesignTokens.spacingXs,
                children: landmarks
                    .map(
                      (landmark) => ZoneChip(
                        landmark: landmark,
                        onTap: () => _openGuestMap(
                          landmark: landmark,
                          heroTag: 'zone-chip-hero-${landmark.id}',
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          index: 4,
        ),
        const SizedBox(height: DesignTokens.spacingLg),

        // f. FOOTER MÍNIMO (Conserva textos legales intactos)
        MotionUtils.staggerEntrance(
          _buildMinimalFooter(context, isDark),
          index: 5,
        ),
        const SizedBox(height: DesignTokens.spacingSm),
      ],
    );
  }

  // Segmented Control (Conductor / Parqueadero) con áreas táctiles >= 48 dp y física Spring
  Widget _buildSegmentedRoleSelector(bool isDark) {
    return Container(
      height: DesignTokens.minTouchTarget,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? DesignTokens.darkSurface : const Color(0xFFE4E4E7),
        borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
        border: Border.all(
          color: DesignTokens.outline(isDark),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: MotionUtils.pressable(
              onTap: () => setState(() => _selectedRoleTab = 0),
              haptic: HapticType.selectionClick,
              semanticLabel: 'Opción Conductor',
              borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
              child: AnimatedContainer(
                duration: DesignTokens.durationNormal,
                curve: DesignTokens.springCurve,
                decoration: BoxDecoration(
                  color: _selectedRoleTab == 0
                      ? DesignTokens.brandAccent
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.directions_car_outlined,
                      size: 16,
                      color: _selectedRoleTab == 0
                          ? DesignTokens.onBrandAccent
                          : DesignTokens.onSurfaceVariant(isDark),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Conductor',
                      style: DesignTokens.bodyBold(isDark).copyWith(
                        color: _selectedRoleTab == 0
                            ? DesignTokens.onBrandAccent
                            : DesignTokens.onSurfaceVariant(isDark),
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
              haptic: HapticType.selectionClick,
              semanticLabel: 'Opción Parqueadero',
              borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
              child: AnimatedContainer(
                duration: DesignTokens.durationNormal,
                curve: DesignTokens.springCurve,
                decoration: BoxDecoration(
                  color: _selectedRoleTab == 1
                      ? DesignTokens.brandAccent
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_parking_rounded,
                      size: 16,
                      color: _selectedRoleTab == 1
                          ? DesignTokens.onBrandAccent
                          : DesignTokens.onSurfaceVariant(isDark),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Parqueadero',
                      style: DesignTokens.bodyBold(isDark).copyWith(
                        color: _selectedRoleTab == 1
                            ? DesignTokens.onBrandAccent
                            : DesignTokens.onSurfaceVariant(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Card Conductor con las 3 Garantías Fusionadas (Icono + Etiqueta Corta) + Acordeón "Ver más"
  Widget _buildConductorRoleCard(BuildContext context, bool isDark) {
    return AppCard(
      key: const ValueKey('conductor_card'),
      variant: AppCardVariant.white,
      padding: const EdgeInsets.all(DesignTokens.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: DesignTokens.brandAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.directions_car_outlined,
                  color: DesignTokens.onBrandAccent,
                  size: 22,
                ),
              ),
              const SizedBox(width: DesignTokens.spacingSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Encuentra y Reserva Cupo',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DesignTokens.headline(isDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Para autos y motos en zonas clave de Pasto.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DesignTokens.caption(isDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacingSm),

          // 3 Iconos con etiqueta corta fusionados (Fase 1.2: "Verificados", "Tiempo real", "Pago fácil")
          Row(
            children: [
              Expanded(
                child: _buildGuaranteeBadge(
                  icon: Icons.verified_user_outlined,
                  label: 'Verificados',
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: DesignTokens.spacingXs),
              Expanded(
                child: _buildGuaranteeBadge(
                  icon: Icons.bolt_rounded,
                  label: 'Tiempo real',
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: DesignTokens.spacingXs),
              Expanded(
                child: _buildGuaranteeBadge(
                  icon: Icons.qr_code_scanner_rounded,
                  label: 'Pago fácil',
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Acordeón "Ver más" con animación fluida de altura (Fase 1.2 y Fase 2.6)
          _buildExpandableDetailsAccordion(
            isDark: isDark,
            items: const [
              (
                icon: Icons.shield_outlined,
                text: 'Cámaras de seguridad y personal de control en cada punto.'
              ),
              (
                icon: Icons.schedule_rounded,
                text: 'Tarifas oficiales por hora en COP sin cobros sorpresa.'
              ),
              (
                icon: Icons.account_balance_wallet_outlined,
                text: 'Paga rápido con Nequi, transferencia o efectivo.'
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Card Parqueadero con 3 Etiquetas Cortas + Acordeón "Ver más" + Acción de Registro
  Widget _buildOwnerRoleCard(BuildContext context, bool isDark) {
    return AppCard(
      key: const ValueKey('owner_card'),
      variant: AppCardVariant.white,
      padding: const EdgeInsets.all(DesignTokens.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: DesignTokens.brandAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.storefront_outlined,
                  color: DesignTokens.onBrandAccent,
                  size: 22,
                ),
              ),
              const SizedBox(width: DesignTokens.spacingSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monetiza tus Espacios',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DesignTokens.headline(isDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Recibe reservas digitales de conductores en Pasto.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DesignTokens.caption(isDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacingSm),

          Row(
            children: [
              Expanded(
                child: _buildGuaranteeBadge(
                  icon: Icons.trending_up_rounded,
                  label: 'Más clientes',
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: DesignTokens.spacingXs),
              Expanded(
                child: _buildGuaranteeBadge(
                  icon: Icons.grid_view_rounded,
                  label: 'Control total',
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: DesignTokens.spacingXs),
              Expanded(
                child: _buildGuaranteeBadge(
                  icon: Icons.payments_outlined,
                  label: 'Cobro directo',
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          _buildExpandableDetailsAccordion(
            isDark: isDark,
            items: const [
              (
                icon: Icons.qr_code_2_rounded,
                text: 'Valida el ingreso de vehículos con lectura QR al instante.'
              ),
              (
                icon: Icons.bar_chart_rounded,
                text: 'Panel en vivo para habilitar cupos y ver ingresos diarios.'
              ),
            ],
          ),
          const SizedBox(height: 10),

          MotionUtils.pressable(
            onTap: () => context.push('/register'),
            haptic: HapticType.lightImpact,
            semanticLabel: 'Registrar mi Parqueadero',
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(
                minHeight: DesignTokens.minTouchTarget,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: DesignTokens.surfaceElevated(isDark),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: DesignTokens.brandAccent.withAlpha(110),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Registrar mi Parqueadero',
                    style: DesignTokens.bodyBold(isDark).copyWith(
                      color: DesignTokens.accentText(isDark),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: DesignTokens.accentText(isDark),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuaranteeBadge({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spacingXs,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: DesignTokens.surfaceElevated(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: DesignTokens.outline(isDark),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: DesignTokens.accentText(isDark),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: DesignTokens.caption(isDark).copyWith(
              fontWeight: FontWeight.w700,
              color: DesignTokens.onSurface(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableDetailsAccordion({
    required bool isDark,
    required List<({IconData icon, String text})> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MotionUtils.pressable(
          onTap: () => setState(
              () => _isGuaranteesExpanded = !_isGuaranteesExpanded),
          haptic: HapticType.selectionClick,
          semanticLabel: _isGuaranteesExpanded
              ? 'Ocultar detalles de garantías'
              : 'Ver más detalles de garantías',
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(
              minHeight: DesignTokens.minTouchTarget,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spacingXs,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isGuaranteesExpanded
                      ? 'Ver menos detalles'
                      : 'Ver más detalles',
                  style: DesignTokens.caption(isDark).copyWith(
                    fontWeight: FontWeight.w700,
                    color: DesignTokens.accentText(isDark),
                  ),
                ),
                AnimatedRotation(
                  turns: _isGuaranteesExpanded ? 0.5 : 0.0,
                  duration: DesignTokens.durationNormal,
                  curve: DesignTokens.springCurve,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: DesignTokens.accentText(isDark),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: DesignTokens.durationNormal,
          curve: DesignTokens.springCurve,
          alignment: Alignment.topCenter,
          child: _isGuaranteesExpanded
              ? Padding(
                  padding: const EdgeInsets.only(
                    top: DesignTokens.spacing2xs,
                    left: DesignTokens.spacing2xs,
                    right: DesignTokens.spacing2xs,
                  ),
                  child: Column(
                    children: items
                        .map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: DesignTokens.spacingXs,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  item.icon,
                                  size: 16,
                                  color: DesignTokens.accentText(isDark),
                                ),
                                const SizedBox(width: DesignTokens.spacingXs),
                                Expanded(
                                  child: Text(
                                    item.text,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: DesignTokens.caption(isDark),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  // f. Footer mínimo (Mantiene textos legales exactos: Términos del Servicio, Privacidad, Soporte)
  Widget _buildMinimalFooter(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: DesignTokens.spacingSm,
        bottom: DesignTokens.spacingXs,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: DesignTokens.outline(isDark),
          ),
        ),
      ),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: DesignTokens.spacingSm,
            runSpacing: DesignTokens.spacing2xs,
            children: [
              _buildFooterLink(
                label: 'Términos del Servicio',
                isDark: isDark,
                onTap: () => _showLegalSheet(
                  context,
                  title: 'Términos del Servicio',
                  content:
                      'Uso de reservas verificadas y acceso QR en la red de parqueaderos aliados de San Juan de Pasto.',
                ),
              ),
              _buildFooterLink(
                label: 'Privacidad',
                isDark: isDark,
                onTap: () => _showLegalSheet(
                  context,
                  title: 'Privacidad',
                  content:
                      'Protegemos tus datos personales y placas vehiculares bajo estándares de seguridad cifrada.',
                ),
              ),
              _buildFooterLink(
                label: 'Soporte',
                isDark: isDark,
                onTap: () => _showLegalSheet(
                  context,
                  title: 'Soporte',
                  content:
                      'Atención prioritaria para conductores y parqueaderos en San Juan de Pasto 24/7.',
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.spacing2xs),
          Text(
            '© 2026 Parking Pasto · San Juan de Pasto, Nariño',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: DesignTokens.caption(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink({
    required String label,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final linkColor = DesignTokens.accentText(isDark);
    return MotionUtils.pressable(
      onTap: onTap,
      haptic: HapticType.lightImpact,
      semanticLabel: label,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(
          minHeight: DesignTokens.minTouchTarget,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        alignment: Alignment.center,
        child: Text(
          label,
          style: DesignTokens.caption(isDark).copyWith(
            fontWeight: FontWeight.w700,
            color: linkColor,
            decoration: TextDecoration.underline,
            decorationColor: linkColor,
          ),
        ),
      ),
    );
  }

  void _showLegalSheet(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spacingMd),
          child: AppCard(
            padding: const EdgeInsets.all(DesignTokens.spacingLg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: DesignTokens.headline(isDark),
                ),
                const SizedBox(height: DesignTokens.spacingXs),
                Text(
                  content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: DesignTokens.body(isDark),
                ),
                const SizedBox(height: DesignTokens.spacingMd),
                PrimaryButton(
                  label: 'Entendido',
                  onPressed: () => Navigator.of(ctx).pop(),
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
    bool isDark,
  ) {
    return Column(
      key: const ValueKey('authenticated_content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MotionUtils.staggerEntrance(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getTimeIcon(),
                    size: 14,
                    color: DesignTokens.accentText(isDark),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '¡${_getTimeGreeting().toUpperCase()}, ${_getDisplayName(user, profileAsync)}!',
                    style: AppTypography.sectionLabel.copyWith(
                      color: DesignTokens.accentText(isDark),
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

        // Pill Search Bar (Adaptive Light/Dark surface)
        MotionUtils.staggerEntrance(
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: DesignTokens.surface(isDark),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: DesignTokens.outline(isDark),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  color: DesignTokens.brandAccent,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: DesignTokens.body(isDark).copyWith(
                      color: DesignTokens.onSurface(isDark),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Buscar por dirección o zona en Pasto...',
                      hintStyle: DesignTokens.body(isDark),
                      fillColor: Colors.transparent,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.mic_none_rounded,
                    color: DesignTokens.onSurfaceVariant(isDark),
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          index: 2,
        ),
        const SizedBox(height: 18),

        // Landmarks Quick Access Bar
        MotionUtils.staggerEntrance(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: SectionLabel(
                      'PUNTOS CLAVE EN PASTO',
                      color: DesignTokens.accentText(isDark),
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatCounter(
                    value: _totalAvailableSpots,
                    label: 'cupos',
                    isLoading: _isLoading,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: DesignTokens.minTouchTarget,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: PastoDataService.getLandmarks().map((landmark) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ZoneChip(
                        landmark: landmark,
                        onTap: () =>
                            AppMap.showLandmarkDetails(context, landmark),
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

        // OpenStreetMap View with Skeleton Shimmer fallback
        MotionUtils.staggerEntrance(
          ClipRRect(
            borderRadius: BorderRadius.circular(DesignTokens.radiusCardLg),
            child: Container(
              height: 290,
              decoration: BoxDecoration(
                color: DesignTokens.surface(isDark),
                borderRadius: BorderRadius.circular(DesignTokens.radiusCardLg),
                border: Border.all(
                  color: DesignTokens.outline(isDark),
                ),
              ),
              child: _isLoading
                  ? Shimmer.fromColors(
                      baseColor: isDark
                          ? DesignTokens.darkSurface
                          : const Color(0xFFE4E4E7),
                      highlightColor: isDark
                          ? DesignTokens.darkSurfaceElevated
                          : const Color(0xFFF4F4F5),
                      child: Container(color: Colors.white),
                    )
                  : const AppMap(
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
          _buildRecommendationsSection(isDark),
          index: 5,
        ),
        const SizedBox(height: 16),

        // Compact AI Chatbot Card (Gemini API) below parking lot suggestions
        MotionUtils.staggerEntrance(
          const AiAssistantCard(),
          index: 6,
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildRecommendationsSection(bool isDark) {
    if (_isLoading) {
      return Shimmer.fromColors(
        baseColor:
            isDark ? DesignTokens.darkSurface : const Color(0xFFE4E4E7),
        highlightColor:
            isDark ? DesignTokens.darkSurfaceElevated : const Color(0xFFF4F4F5),
        child: const Row(
          children: [
            Expanded(
              child: AppCard(
                variant: AppCardVariant.dark,
                height: 160,
                child: SizedBox(),
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: AppCard(
                variant: AppCardVariant.amber,
                height: 160,
                child: SizedBox(),
              ),
            ),
          ],
        ),
      );
    }

    final lot1 = _parkingLots.isNotEmpty ? _parkingLots[0] : null;
    final lot2 = _parkingLots.length > 1 ? _parkingLots[1] : null;

    final name1 = lot1?['name'] as String? ?? 'Parqueadero Unicentro Plaza';
    final price1 =
        lot1 != null ? '\$${lot1['price_per_hour']}/h' : '\$2.500/h';
    final id1 = lot1?['id'] as String? ?? 'pasto-unicentro-1';
    final spaces1 = lot1?['car_spaces'] ?? 24;
    final dist1 = lot1?['distance'] ?? 60;

    final name2 = lot2?['name'] as String? ?? 'Parqueadero Plaza Belalcázar';
    final price2 =
        lot2 != null ? '\$${lot2['price_per_hour']}/h' : '\$2.500/h';
    final id2 = lot2?['id'] as String? ?? 'pasto-belalcazar-1';
    final spaces2 = lot2?['car_spaces'] ?? 18;
    final dist2 = lot2?['distance'] ?? 30;

    return Row(
      children: [
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
                        fontSize: 12,
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
                        fontSize: 12,
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
