import 'package:flutter/material.dart';
import 'package:mivi/presentation/core/app_colors.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool autofocus;

  const CustomSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outline.withOpacity(0.3),
        ),
      ),
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        style: const TextStyle(
          color: AppColors.onSurface,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: hintText ?? 'Search movies...',
          hintStyle: TextStyle(
            color: AppColors.onSurface.withOpacity(0.6),
            fontSize: 16,
          ),
          prefixIcon: prefixIcon ??
              Icon(
                Icons.search,
                color: AppColors.onSurface.withOpacity(0.6),
              ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
} 