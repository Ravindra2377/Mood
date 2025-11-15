import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class CustomInputField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final String? Function(String?)? validator;
  final int maxLines;
  final int minLines;

  const CustomInputField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.validator,
    this.maxLines = 1,
    this.minLines = 1,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTypography.label.copyWith(
            color: AppColors.charcoal,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: _isObscured,
          maxLines: _isObscured ? 1 : widget.maxLines,
          minLines: widget.minLines,
          validator: widget.validator,
          style: AppTypography.body1.copyWith(
            color: AppColors.charcoal,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: AppColors.darkGrey)
                : null,
            suffixIcon: widget.obscureText
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                    child: Icon(
                      _isObscured ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.darkGrey,
                    ),
                  )
                : widget.suffixIcon != null
                    ? GestureDetector(
                        onTap: widget.onSuffixTap,
                        child: Icon(
                          widget.suffixIcon,
                          color: AppColors.darkGrey,
                        ),
                      )
                    : null,
            filled: true,
            fillColor: AppColors.lightGrey,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.mediumGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.mediumGrey,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.primaryPastel,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
