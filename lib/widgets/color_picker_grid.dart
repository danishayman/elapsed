import 'package:flutter/material.dart';
import '../theme.dart';

class ColorPickerGrid extends StatelessWidget {
  final List<String> colors;
  final String selectedColor;
  final ValueChanged<String> onColorSelected;

  const ColorPickerGrid({
    super.key,
    required this.colors,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: colors.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final hex = colors[index];
        final color = Color(
          int.parse('FF${hex.replaceFirst('#', '')}', radix: 16),
        );
        final isSelected = hex == selectedColor;

        return GestureDetector(
          onTap: () => onColorSelected(hex),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: kTextPrimary, width: 2)
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: kTextPrimary, size: 18)
                : null,
          ),
        );
      },
    );
  }
}
