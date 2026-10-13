import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/domain_entities.dart';

class SpaceTile extends StatelessWidget {
  final String spaceNumber;
  final String vehicleType;
  final ParkingSpaceStatus status;
  final VoidCallback? onTap;

  const SpaceTile({
    super.key,
    required this.spaceNumber,
    required this.vehicleType,
    required this.status,
    this.onTap,
  });

  IconData _getVehicleIcon(String type) {
    final lower = type.toLowerCase();
    if (lower.contains('moto')) return Icons.two_wheeler_rounded;
    if (lower.contains('bici')) return Icons.pedal_bike_rounded;
    if (lower.contains('camion') || lower.contains('van')) return Icons.local_shipping_rounded;
    return Icons.directions_car_rounded;
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Color iconColor;
    String statusText;
    BoxBorder? border;
    double opacity = 1.0;
    Widget? extraIcon;

    switch (status) {
      case ParkingSpaceStatus.available:
        bgColor = AppColors.secondary; // Amber #FEC775
        textColor = AppColors.darkCard;
        iconColor = AppColors.darkCard;
        statusText = 'LIBRE';
        break;

      case ParkingSpaceStatus.occupied:
        bgColor = AppColors.spaceOccupied; // #3A3A3A
        textColor = AppColors.white;
        iconColor = AppColors.white.withAlpha(200);
        statusText = 'OCUPADO';
        break;

      case ParkingSpaceStatus.maintenance:
        bgColor = AppColors.white;
        textColor = AppColors.spaceMaintenance;
        iconColor = AppColors.spaceMaintenance;
        statusText = 'MANTENIMIENTO';
        border = Border.all(
          color: AppColors.spaceMaintenance,
          width: 2.0,
          style: BorderStyle.solid,
        );
        extraIcon = const Icon(
          Icons.build_rounded, // Wrench icon
          size: 16,
          color: AppColors.spaceMaintenance,
        );
        break;

      case ParkingSpaceStatus.inactive:
        bgColor = Colors.grey.shade300;
        textColor = AppColors.spaceInactive;
        iconColor = AppColors.spaceInactive;
        statusText = 'INACTIVO';
        opacity = 0.55;
        break;
    }

    final content = AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(milliseconds: 200),
      child: Container(
        height: 104,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: border,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(_getVehicleIcon(vehicleType), color: iconColor, size: 20),
                if (extraIcon != null)
                  extraIcon
                else
                  Text(
                    statusText,
                    style: AppTypography.sectionLabel.copyWith(
                      color: textColor,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
            Text(
              spaceNumber,
              style: AppTypography.title.copyWith(
                color: textColor,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
