import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final LinearGradient? gradient;
  final double? borderRadius;
  final BoxBorder? border;
  final Color? backgroundColor;

  const CustomCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.gradient,
    this.borderRadius,
    this.border,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null
            ? backgroundColor ?? AppColors.white
            : null,
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
        border: border,
        boxShadow: [
          BoxShadow(
            color: AppColors.lightGrey.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = isOutlined
        ? OutlinedButton.styleFrom(
            foregroundColor: backgroundColor ?? AppColors.primaryPastel,
            side: BorderSide(color: backgroundColor ?? AppColors.primaryPastel, width: 1.5),
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 12),
            ),
            textStyle: AppTypography.button,
          )
        : ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppColors.primaryPastel,
            foregroundColor: textColor ?? AppColors.white,
            elevation: 0,
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 12),
            ),
            textStyle: AppTypography.button,
          );

    return isOutlined
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        backgroundColor ?? AppColors.primaryPastel,
                      ),
                    ),
                  )
                : Text(text),
          )
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        textColor ?? AppColors.white,
                      ),
                    ),
                  )
                : Text(text),
          );
  }
}