import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool isOutlined;
  final double borderRadius;
  final EdgeInsets padding;

  const CustomButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isOutlined = false,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.primaryPastel;
    final tColor = textColor ?? AppColors.charcoal;

    if (isOutlined) {
      return OutlinedButton.icon(
        onPressed: (isLoading || isDisabled) ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : Icon(icon),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: bgColor, width: 2),
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          foregroundColor: bgColor,
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: (isLoading || isDisabled) ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isDisabled ? AppColors.mediumGrey : bgColor,
        foregroundColor: tColor,
        elevation: 0,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}