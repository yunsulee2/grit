import 'package:flutter/material.dart';
import '../models/fund.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/app_radius.dart';
import '../utils/formatters.dart';
import '../widgets/responsive_container.dart';
import '../widgets/fund_image.dart';
import '../services/fund_service.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    FundService.instance.addListener(_onFundChanged);
  }

  @override
  void dispose() {
    FundService.instance.removeListener(_onFundChanged);
    super.dispose();
  }

  void _onFundChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final funds = FundService.instance.getAllFunds().take(10).toList();
    final userFunds = FundService.instance.getUserFunds();
    final activeFunds = funds.where((f) => f.status == 'active').length;
    final totalParticipants =
        funds.fold<int>(0, (sum, f) => sum + f.currentParticipants);
    final totalRevenue = funds.fold<int>(
        0, (sum, f) => sum + f.currentParticipants * f.targetPrice);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('셀러 대시보드'),
      ),
      body: ResponsiveContainer.content(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _SummaryCards(
              activeFunds: activeFunds,
              totalParticipants: totalParticipants,
              totalRevenue: totalRevenue,
            ),
            const SizedBox(height: AppSpacing.xxl),
            if (userFunds.isNotEmpty) ...[
              Text(
                '새로 등록한 펀드',
                style: AppTextStyles.titleMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              ...userFunds.map((fund) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _FundCard(fund: fund, isNew: true),
                  )),
              const SizedBox(height: AppSpacing.lg),
            ],
            Text(
              '내 펀드 목록',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            ...funds.map((fund) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _FundCard(fund: fund),
                )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.pushNamed(context, '/seller/fund/new');
        },
        child: const Icon(Icons.add, color: AppColors.onPrimary),
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  final int activeFunds;
  final int totalParticipants;
  final int totalRevenue;

  const _SummaryCards({
    required this.activeFunds,
    required this.totalParticipants,
    required this.totalRevenue,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _SummaryCard(
            label: '진행 중 펀드',
            value: '$activeFunds개',
            valueColor: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.md),
          _SummaryCard(
            label: '총 참여자',
            value: '${formatNumber(totalParticipants)}명',
            valueColor: AppColors.textPrimary,
          ),
          const SizedBox(width: AppSpacing.md),
          _SummaryCard(
            label: '이번 달 매출',
            value: formatPrice(totalRevenue),
            valueColor: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }
}

class _FundCard extends StatelessWidget {
  final Fund fund;
  final bool isNew;

  const _FundCard({required this.fund, this.isNew = false});

  Color get _statusColor {
    switch (fund.status) {
      case 'active':
        return AppColors.success;
      case 'ended':
        return AppColors.textSecondary;
      default:
        return AppColors.primary;
    }
  }

  String get _statusLabel {
    switch (fund.status) {
      case 'active':
        return '진행 중';
      case 'ended':
        return '종료';
      default:
        return fund.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = fund.progressRatio;
    final revenue = fund.currentParticipants * fund.targetPrice;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/fund/${fund.id}'),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.borderMd,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: AppRadius.borderSm,
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: FundImage(
                      imageUrl: fund.imageUrl,
                      errorIcon: Icons.fastfood,
                      errorIconSize: 24,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    fund.productName,
                    style: AppTextStyles.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const SizedBox(width: AppSpacing.sm),
              if (isNew) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppRadius.borderFull,
                  ),
                  child: Text(
                    'NEW',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.12),
                  borderRadius: AppRadius.borderFull,
                ),
                child: Text(
                  _statusLabel,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: _statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${formatNumber(fund.currentParticipants)}명 참여',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '목표 ${formatNumber(fund.maxParticipants)}명',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              ClipRRect(
                borderRadius: AppRadius.borderXs,
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '마감: ${fund.endAt.month}/${fund.endAt.day}',
                style: AppTextStyles.bodySmall,
              ),
              Text(
                '매출 ${formatPrice(revenue)}',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}
