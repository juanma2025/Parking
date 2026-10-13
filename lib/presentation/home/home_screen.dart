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

      // Fetch active parking lots from Supabase
      final response = await Supabase.instance.client
          .from('parking_lots')
          .select()
          .eq('status', 'active')
          .limit(10);

      setState(() {
        _parkingLots = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
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
                // 1. Top App Bar with Drawer opener
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
                          builder: (scaffoldContext) => IconButton(
                            icon: const Icon(Icons.menu_rounded, color: AppColors.darkCard),
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
                      AvatarButton(
                        onTap: () => context.go('/profile'),
                      ),
                    ],
                  ),
                  index: 0,
                ),
                const SizedBox(height: 18),

                // 2. Greeting & Title + Quick Auth Action Pills
                MotionUtils.staggerEntrance(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SectionLabel('BIENVENIDO, $_userName'),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  ref.read(userRoleStateProvider.notifier).setRole(UserRole.guest);
                                  context.go('/login');
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.darkCard,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.login_rounded, size: 12, color: AppColors.secondary),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Iniciar sesión',
                                        style: AppTypography.caption.copyWith(
                                          color: AppColors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 10.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () {
                                  ref.read(userRoleStateProvider.notifier).setRole(UserRole.guest);
                                  context.go('/register');
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.person_add_rounded, size: 12, color: AppColors.darkCard),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Registro',
                                        style: AppTypography.caption.copyWith(
                                          color: AppColors.darkCard,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 10.5,
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
                const SizedBox(height: 22),

                // 4. Amber Map Card
                MotionUtils.staggerEntrance(
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      height: 220,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary, // Amber #FEC775
                      ),
                      child: Stack(
                        children: [
                          // OpenStreetMap View
                          const AppMap(),

                          // Overlay Pill: Top Left
                          Positioned(
                            top: 14,
                            left: 14,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.white.withAlpha(235),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Parqueaderos disponibles cerca',
                                    style: AppTypography.caption.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.darkCard,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Layer Button: Top Right
                          Positioned(
                            top: 14,
                            right: 14,
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AppColors.white.withAlpha(235),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.layers_outlined,
                                color: AppColors.darkCard,
                                size: 20,
                              ),
                            ),
                          ),

                          // Overlay Pill: Bottom Left
                          Positioned(
                            bottom: 14,
                            left: 14,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.white.withAlpha(235),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.near_me_outlined,
                                    color: AppColors.darkCard,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Zona activa: Chapinero',
                                    style: AppTypography.caption.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.darkCard,
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
                  ),
                  index: 3,
                ),
                const SizedBox(height: 24),

                // 5. Recommended Parking Lots Cards
                MotionUtils.staggerEntrance(
                  _buildRecommendationsSection(),
                  index: 4,
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

    // Default Stitch Recommended Cards (or populated from Supabase)
    final lot1 = _parkingLots.isNotEmpty ? _parkingLots[0] : null;
    final lot2 = _parkingLots.length > 1 ? _parkingLots[1] : null;

    final name1 = lot1?['name'] ?? 'Hospital San José';
    final price1 = lot1 != null ? '\$${lot1['price_per_hour']}/h' : '\$3.500/h';
    final id1 = lot1?['id'] ?? 'mock-1';

    final name2 = lot2?['name'] ?? 'Clínica Norte';
    final price2 = lot2 != null ? '\$${lot2['price_per_hour']}/h' : '\$5.000/h';
    final id2 = lot2?['id'] ?? 'mock-2';

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
                    const StatusPill(
                      text: '12 cupos',
                      backgroundColor: Color(0xFF333333),
                      textColor: AppColors.white,
                      dotColor: AppColors.primary,
                    ),
                    Text(
                      '350 m',
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
                    fontSize: 18,
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
                    const StatusPill(
                      text: '5 cupos',
                      backgroundColor: Color(0xFFF7BD69),
                      textColor: AppColors.darkCard,
                      dotColor: AppColors.darkCard,
                    ),
                    Text(
                      '800 m',
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
                    fontSize: 18,
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
