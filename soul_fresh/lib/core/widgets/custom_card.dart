import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final BorderRadiusGeometry? borderRadius;

  const CustomCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor = AppColors.white,
    this.borderColor = AppColors.mediumGrey,
    this.onTap,
    this.border,
    this.boxShadow,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final cardBorder =
        border ?? Border.all(color: borderColor ?? AppColors.mediumGrey);

    final cardRadius = borderRadius ?? BorderRadius.circular(20);

    final container = Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: cardBorder is Border ? cardBorder : null,
        borderRadius: cardRadius,
        boxShadow: boxShadow,
      ),
      padding: padding,
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: cardRadius is BorderRadius ? cardRadius : null,
          child: container,
        ),
      );
    }

    return container;
  }
}
