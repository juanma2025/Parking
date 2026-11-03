import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/utils/motion_utils.dart';

class StepCarouselItemData {
  final String stepNumber;
  final IconData icon;
  final String title; // Máximo 5 palabras
  final String subtitle; // 1 sola línea de apoyo

  const StepCarouselItemData({
    required this.stepNumber,
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

/// Carrusel horizontal de 3 pasos con indicador de página animado (Fase 1-4):
/// - Icono grande outline uniforme + máximo 5 palabras de título + 1 línea de apoyo.
/// - Gestos naturales de swipe + tap en indicadores o tarjeta para avanzar con `HapticFeedback.selectionClick()`.
/// - Superficie adaptativa Light/Dark sin tarjetas blancas fijas en Dark Mode.
class StepCarousel extends StatefulWidget {
  final List<StepCarouselItemData> steps;
  final bool isLoading;

  const StepCarousel({
    super.key,
    required this.steps,
    this.isLoading = false,
  });

  @override
  State<StepCarousel> createState() => _StepCarouselState();
}

class _StepCarouselState extends State<StepCarousel> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.91);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    if (!mounted) return;
    final reduceMotion = MotionUtils.reduceMotion(context);
    MotionUtils.triggerHaptic(HapticType.selectionClick);
    if (reduceMotion) {
      _pageController.jumpToPage(index);
    } else {
      _pageController.animateToPage(
        index,
        duration: DesignTokens.durationNormal,
        curve: DesignTokens.springCurve,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.isLoading) {
      return Shimmer.fromColors(
        baseColor: isDark ? const Color(0xFF27272A) : const Color(0xFFE2E8F0),
        highlightColor:
            isDark ? const Color(0xFF3F3F46) : const Color(0xFFF8FAFC),
        child: Container(
          height: 118,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(DesignTokens.radiusCard),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabecera compacta con título e indicador de página interactivo
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  '¿CÓMO FUNCIONA?',
                  style: DesignTokens.overline(isDark),
                ),
                const SizedBox(width: 8),
                Text(
                  '· 3 pasos',
                  style: DesignTokens.caption(isDark),
                ),
              ],
            ),
            // Indicadores de página con área táctil accesible
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(widget.steps.length, (i) {
                final isActive = i == _currentIndex;
                return Semantics(
                  button: true,
                  selected: isActive,
                  label: 'Paso ${i + 1} de ${widget.steps.length}',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _goToPage(i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      child: AnimatedContainer(
                        duration: DesignTokens.durationFast,
                        curve: DesignTokens.springCurve,
                        width: isActive ? 22 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: isActive
                              ? DesignTokens.brandAccent
                              : DesignTokens.onSurfaceVariant(isDark)
                                  .withAlpha(75),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Carrusel horizontal con física nativa de rebote
        SizedBox(
          height: 116,
          child: PageView.builder(
            controller: _pageController,
            padEnds: false,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.steps.length,
            onPageChanged: (index) {
              if (_currentIndex != index) {
                setState(() => _currentIndex = index);
                MotionUtils.triggerHaptic(HapticType.selectionClick);
              }
            },
            itemBuilder: (context, index) {
              final step = widget.steps[index];
              final isSelected = index == _currentIndex;

              return Padding(
                padding: EdgeInsets.only(
                  right: index == widget.steps.length - 1 ? 0 : 12,
                ),
                child: MotionUtils.pressable(
                  haptic: HapticType.selectionClick,
                  semanticLabel:
                      'Paso ${step.stepNumber}: ${step.title}. ${step.subtitle}',
                  onTap: () {
                    final next = (index + 1) % widget.steps.length;
                    _goToPage(next);
                  },
                  child: AnimatedContainer(
                    duration: DesignTokens.durationFast,
                    curve: DesignTokens.springCurve,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: DesignTokens.surface(isDark),
                      borderRadius:
                          BorderRadius.circular(DesignTokens.radiusCardSm),
                      border: Border.all(
                        color: isSelected
                            ? DesignTokens.brandAccent.withAlpha(isDark ? 160 : 190)
                            : DesignTokens.outline(isDark),
                        width: isSelected ? 1.4 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(isDark ? 35 : 10),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Icono grande uniforme con badge de número
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: DesignTokens.brandAccent
                                .withAlpha(isDark ? 32 : 38),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: DesignTokens.brandAccent.withAlpha(90),
                              width: 1,
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                step.icon,
                                size: 26,
                                color: isDark
                                    ? DesignTokens.brandSecondary
                                    : DesignTokens.onBrandAccent,
                              ),
                              Positioned(
                                top: 4,
                                right: 5,
                                child: Text(
                                  step.stepNumber,
                                  style: TextStyle(
                                    fontFamily: DesignTokens.fontFamily,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    color: DesignTokens.accentText(isDark),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: DesignTokens.headline(isDark).copyWith(
                                  fontSize: 15.0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                step.subtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: DesignTokens.caption(isDark).copyWith(
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: DesignTokens.onSurfaceVariant(isDark),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

