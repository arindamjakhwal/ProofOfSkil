import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/helpers.dart';

class AvatarWidget extends StatelessWidget {
  final String name;
  final double size;
  final Color? backgroundColor;

  const AvatarWidget({
    super.key,
    required this.name,
    this.size = 48,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primaryLight,
        borderRadius: BorderRadius.circular(size * 0.35),
      ),
      child: Center(
        child: Text(
          Helpers.initials(name),
          style: TextStyle(
            color: backgroundColor != null ? Colors.white : AppColors.primary,
            fontSize: size * 0.36,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
