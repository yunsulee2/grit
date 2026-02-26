import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

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
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _addresses.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final addr = _addresses[index];
          return _AddressCard(
            address: addr,
            onEdit: () => _showPlaceholder(context, '준비 중'),
            onDelete: () => _showPlaceholder(context, '준비 중'),
          );
        },
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
              Text(
                address.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (address.isDefault) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '기본 배송지',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              TextButton(
                onPressed: onEdit,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  '수정',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              TextButton(
                onPressed: onDelete,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  '삭제',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.accentRed,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            address.address,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            address.phone,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
