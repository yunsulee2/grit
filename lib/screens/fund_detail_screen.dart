import 'dart:async';
import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/fund.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import '../widgets/option_bottom_sheet.dart';
import '../widgets/volume_pricing_bar.dart';
import '../widgets/price_tier_label.dart';

class FundDetailScreen extends StatefulWidget {
  final String fundId;

  const FundDetailScreen({super.key, required this.fundId});

  @override
  State<FundDetailScreen> createState() => _FundDetailScreenState();
}

class _FundDetailScreenState extends State<FundDetailScreen> {
  int _quantity = 1;
  late Timer _timer;
  late Duration _remaining;

  Fund? get _fund =>
      mockFunds.where((f) => f.id == widget.fundId).firstOrNull;

  @override
  void initState() {
    super.initState();
    final fund = _fund;
    _remaining = fund != null
        ? fund.endAt.difference(DateTime.now())
        : Duration.zero;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final fund = _fund;
      if (fund != null) {
        setState(() {
          _remaining = fund.endAt.difference(DateTime.now());
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatCountdown(Duration d) {
    if (d.isNegative) return '마감';
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  void _onParticipate(Fund fund) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 960) {
      OptionBottomSheet.show(
        context,
        fund: fund,
        onParticipate: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/fund/${fund.id}/complete');
        },
      );
    } else {
      Navigator.pushNamed(context, '/fund/${fund.id}/complete');
    }
  }

  @override
  Widget build(BuildContext context) {
    final fund = _fund;

    if (fund == null) {
      return Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: const Text('상품 없음'),
        ),
        body: const Center(
          child: Text(
            '상품을 찾을 수 없습니다.',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 960;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // 1. Brand top bar
          _BrandTopBar(
            brandName: fund.brandName,
            onBack: () => Navigator.pop(context),
          ),

          // 2. Store navigation tabs
          const _StoreNavTabs(),

          // 3. Breadcrumb
          _Breadcrumb(category: fund.category, productName: fund.productName),

          // 4. Main scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: isDesktop
                        ? _buildDesktopLayout(fund)
                        : _buildMobileLayout(fund),
                  ),
                ),
              ),
            ),
          ),

          // 5. Mobile bottom CTA bar
          if (!isDesktop)
            _MobileCtaBar(
              fund: fund,
              onParticipate: () => _onParticipate(fund),
            ),
        ],
      ),
    );
  }

  // ─── Desktop: 3-column layout ──────────────────────────────────────────────

  Widget _buildDesktopLayout(Fund fund) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT: Product image
          SizedBox(
            width: 450,
            child: _ProductImageSection(
              fund: fund,
              remaining: _remaining,
              formatCountdown: _formatCountdown,
            ),
          ),
          const SizedBox(width: 32),

          // CENTER: Product info + pricing
          Expanded(
            child: _ProductInfoCenter(fund: fund),
          ),
          const SizedBox(width: 32),

          // RIGHT: Option sidebar
          SizedBox(
            width: 280,
            child: _OptionSidebar(
              fund: fund,
              quantity: _quantity,
              onDecrement: () {
                if (_quantity > 1) setState(() => _quantity--);
              },
              onIncrement: () => setState(() => _quantity++),
              onParticipate: () => _onParticipate(fund),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Mobile: stacked layout ────────────────────────────────────────────────

  Widget _buildMobileLayout(Fund fund) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        // Product image (constrained, not full-bleed)
        _ProductImageSection(
          fund: fund,
          remaining: _remaining,
          formatCountdown: _formatCountdown,
        ),
        const SizedBox(height: 16),
        // Product info
        _ProductInfoCenter(fund: fund),
        const SizedBox(height: 12),
        // Volume pricing detail
        _VolumePricingCard(fund: fund),
        const SizedBox(height: 12),
        // Fund info
        _FundInfoCard(fund: fund),
        const SizedBox(height: 12),
        // Product detail
        _ProductDetailCard(fund: fund),
        const SizedBox(height: 80), // space for bottom CTA
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Brand Top Bar — centered brand name with back/share/cart actions
// ═══════════════════════════════════════════════════════════════════════════════

class _BrandTopBar extends StatelessWidget {
  final String brandName;
  final VoidCallback onBack;

  const _BrandTopBar({required this.brandName, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Center: brand name + store info
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    brandName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 1),
                  const Text(
                    '스토어정보 >',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              // Left: back button
              Positioned(
                left: 4,
                child: IconButton(
                  onPressed: onBack,
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 20,
                    color: AppColors.secondary,
                  ),
                ),
              ),
              // Right: share + cart
              Positioned(
                right: 4,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('링크가 복사되었습니다!'),
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.share_outlined,
                        size: 20,
                        color: AppColors.secondary,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.shopping_cart_outlined,
                        size: 20,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Store Navigation Tabs — 톡딜 style (홈, 베스트, 기획전, ...)
// ═══════════════════════════════════════════════════════════════════════════════

class _StoreNavTabs extends StatelessWidget {
  const _StoreNavTabs();

  static const _tabs = ['홈', '베스트', '기획전', '라이브', '공지사항', '카테고리'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            for (int i = 0; i < _tabs.length; i++) ...[
              if (i > 0) const SizedBox(width: 24),
              Center(
                child: Text(
                  _tabs[i],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: i == 0 ? FontWeight.bold : FontWeight.normal,
                    color: i == 0
                        ? AppColors.secondary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Breadcrumb — 홈 > 카테고리 > 상품명
// ═══════════════════════════════════════════════════════════════════════════════

class _Breadcrumb extends StatelessWidget {
  final String category;
  final String productName;

  const _Breadcrumb({required this.category, required this.productName});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Row(
            children: [
              const Text(
                '홈',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const _BreadcrumbArrow(),
              Text(
                category,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
              const _BreadcrumbArrow(),
              Flexible(
                child: Text(
                  productName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BreadcrumbArrow extends StatelessWidget {
  const _BreadcrumbArrow();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 6),
      child: Icon(
        Icons.chevron_right,
        size: 14,
        color: AppColors.textDisabled,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Product Image Section — main image with timer badge + thumbnail strip
// ═══════════════════════════════════════════════════════════════════════════════

class _ProductImageSection extends StatelessWidget {
  final Fund fund;
  final Duration remaining;
  final String Function(Duration) formatCountdown;

  const _ProductImageSection({
    required this.fund,
    required this.remaining,
    required this.formatCountdown,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main image with timer badge
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  fund.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, _) => Container(
                    color: const Color(0xFFE5E5E5),
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                // Timer badge — top left
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xCC000000),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '종료까지 ${formatCountdown(remaining)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Thumbnail strip (single image repeated as placeholder)
        SizedBox(
          height: 64,
          child: Row(
            children: [
              _Thumbnail(imageUrl: fund.imageUrl, isSelected: true),
              const SizedBox(width: 8),
              _Thumbnail(imageUrl: fund.imageUrl, isSelected: false),
              const SizedBox(width: 8),
              _Thumbnail(imageUrl: fund.imageUrl, isSelected: false),
            ],
          ),
        ),
      ],
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final String imageUrl;
  final bool isSelected;

  const _Thumbnail({required this.imageUrl, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Image.asset(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, _) => Container(
            color: const Color(0xFFE5E5E5),
            child: const Icon(Icons.image, size: 20, color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Product Info Center — name, origin, price, progress summary
// ═══════════════════════════════════════════════════════════════════════════════

class _ProductInfoCenter extends StatelessWidget {
  final Fund fund;

  const _ProductInfoCenter({required this.fund});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand name
          Text(
            fund.brandName,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),

          // Product name
          Text(
            fund.productName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '원산지: 국내산',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 16),

          // Price section
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Discount badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accentRed,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${fund.discountPercent}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Target price (big)
              Text(
                formatPrice(fund.targetPrice),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Original price strikethrough
          Text(
            formatPrice(fund.startPrice),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              decoration: TextDecoration.lineThrough,
              decorationColor: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 20),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 16),

          // Volume pricing progress
          const Text(
            '공동구매 진행률',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 12),
          VolumePricingBar(
            tiers: fund.tiers,
            currentParticipants: fund.currentParticipants,
            maxParticipants: fund.maxParticipants,
            isLarge: true,
          ),
          const SizedBox(height: 8),
          PriceTierLabel(
            tiers: fund.tiers,
            currentParticipants: fund.currentParticipants,
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),

          // Discount breakdown rows
          _InfoDetailRow(
            label: '공동 할인 (수량 비례)',
            value: '-${formatPrice(fund.startPrice - fund.targetPrice)}',
            valueColor: AppColors.accentRed,
          ),
          const SizedBox(height: 8),
          const _InfoDetailRow(
            label: '첫 구매 적립',
            value: '+ 500P',
            valueColor: AppColors.successGreen,
          ),
          if (fund.freeShipping) ...[
            const SizedBox(height: 8),
            const _InfoDetailRow(
              label: '배송비',
              value: '무료',
              valueColor: AppColors.successGreen,
            ),
          ],

          const SizedBox(height: 16),

          // Share promotion banner
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEBF5FB),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.group_outlined,
                    size: 18, color: Color(0xFF2980B9)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '친구에게 공유하면 함께 더 싸게!',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF2980B9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('링크가 복사되었습니다!'),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2980B9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '공유하기',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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

class _InfoDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _InfoDetailRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style:
              const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Option Sidebar (Desktop) — option select, quantity, CTA button
// ═══════════════════════════════════════════════════════════════════════════════

class _OptionSidebar extends StatelessWidget {
  final Fund fund;
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onParticipate;

  const _OptionSidebar({
    required this.fund,
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
    required this.onParticipate,
  });

  @override
  Widget build(BuildContext context) {
    final totalPrice = fund.startPrice * quantity;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          const Text(
            '옵션 선택',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 12),

          // Option dropdown
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    fund.productName,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.secondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down,
                    size: 20, color: AppColors.textSecondary),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quantity row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '수량',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SidebarStepperBtn(
                    icon: Icons.remove,
                    enabled: quantity > 1,
                    onTap: onDecrement,
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '$quantity',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  _SidebarStepperBtn(
                    icon: Icons.add,
                    enabled: true,
                    onTap: onIncrement,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),

          // Delivery info
          const Text(
            '배송방법: 직접배송',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            fund.freeShipping ? '배송비: 무료' : '배송비: 유료',
            style:
                const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),

          // Price summary
          Text(
            formatPrice(fund.startPrice),
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              decoration: TextDecoration.lineThrough,
              decorationColor: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '총 주문금액',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
              Text(
                formatPrice(totalPrice),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentRed,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // CTA button — Orange like 톡딜
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: onParticipate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '공동구매 참여하기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarStepperBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _SidebarStepperBtn({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border.all(
            color: enabled ? AppColors.border : AppColors.textDisabled,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? AppColors.secondary : AppColors.textDisabled,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Mobile CTA Bar — fixed bottom bar for mobile
// ═══════════════════════════════════════════════════════════════════════════════

class _MobileCtaBar extends StatelessWidget {
  final Fund fund;
  final VoidCallback onParticipate;

  const _MobileCtaBar({required this.fund, required this.onParticipate});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Price display
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatPrice(fund.startPrice),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        formatPrice(fund.targetPrice),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentRed,
                        ),
                      ),
                    ],
                  ),
                ),
                // CTA button
                SizedBox(
                  height: 48,
                  width: 180,
                  child: ElevatedButton(
                    onPressed: onParticipate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '공동구매 참여하기',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Volume Pricing Card (Mobile only — desktop shows in center column)
// ═══════════════════════════════════════════════════════════════════════════════

class _VolumePricingCard extends StatelessWidget {
  final Fund fund;

  const _VolumePricingCard({required this.fund});

  @override
  Widget build(BuildContext context) {
    final discountAmount = fund.startPrice - fund.targetPrice;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_offer_outlined,
                  size: 16, color: AppColors.accentRed),
              const SizedBox(width: 6),
              const Text(
                '할인 & 적립',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoDetailRow(
            label: '공동 할인',
            value: '-${formatPrice(discountAmount)}',
            valueColor: AppColors.accentRed,
          ),
          const SizedBox(height: 6),
          const _InfoDetailRow(
            label: '첫 구매 적립',
            value: '+ 500P',
            valueColor: AppColors.successGreen,
          ),
          if (fund.freeShipping) ...[
            const SizedBox(height: 6),
            const _InfoDetailRow(
              label: '배송비',
              value: '무료',
              valueColor: AppColors.successGreen,
            ),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '총 주문금액',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
              Text(
                formatPrice(fund.targetPrice),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Fund Info Card (Mobile only)
// ═══════════════════════════════════════════════════════════════════════════════

class _FundInfoCard extends StatelessWidget {
  final Fund fund;

  const _FundInfoCard({required this.fund});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final end = fund.endAt;
    final startShort = '${now.month}/${now.day} 00:00';
    final endShort =
        '${end.month}/${end.day} ${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              const Text(
                '공구 안내',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Date banner
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFCC80)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.access_time,
                    size: 15, color: Color(0xFFF57C00)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '$startShort ~ $endShort 까지 한정판매!',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFF57C00),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _FundInfoRow(label: '혜택', content: '첫 구매 적립 500P'),
          const Divider(height: 1, color: AppColors.border),
          _FundInfoRow(label: '상품정보', content: '1인 최대 5개 구매 가능'),
          const Divider(height: 1, color: AppColors.border),
          _FundInfoRow(
            label: '배송',
            content: fund.freeShipping
                ? '무료배송  |  주문 후 2~3일 이내'
                : '유료배송  |  주문 후 2~3일 이내',
          ),
        ],
      ),
    );
  }
}

class _FundInfoRow extends StatelessWidget {
  final String label;
  final String content;

  const _FundInfoRow({required this.label, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 68,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Product Detail Card (Mobile only)
// ═══════════════════════════════════════════════════════════════════════════════

class _ProductDetailCard extends StatelessWidget {
  final Fund fund;

  const _ProductDetailCard({required this.fund});

  @override
  Widget build(BuildContext context) {
    final description =
        '${fund.brandName}의 ${fund.productName}입니다.\n\n'
        '공동구매를 통해 더 많은 분들이 참여할수록 가격이 낮아집니다. '
        '지금 바로 참여하고 목표 달성 시 최대 ${fund.discountPercent}% 할인된 가격으로 구매하세요.\n\n'
        '신선하고 건강한 ${fund.category} 제품을 합리적인 가격으로 만나보세요.';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '상품 상세',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          // Placeholder detail image
          Container(
            height: 240,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5E5),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.image_outlined,
                    size: 44, color: AppColors.textSecondary),
                SizedBox(height: 8),
                Text(
                  '상품 상세 이미지 영역',
                  style:
                      TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
