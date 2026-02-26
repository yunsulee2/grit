import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/app_radius.dart';
import '../data/mock_data.dart';
import '../models/fund.dart';
import '../widgets/status_badge.dart';
import '../utils/formatters.dart';
import '../widgets/responsive_container.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock orders per tab using first 6 mockFunds
  List<_OrderItem> get _activeOrders => [
        _OrderItem(fund: mockFunds[0], badge: const StatusBadge.active(text: '참여 중')),
        _OrderItem(fund: mockFunds[1], badge: const StatusBadge.active(text: '참여 중')),
      ];

  List<_OrderItem> get _shippingOrders => [
        _OrderItem(
          fund: mockFunds[2],
          badge: const StatusBadge(
            text: '배송중',
            type: BadgeType.custom,
            customBgColor: AppColors.info,
            customTextColor: AppColors.surface,
          ),
        ),
      ];

  List<_OrderItem> get _completedOrders => [
        _OrderItem(fund: mockFunds[3], badge: const StatusBadge.completed(text: '완료')),
        _OrderItem(fund: mockFunds[4], badge: const StatusBadge.completed(text: '완료')),
        _OrderItem(fund: mockFunds[5], badge: const StatusBadge.completed(text: '완료')),
      ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('마이페이지'),
      ),
      body: ResponsiveContainer.content(
        child: Column(
          children: [
            // Profile section
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.background,
                    child: Icon(
                      Icons.person,
                      color: AppColors.textSecondary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '김운동',
                          style: AppTextStyles.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'workout@gmail.com',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/profile-edit'),
                    child: Text(
                      '프로필 수정',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Tabs
            Container(
              color: AppColors.surface,
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                indicatorWeight: 2,
                labelStyle: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.normal,
                ),
                tabs: const [
                  Tab(text: '참여 중 (2)'),
                  Tab(text: '배송중 (1)'),
                  Tab(text: '완료 (3)'),
                ],
              ),
            ),
            // Order list
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _OrderList(orders: _activeOrders),
                  _OrderList(orders: _shippingOrders),
                  _OrderList(orders: _completedOrders),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Order data model ─────────────────────────────────────────────────────────

class _OrderItem {
  final Fund fund;
  final Widget badge;

  const _OrderItem({required this.fund, required this.badge});
}

// ─── Order list ───────────────────────────────────────────────────────────────

class _OrderList extends StatelessWidget {
  final List<_OrderItem> orders;

  const _OrderList({required this.orders});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: AppSpacing.sm),
        Container(
          color: AppColors.surface,
          child: Column(
            children: [
              for (int i = 0; i < orders.length; i++) ...[
                _OrderCard(item: orders[i]),
                if (i < orders.length - 1)
                  const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Menu section
        const Divider(height: 1),
        Container(
          color: AppColors.surface,
          child: Column(
            children: [
              _MenuTile(
                label: '배송지 관리',
                onTap: () => Navigator.pushNamed(context, '/addresses'),
              ),
              const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
              _MenuTile(
                label: '문의하기',
                onTap: () => Navigator.pushNamed(context, '/inquiry'),
              ),
              const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
              _MenuTile(
                label: '로그아웃',
                labelColor: AppColors.error,
                onTap: () => _showLogoutDialog(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              '취소',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('로그아웃되었습니다'),
                  duration: Duration(seconds: 2),
                ),
              );
              Navigator.pushNamedAndRemoveUntil(
                  context, '/', (route) => false);
            },
            child: Text(
              '로그아웃',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Order card ───────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  final _OrderItem item;

  const _OrderCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final fund = item.fund;
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: AppRadius.borderSm,
            child: Image.asset(
              fund.imageUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(
                width: 56,
                height: 56,
                color: AppColors.background,
                child: const Icon(Icons.image, color: AppColors.textSecondary),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fund.productName,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                item.badge,
                const SizedBox(height: AppSpacing.xs),
                Text(
                  formatPrice(fund.startPrice),
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

// ─── Menu tile ────────────────────────────────────────────────────────────────

class _MenuTile extends StatelessWidget {
  final String label;
  final Color? labelColor;
  final VoidCallback onTap;

  const _MenuTile({
    required this.label,
    this.labelColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(
        label,
        style: AppTextStyles.titleMedium.copyWith(
          color: labelColor ?? AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),
    );
  }
}
