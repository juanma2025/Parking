import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class BottomBarItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const BottomBarItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class BottomBar5 extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomBarItemData> items;
  final bool hasCenterAction;
  final VoidCallback? onCenterAction;

  const BottomBar5({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.hasCenterAction = true,
    this.onCenterAction,
  });

  @override
  State<BottomBar5> createState() => _BottomBar5State();
}

class _BottomBar5State extends State<BottomBar5> {
  double _centerScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      height: 68.0,
      decoration: BoxDecoration(
        color: AppColors.primary, // #FBAB56
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(80),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(widget.items.length, (index) {
          final isCenter = widget.hasCenterAction && index == 2;
          final item = widget.items[index];
          final isSelected = widget.currentIndex == index;

          if (isCenter) {
            return AnimatedScale(
              scale: _centerScale,
              duration: const Duration(milliseconds: 100),
              child: GestureDetector(
                onTapDown: (_) => setState(() => _centerScale = 0.92),
                onTapUp: (_) => setState(() => _centerScale = 1.0),
                onTapCancel: () => setState(() => _centerScale = 1.0),
                onTap: widget.onCenterAction ?? () => widget.onTap(index),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: AppColors.darkCard,
                    size: 28,
                  ),
                ),
              ),
            );
          }

          return IconButton(
            icon: Icon(
              isSelected ? item.activeIcon : item.icon,
              color: isSelected ? AppColors.darkCard : AppColors.darkCard.withAlpha(160),
              size: 26,
            ),
            onPressed: () => widget.onTap(index),
            tooltip: item.label,
          );
        }),
      ),
    );
  }
}
