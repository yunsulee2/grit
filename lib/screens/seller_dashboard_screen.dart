import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/fund.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

class SellerDashboardScreen extends StatelessWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final funds = mockFunds.take(5).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('셀러 대시보드'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SummaryCards(),
          const SizedBox(height: 24),
          const Text(
            '내 펀드 목록',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...funds.map((fund) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _FundCard(fund: fund),
              )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.pushNamed(context, '/seller/fund/new');
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _SummaryCard(
            label: '진행 중 펀드',
            value: '3개',
            valueColor: AppColors.primary,
          ),
          const SizedBox(width: 12),
          _SummaryCard(
            label: '총 참여자',
            value: '1,247명',
            valueColor: AppColors.textPrimary,
          ),
          const SizedBox(width: 12),
          _SummaryCard(
            label: '이번 달 매출',
            value: '12,450,000원',
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _FundCard extends StatelessWidget {
  final Fund fund;

  const _FundCard({required this.fund});

  Color get _statusColor {
    switch (fund.status) {
      case 'active':
        return AppColors.successGreen;
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  fund.productName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '목표 ${formatNumber(fund.maxParticipants)}명',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
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
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '매출 ${formatPrice(revenue)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
