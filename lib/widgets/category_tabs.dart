import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CategoryTabs extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const CategoryTabs({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine if we need smaller text to fit all tabs
        // Rough estimate: if more than 6 categories, shrink font
        final fontSize = categories.length > 6 ? 11.0 : 13.0;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          height: 44,
          child: Row(
            children: List.generate(categories.length, (i) {
              final isActive = i == selectedIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onSelected(i),
                  child: Container(
                    margin: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF1A1A1A)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      categories[i],
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.normal,
                        color: isActive
                            ? Colors.white
                            : const Color(0xFF666666),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
