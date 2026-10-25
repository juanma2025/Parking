import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AvatarButton extends StatelessWidget {
  final String? avatarUrl;
  final String? initials;
  final VoidCallback? onTap;
  final double size;

  const AvatarButton({
    super.key,
    this.avatarUrl,
    this.initials,
    this.onTap,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      final url = avatarUrl!;
      if (url.startsWith('data:image')) {
        try {
          final base64String = url.split(',').last;
          final bytes = base64Decode(base64String);
          imageWidget = Image.memory(
            bytes,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _buildFallback(),
          );
        } catch (_) {
          imageWidget = _buildFallback();
        }
      } else if (url.startsWith('assets/')) {
        imageWidget = Image.asset(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildFallback(),
        );
      } else {
        imageWidget = Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildFallback(),
        );
      }
    } else {
      imageWidget = _buildFallback();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: ClipOval(child: imageWidget),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      color: AppColors.primary.withAlpha(40),
      alignment: Alignment.center,
      child: initials != null && initials!.isNotEmpty
          ? Text(
              initials!.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: size * 0.4,
                color: AppColors.darkCard,
              ),
            )
          : Icon(
              Icons.person_rounded,
              size: size * 0.6,
              color: AppColors.darkCard,
            ),
    );
  }
}
