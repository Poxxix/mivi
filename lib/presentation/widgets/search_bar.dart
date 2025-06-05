import 'package:flutter/material.dart';
import 'package:mivi/presentation/core/app_colors.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final VoidCallback? onBackPressed;
  final String hintText;
  final bool autofocus;

  const SearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onClear,
    this.onBackPressed,
    this.hintText = 'Search movies...',
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (onBackPressed != null)
            IconButton(
              onPressed: onBackPressed,
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.onSurface,
              ),
            ),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              autofocus: autofocus,
              style: const TextStyle(
                color: AppColors.onSurface,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: AppColors.onSurface.withOpacity(0.5),
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          if (controller.text.isNotEmpty && onClear != null)
            IconButton(
              onPressed: () {
                controller.clear();
                onClear?.call();
              },
              icon: const Icon(
                Icons.clear,
                color: AppColors.onSurface,
              ),
            ),
          IconButton(
            onPressed: () {
              // Implement search functionality
            },
            icon: const Icon(
              Icons.search,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
} 