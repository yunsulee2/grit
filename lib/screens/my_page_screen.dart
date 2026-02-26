import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../data/mock_data.dart';
import '../models/fund.dart';
import '../widgets/status_badge.dart';
import '../utils/formatters.dart';

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
            customBgColor: Color(0xFF007AFF),
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
      body: Column(
        children: [
          // Profile section
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(20),
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
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '김운동',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'workout@gmail.com',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/profile-edit'),
                  child: const Text(
                    '프로필 수정',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Tabs
          Container(
            color: AppColors.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 2,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
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
        const SizedBox(height: 8),
        Container(
          color: AppColors.surface,
          child: Column(
            children: [
              for (int i = 0; i < orders.length; i++) ...[
                _OrderCard(item: orders[i]),
                if (i < orders.length - 1)
                  const Divider(height: 1, indent: 16, endIndent: 16),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
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
              const Divider(height: 1, indent: 16, endIndent: 16),
              _MenuTile(
                label: '문의하기',
                onTap: () => Navigator.pushNamed(context, '/inquiry'),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _MenuTile(
                label: '로그아웃',
                labelColor: AppColors.accentRed,
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
            child: const Text(
              '취소',
              style: TextStyle(color: AppColors.textSecondary),
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
            child: const Text(
              '로그아웃',
              style: TextStyle(color: AppColors.accentRed),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fund.productName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                item.badge,
                const SizedBox(height: 4),
                Text(
                  formatPrice(fund.startPrice),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
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
        style: TextStyle(
          fontSize: 16,
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
