import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../data/mock_data.dart';
import '../models/fund.dart';
import '../widgets/gnb.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/category_tabs.dart';
import '../widgets/filter_chips_bar.dart';
import '../widgets/fund_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;
  final Set<String> _activeFilters = {};

  List<Fund> get _filteredFunds {
    // Step 1: filter by category
    List<Fund> result;
    if (_selectedCategoryIndex == 0) {
      result = List<Fund>.from(mockFunds);
    } else {
      final cat = categories[_selectedCategoryIndex];
      result = mockFunds.where((f) => f.category == cat).toList();
    }

    // Step 2: apply filter chips (order matters — filtering before sorting)
    if (_activeFilters.contains('마감임박')) {
      result = result.where((f) => f.status == 'ending_soon').toList();
    }
    if (_activeFilters.contains('무료배송')) {
      result = result.where((f) => f.freeShipping).toList();
    }

    // Step 3: sorting (mutually exclusive intent, last toggled wins via Set order)
    if (_activeFilters.contains('인기순')) {
      result.sort((a, b) => b.currentParticipants.compareTo(a.currentParticipants));
    } else if (_activeFilters.contains('최저가순')) {
      result.sort((a, b) => a.targetPrice.compareTo(b.targetPrice));
    } else if (_activeFilters.contains('최신순')) {
      result.sort((a, b) => b.endAt.compareTo(a.endAt));
    }

    return result;
  }

  void _toggleFilter(String filter) {
    setState(() {
      if (_activeFilters.contains(filter)) {
        _activeFilters.remove(filter);
      } else {
        // For sort filters, remove other sort filters before adding new one
        const sortFilters = {'인기순', '최저가순', '최신순'};
        if (sortFilters.contains(filter)) {
          _activeFilters.removeAll(sortFilters);
        }
        _activeFilters.add(filter);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 960;
    final isMobile = screenWidth <= 768;
    final columnCount = isMobile ? 2 : 3;
    final funds = _filteredFunds;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Fixed GNB at top
          GNB(
            activeNavIndex: 0,
            onLogoTap: () {},
            onSearch: () {},
            onCart: () {},
            onLogin: () {},
          ),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Banner (full width)
                  const BannerCarousel(),

                  // Content area with max-width constraint
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1280),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: isDesktop
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _buildMainContent(funds, columnCount),
                                  ),
                                  const SizedBox(width: 24),
                                  SizedBox(
                                    width: 280,
                                    child: _buildSidePanel(),
                                  ),
                                ],
                              )
                            : _buildMainContent(funds, columnCount),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(List<Fund> funds, int columnCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        const Padding(
          padding: EdgeInsets.fromLTRB(0, 20, 0, 12),
          child: Text(
            '오늘의 추천 딜',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        // Category tabs
        CategoryTabs(
          categories: categories,
          selectedIndex: _selectedCategoryIndex,
          onSelected: (i) => setState(() => _selectedCategoryIndex = i),
        ),
        const SizedBox(height: 12),

        // Filter chips
        FilterChipsBar(
          filters: filters,
          selected: _activeFilters,
          onToggle: _toggleFilter,
        ),
        const SizedBox(height: 12),

        // Card grid
        _buildCardGrid(funds, columnCount),

        // Bottom padding
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildCardGrid(List<Fund> funds, int columnCount) {
    if (funds.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 64),
        child: _EmptyState(),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final cardWidth =
            (constraints.maxWidth - spacing * (columnCount - 1)) / columnCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: funds.asMap().entries.map((entry) {
            final index = entry.key;
            final fund = entry.value;
            return SizedBox(
              width: cardWidth,
              child: FundCard(
                fund: fund,
                showProgressOverlay: index == 0,
                onTap: () =>
                    Navigator.pushNamed(context, '/fund/${fund.id}'),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildSidePanel() {
    if (mockFunds.isEmpty) return const SizedBox.shrink();

    final featured = mockFunds.first;
    final upcoming = mockFunds.length > 2
        ? mockFunds.sublist(mockFunds.length - 2)
        : mockFunds.skip(1).toList();

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Featured product ───────────────────────────────────────────
          const Text(
            '지금 가장 인기있는 딜',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.asset(
                    featured.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, _) => Container(
                      color: AppColors.background,
                      child: const Center(
                        child: Icon(
                          Icons.fastfood,
                          size: 36,
                          color: AppColors.textDisabled,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        featured.productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${featured.discountPercent}%',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentRed,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatPrice(featured.targetPrice),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatPrice(featured.startPrice),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Upcoming section ───────────────────────────────────────────
          const Text(
            '다음 공동구매 미리보기',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),

          ...upcoming.map(
            (fund) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _UpcomingCard(fund: fund),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    final str = price.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return '${buffer.toString()}원';
  }
}

// ─── Upcoming card (horizontal, small) ────────────────────────────────────────

class _UpcomingCard extends StatelessWidget {
  final Fund fund;

  const _UpcomingCard({required this.fund});

  String _formatPrice(int price) {
    final str = price.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return '${buffer.toString()}원';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 60,
              height: 60,
              child: Image.asset(
                fund.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, _) => Container(
                  color: AppColors.background,
                  child: const Center(
                    child: Icon(
                      Icons.fastfood,
                      size: 24,
                      color: AppColors.textDisabled,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fund.brandName,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  fund.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatPrice(fund.targetPrice),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentRed,
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

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: AppColors.textDisabled,
          ),
          SizedBox(height: 16),
          Text(
            '해당 조건의 공구가 없어요',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '다른 카테고리나 필터를 선택해보세요',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textDisabled,
            ),
          ),
        ],
      ),
    );
  }
}
