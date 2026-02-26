import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/app_radius.dart';
import '../widgets/responsive_container.dart';

class _Address {
  final String name;
  final String address;
  final String phone;
  final bool isDefault;

  const _Address({
    required this.name,
    required this.address,
    required this.phone,
    this.isDefault = false,
  });
}

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

  static const List<_Address> _addresses = [
    _Address(
      name: '김운동',
      address: '서울시 강남구 역삼동 123-45',
      phone: '010-1234-5678',
      isDefault: true,
    ),
    _Address(
      name: '김운동',
      address: '경기도 성남시 분당구 정자동 67-8',
      phone: '010-1234-5678',
    ),
    _Address(
      name: '김운동',
      address: '서울시 마포구 합정동 89-10',
      phone: '010-1234-5678',
    ),
  ];

  void _showPlaceholder(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('배송지 관리'),
      ),
      body: ResponsiveContainer.form(
        child: ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: _addresses.length,
          separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final addr = _addresses[index];
            return _AddressCard(
              address: addr,
              onEdit: () => _showPlaceholder(context, '준비 중'),
              onDelete: () => _showPlaceholder(context, '준비 중'),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPlaceholder(context, '새 배송지 추가는 준비 중입니다'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final _Address address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            children: [
              Text(
                address.name,
                style: AppTextStyles.titleSmall,
              ),
              if (address.isDefault) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs / 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: AppRadius.borderXs,
                  ),
                  child: Text(
                    '기본 배송지',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              TextButton(
                onPressed: onEdit,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  '수정',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              TextButton(
                onPressed: onDelete,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  '삭제',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            address.address,
            style: AppTextStyles.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            address.phone,
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}
