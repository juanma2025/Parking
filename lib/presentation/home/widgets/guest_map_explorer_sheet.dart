import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/utils/motion_utils.dart';
import '../../../data/datasources/pasto_landmarks_data.dart';
import '../../shared/app_card.dart';
import '../../shared/app_map.dart';
import '../../shared/glass_container.dart';
import '../../shared/primary_button.dart';
import '../../shared/stat_counter.dart';

/// Modal interactivo en Modo Invitado (Fase 1.5, Fase 2.4, Fase 3.1, Fase 4.4).
/// Permite explorar el mapa de San Juan de Pasto y cambiar de zona sin registro;
/// solicita cuenta únicamente cuando el usuario toca "Reservar cupo".
class GuestMapExplorerSheet extends StatefulWidget {
  final Landmark? initialLandmark;
  final String? heroTag;

  const GuestMapExplorerSheet({
    super.key,
    this.initialLandmark,
    this.heroTag,
  });

  static Future<void> show(
    BuildContext context, {
    Landmark? initialLandmark,
    String? heroTag,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withAlpha(140),
        transitionDuration: DesignTokens.durationNormal,
        reverseTransitionDuration: DesignTokens.durationFast,
        pageBuilder: (context, animation, secondaryAnimation) {
          return GuestMapExplorerSheet(
            initialLandmark: initialLandmark,
            heroTag: heroTag,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final reduce = MotionUtils.reduceMotion(context);
          final curved = CurvedAnimation(
            parent: animation,
            curve: reduce ? Curves.easeOut : DesignTokens.springCurve,
          );
          if (reduce) {
            return FadeTransition(opacity: curved, child: child);
          }
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.96,
                end: 1.0,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  State<GuestMapExplorerSheet> createState() => _GuestMapExplorerSheetState();
}

class _GuestMapExplorerSheetState extends State<GuestMapExplorerSheet> {
  late Landmark? _selectedLandmark;
  final bool _isSwitchingZone = false;

  @override
  void initState() {
    super.initState();
    _selectedLandmark = widget.initialLandmark;
  }

  LatLng get _targetCenter {
    if (_selectedLandmark != null) {
      return LatLng(_selectedLandmark!.latitude, _selectedLandmark!.longitude);
    }
    return const LatLng(1.2136, -77.2811);
  }

  double get _targetZoom => _selectedLandmark != null ? 16.0 : 14.2;

  List<PastoParkingLot> get _visibleLots {
    if (_selectedLandmark != null) {
      return _selectedLandmark!.nearbyParkingLots;
    }
    return PastoDataService.getAllParkingLots().take(4).toList();
  }

  int get _availableSpotsCount {
    return _visibleLots.fold<int>(0, (sum, lot) => sum + lot.totalSpaces);
  }

  void _selectLandmark(Landmark? landmark) {
    if (_selectedLandmark?.id == landmark?.id) return;
    setState(() {
      _selectedLandmark = landmark;
    });
  }

  void _promptAuthForReservation(BuildContext context, PastoParkingLot lot) {
    MotionUtils.triggerHaptic(HapticType.successNotification);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.spacingMd),
            child: AppCard(
              borderRadius: DesignTokens.radiusCardLg,
              padding: const EdgeInsets.all(DesignTokens.spacingLg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: DesignTokens.brandAccent.withAlpha(35),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.qr_code_2_rounded,
                          color: DesignTokens.brandAccentOnLight,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: DesignTokens.spacingSm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reserva en ${lot.name}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: DesignTokens.headline(isDark),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${lot.formattedPrice} · ${lot.totalSpaces} cupos libres ahora',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: DesignTokens.caption(isDark),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Inicia sesión o crea tu cuenta gratis en 30 segundos para generar tu pase QR.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: DesignTokens.body(isDark),
                  ),
                  const SizedBox(height: DesignTokens.spacingMd),
                  PrimaryButton(
                    label: 'Iniciar sesión para reservar',
                    icon: Icons.login_rounded,
                    onPressed: () {
                      Navigator.of(sheetCtx).pop();
                      Navigator.of(context).pop();
                      context.push('/login');
                    },
                  ),
                  const SizedBox(height: DesignTokens.spacingXs),
                  SizedBox(
                    width: double.infinity,
                    height: DesignTokens.minTouchTarget,
                    child: OutlinedButton(
                      onPressed: () {
                        MotionUtils.triggerHaptic(HapticType.lightImpact);
                        Navigator.of(sheetCtx).pop();
                        Navigator.of(context).pop();
                        context.push('/register');
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: DesignTokens.outline(isDark),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Crear cuenta nueva',
                        style: DesignTokens.bodyBold(isDark),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final landmarks = PastoDataService.getLandmarks();
    final titleText = _selectedLandmark?.shortName ?? 'Mapa de Pasto';

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: DesignTokens.clampedTextScaler(context),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Container(
                margin: const EdgeInsets.only(top: DesignTokens.spacingMd),
                decoration: BoxDecoration(
                  color: isDark
                      ? DesignTokens.darkBackground
                      : DesignTokens.lightBackground,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(DesignTokens.radiusCardLg),
                  ),
                  border: Border.all(
                    color: DesignTokens.outline(isDark),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    // 1. Liquid Glass Top Header Bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        DesignTokens.spacingMd,
                        DesignTokens.spacingSm,
                        DesignTokens.spacingMd,
                        DesignTokens.spacingXs,
                      ),
                      child: GlassContainer(
                        borderRadius: DesignTokens.radiusCard,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: DesignTokens.spacingXs,
                        ),
                        child: Row(
                          children: [
                            if (widget.heroTag != null)
                              Hero(
                                tag: widget.heroTag!,
                                child: Material(
                                  type: MaterialType.transparency,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: DesignTokens.brandAccent,
                                      borderRadius: BorderRadius.circular(11),
                                    ),
                                    child: Icon(
                                      _selectedLandmark?.icon ??
                                          Icons.explore_rounded,
                                      color: DesignTokens.onBrandAccent,
                                      size: 19,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: DesignTokens.brandAccent,
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: Icon(
                                  _selectedLandmark?.icon ??
                                      Icons.explore_rounded,
                                  color: DesignTokens.onBrandAccent,
                                  size: 19,
                                ),
                              ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    titleText,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: DesignTokens.headline(isDark),
                                  ),
                                  Text(
                                    'Modo invitado · Explora sin registro',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: DesignTokens.caption(isDark),
                                  ),
                                ],
                              ),
                            ),
                            StatCounter(
                              value: _availableSpotsCount,
                              label: 'cupos',
                              isLoading: _isSwitchingZone,
                            ),
                            const SizedBox(width: 6),
                            Semantics(
                              button: true,
                              label: 'Cerrar mapa',
                              child: SizedBox(
                                width: DesignTokens.minTouchTarget,
                                height: DesignTokens.minTouchTarget,
                                child: IconButton(
                                  tooltip: 'Cerrar',
                                  onPressed: () {
                                    MotionUtils.triggerHaptic(
                                        HapticType.lightImpact);
                                    Navigator.of(context).pop();
                                  },
                                  icon: Icon(
                                    Icons.close_rounded,
                                    color: DesignTokens.onSurface(isDark),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 2. Interactive Zone Filter Chips (All 8 Pasto zones + "Todo Pasto")
                    SizedBox(
                      height: DesignTokens.minTouchTarget,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: DesignTokens.spacingMd,
                        ),
                        itemCount: landmarks.length + 1,
                        separatorBuilder: (_, _) =>
                            const SizedBox(width: DesignTokens.spacingXs),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            final isAllSelected = _selectedLandmark == null;
                            return MotionUtils.pressable(
                              onTap: () => _selectLandmark(null),
                              haptic: HapticType.selectionClick,
                              semanticLabel: 'Ver todo Pasto',
                              borderRadius: BorderRadius.circular(
                                  DesignTokens.radiusChip),
                              child: Container(
                                constraints: const BoxConstraints(
                                  minHeight: DesignTokens.minTouchTarget,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: DesignTokens.spacingSm,
                                ),
                                decoration: BoxDecoration(
                                  color: isAllSelected
                                      ? DesignTokens.brandAccent
                                      : DesignTokens.surfaceElevated(isDark),
                                  borderRadius: BorderRadius.circular(
                                      DesignTokens.radiusChip),
                                  border: Border.all(
                                    color: isAllSelected
                                        ? DesignTokens.brandAccent
                                        : DesignTokens.outline(isDark),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Todo Pasto',
                                  style: DesignTokens.caption(isDark).copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isAllSelected
                                        ? DesignTokens.onBrandAccent
                                        : DesignTokens.onSurface(isDark),
                                  ),
                                ),
                              ),
                            );
                          }

                          final lm = landmarks[index - 1];
                          final isSelected = _selectedLandmark?.id == lm.id;
                          return MotionUtils.pressable(
                            onTap: () => _selectLandmark(lm),
                            haptic: HapticType.selectionClick,
                            semanticLabel: 'Centrar mapa en ${lm.shortName}',
                            borderRadius:
                                BorderRadius.circular(DesignTokens.radiusChip),
                            child: Container(
                              constraints: const BoxConstraints(
                                minHeight: DesignTokens.minTouchTarget,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: DesignTokens.spacingSm,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? DesignTokens.brandAccent
                                    : DesignTokens.surfaceElevated(isDark),
                                borderRadius: BorderRadius.circular(
                                    DesignTokens.radiusChip),
                                border: Border.all(
                                  color: isSelected
                                      ? DesignTokens.brandAccent
                                      : DesignTokens.outline(isDark),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    lm.icon,
                                    size: 15,
                                    color: isSelected
                                        ? DesignTokens.onBrandAccent
                                        : DesignTokens.brandAccent,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    lm.shortName,
                                    style:
                                        DesignTokens.caption(isDark).copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? DesignTokens.onBrandAccent
                                          : DesignTokens.onSurface(isDark),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 3. Interactive Map + Nearby Parking Cards
                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                          DesignTokens.spacingMd,
                          0,
                          DesignTokens.spacingMd,
                          DesignTokens.spacingLg,
                        ),
                        children: [
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(DesignTokens.radiusCardLg),
                            child: Container(
                              height: 270,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    DesignTokens.radiusCardLg),
                                border: Border.all(
                                  color: DesignTokens.outline(isDark),
                                ),
                              ),
                              child: _isSwitchingZone
                                  ? Shimmer.fromColors(
                                      baseColor: isDark
                                          ? DesignTokens.darkSurface
                                          : const Color(0xFFE4E4E7),
                                      highlightColor: isDark
                                          ? DesignTokens.darkSurfaceElevated
                                          : const Color(0xFFF4F4F5),
                                      child: Container(color: Colors.white),
                                    )
                                  : AppMap(
                                      height: 270,
                                      showControls: true,
                                      initialCenter: _targetCenter,
                                      initialZoom: _targetZoom,
                                    ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'PARQUEADEROS CERCANOS EN ESTA ZONA',
                            style: DesignTokens.overline(isDark),
                          ),
                          const SizedBox(height: DesignTokens.spacingXs),
                          ..._visibleLots.map(
                            (lot) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: AppCard(
                                padding: const EdgeInsets.all(14),
                                onTap: () =>
                                    _promptAuthForReservation(context, lot),
                                semanticLabel:
                                    'Reservar en ${lot.name}, ${lot.formattedPrice}',
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: DesignTokens.brandAccent
                                            .withAlpha(30),
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                      child: const Icon(
                                        Icons.local_parking_rounded,
                                        color: DesignTokens.brandAccent,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(
                                        width: DesignTokens.spacingSm),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            lot.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                DesignTokens.bodyBold(isDark),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${lot.formattedPrice} · A ${lot.distanceMeters} m · ${lot.totalSpaces} cupos',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: DesignTokens.caption(isDark),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                        width: DesignTokens.spacingXs),
                                    Container(
                                      constraints: const BoxConstraints(
                                        minHeight: 38,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: DesignTokens.spacingSm,
                                        vertical: DesignTokens.spacingXs,
                                      ),
                                      decoration: BoxDecoration(
                                        color: DesignTokens.brandAccent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Reservar',
                                        style: DesignTokens.caption(isDark)
                                            .copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: DesignTokens.onBrandAccent,
                                        ),
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
