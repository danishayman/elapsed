import 'package:flutter/material.dart';

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
                  ? Border.all(color: Colors.white, width: 2.5)
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
          ),
        );
      },
    );
  }
}
