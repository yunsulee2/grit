import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/app_radius.dart';
import '../data/mock_data.dart';
import '../models/fund.dart';
import '../widgets/gnb.dart';
import '../widgets/fund_card.dart';
import '../widgets/responsive_container.dart';

// All category labels shown as filter chips
const _kCategories = [
  '전체',
  '닭가슴살',
  '프로틴',
  '간식/간편식',
  '음료',
  '도시락',
  '샐러드',
  '소스/시즌닝',
  '운동용품',
  '보충제',
];

enum _SortOption {
  popular('인기순'),
  newest('최신순'),
  priceLow('가격낮은순'),
  priceHigh('가격높은순');

  const _SortOption(this.label);
  final String label;
}

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  int _selectedCategoryIndex = 0;
  _SortOption _sortOption = _SortOption.popular;

  List<Fund> get _filteredFunds {
    // Category filter
    List<Fund> result;
    if (_selectedCategoryIndex == 0) {
      result = List<Fund>.from(mockFunds);
    } else {
      final cat = _kCategories[_selectedCategoryIndex];
      result = mockFunds.where((f) => f.category == cat).toList();
    }

    // Sort
    switch (_sortOption) {
      case _SortOption.popular:
        result.sort((a, b) => b.currentParticipants.compareTo(a.currentParticipants));
      case _SortOption.newest:
        result.sort((a, b) => b.endAt.compareTo(a.endAt));
      case _SortOption.priceLow:
        result.sort((a, b) => a.targetPrice.compareTo(b.targetPrice));
      case _SortOption.priceHigh:
        result.sort((a, b) => b.targetPrice.compareTo(a.targetPrice));
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final funds = _filteredFunds;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          GNB(
            activeNavIndex: 1,
            onLogoTap: () {},
            onSearch: () {},
            onCart: () {},
            onLogin: () {},
          ),
          Expanded(
            child: ResponsiveContainer.content(
              child: CustomScrollView(
                slivers: [
                  // Page title
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.xs),
                      child: Text(
                        '카테고리',
                        style: AppTextStyles.titleLarge,
                      ),
                    ),
                  ),

                  // Horizontal category filter chips
                  SliverToBoxAdapter(
                    child: _CategoryChipsBar(
                      categories: _kCategories,
                      selectedIndex: _selectedCategoryIndex,
                      onSelected: (i) => setState(() => _selectedCategoryIndex = i),
                    ),
                  ),

                  // Sort row + result count
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.xs),
                      child: Row(
                        children: [
                          Text(
                            '총 ${funds.length}개',
                            style: AppTextStyles.bodyMedium,
                          ),
                          const Spacer(),
                          _SortDropdown(
                            value: _sortOption,
                            onChanged: (v) => setState(() => _sortOption = v),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Grid or empty state
                  funds.isEmpty
                      ? const SliverFillRemaining(
                          child: _EmptyState(),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.fromLTRB(
                              AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.xxxl),
                          sliver: _FundGrid(funds: funds),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Category chips bar ────────────────────────────────────────────────────────

class _CategoryChipsBar extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _CategoryChipsBar({
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          final selected = i == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.surface,
                borderRadius: AppRadius.borderFull,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                categories[i],
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected ? AppColors.surface : AppColors.textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Sort dropdown ─────────────────────────────────────────────────────────────

class _SortDropdown extends StatelessWidget {
  final _SortOption value;
  final ValueChanged<_SortOption> onChanged;

  const _SortDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderSm,
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<_SortOption>(
          value: value,
          isDense: true,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: AppColors.textSecondary,
          ),
          items: _SortOption.values
              .map(
                (opt) => DropdownMenuItem(
                  value: opt,
                  child: Text(opt.label),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

// ─── Fund grid (2-column) ──────────────────────────────────────────────────────

class _FundGrid extends StatelessWidget {
  final List<Fund> funds;

  const _FundGrid({required this.funds});

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, i) => FundCard(
          fund: funds[i],
          showProgressOverlay: false,
          onTap: () =>
              Navigator.pushNamed(context, '/fund/${funds[i].id}'),
        ),
        childCount: funds.length,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.68,
      ),
    );
  }
}

// ─── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            '해당 카테고리의 공구가 없어요',
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '다른 카테고리를 선택해보세요',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}
