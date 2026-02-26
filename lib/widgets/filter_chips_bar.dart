import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

const _filterData = [
  {'emoji': '🔥', 'label': '마감임박'},
  {'emoji': '⭐', 'label': '인기순'},
  {'emoji': '💰', 'label': '최저가순'},
  {'emoji': '🕐', 'label': '최신순'},
  {'emoji': '🚚', 'label': '무료배송'},
];

String _emojiFor(String label) {
  for (final entry in _filterData) {
    if (entry['label'] == label) return entry['emoji']!;
  }
  return '';
}

class FilterChipsBar extends StatelessWidget {
  final List<String> filters;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  const FilterChipsBar({
    super.key,
    required this.filters,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      color: AppColors.surface,
      child: Stack(
        children: [
          ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(
              left: 16,
              right: 8,
              top: 7,
              bottom: 7,
            ),
            itemCount: filters.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final filter = filters[index];
              final isActive = selected.contains(filter);
              final emoji = _emojiFor(filter);
              final label = emoji.isEmpty ? filter : '$emoji $filter';

              return GestureDetector(
                onTap: () => onToggle(filter),
                child: Container(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFFFFF3EC)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive
                          ? AppColors.primary
                          : const Color(0xFFE0E0E0),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      color: isActive
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
          // Gradient fade + arrow on the right edge
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Row(
              children: [
                IgnorePointer(
                  child: Container(
                    width: 32,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0x00FFFFFF),
                          Color(0xFFFFFFFF),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.only(right: 8),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
