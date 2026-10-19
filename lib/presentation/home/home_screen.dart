import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/motion_utils.dart';
import '../../data/datasources/pasto_landmarks_data.dart';
import '../../domain/entities/domain_entities.dart';
import '../auth/auth_providers.dart';
import '../shared/animated_auth_actions.dart';
import '../shared/app_card.dart';
import '../shared/app_drawer.dart';
import '../shared/app_map.dart';
import '../shared/avatar_button.dart';
import '../shared/section_label.dart';
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

  @override
  Widget build(BuildContext context) {
    final isAuth = ref.watch(isAuthenticatedProvider);
    final user = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(currentProfileProvider);

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
                // 1. Top App Bar (Conditional Hamburger and Top-Right Action)
                MotionUtils.staggerEntrance(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Left: Hamburger menu ONLY if authenticated; Logo squircle if unauthenticated
                      if (isAuth)
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.white,
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
                              icon: const Icon(Icons.menu_rounded, color: AppColors.darkCard),
                              onPressed: () {
                                Scaffold.of(scaffoldContext).openDrawer();
                              },
                            ),
                          ),
                        )
                      else
                        Container(
                          width: 44,
                          height: 44,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(8),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              'assets/images/app_logo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.local_parking_rounded,
                                  color: AppColors.darkCard,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),

                      Text(
                        'Explore Parking',
                        style: AppTypography.title.copyWith(fontSize: 18),
                      ),

                      // Top Right: Real AvatarButton if authenticated; AnimatedAuthActions if unauthenticated
                      if (isAuth)
                        AvatarButton(
                          initials: _getUserInitials(user, profileAsync),
                          onTap: () => context.go('/profile'),
                        )
                      else
                        const AnimatedAuthActions(),
                    ],
                  ),
                  index: 0,
                ),
                const SizedBox(height: 18),

                // 2. Greeting & Title
                MotionUtils.staggerEntrance(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isAuth)
                        SectionLabel('BIENVENIDO, ${_getDisplayName(user, profileAsync)}')
                      else
                        const SectionLabel('MODO EXPLORACIÓN'),
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

                // 3. Pill Search Bar
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
                              hintText: 'Buscar por dirección o zona...',
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

                // 4. Landmarks Quick Access Bar (San Juan de Pasto)
                MotionUtils.staggerEntrance(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'PUNTOS CLAVE EN PASTO',
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
                              'Toca para ver parqueaderos',
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
                      SizedBox(
                        height: 38,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: PastoDataService.getLandmarks().map((landmark) {
                            final isMall = landmark.category == LandmarkCategory.shoppingMall;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: InkWell(
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

                // 5. OpenStreetMap View (San Juan de Pasto)
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

                // 6. Recommended Parking Lots Cards
                MotionUtils.staggerEntrance(
                  _buildRecommendationsSection(),
                  index: 5,
                ),
                const SizedBox(height: 80), // Padding for BottomBar5
              ],
            ),
          ),
        ),
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

    // Default Pasto Recommended Cards (or populated from Supabase)
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
