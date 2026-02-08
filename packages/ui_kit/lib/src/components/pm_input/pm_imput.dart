import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

class PMInput extends StatelessWidget {
  final String label;
  final String hint;
  final bool obscureText;
  final TextEditingController? controller;

  const PMInput({
    super.key,
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(label, style: context.texts.titleMedium?.copyWith(fontWeight: FontWeight.w600)),

        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            isDense: true,
            fillColor: context.colors.secondaryContainer,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            hintStyle: context.texts.bodyLarge?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.5),
            ),
          ),
          style: context.texts.bodyLarge?.copyWith(color: context.colors.onSurface),
        ),
      ],
    );
  }
}
