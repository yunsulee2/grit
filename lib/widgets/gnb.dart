import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

const _navItems = ['홈', '프로틴페스티벌', '랭킹', '전체딜', '브랜드딜', '기획전', '카테고리'];

class GNB extends StatelessWidget implements PreferredSizeWidget {
  final int activeNavIndex;
  final ValueChanged<int>? onNavTap;
  final VoidCallback? onLogoTap;
  final VoidCallback? onSearch;
  final VoidCallback? onCart;
  final VoidCallback? onLogin;

  const GNB({
    super.key,
    this.activeNavIndex = 0,
    this.onNavTap,
    this.onLogoTap,
    this.onSearch,
    this.onCart,
    this.onLogin,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;

    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16),
      child: Row(
        children: [
          // Logo
          GestureDetector(
            onTap: onLogoTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'GRIT',
                  style: TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const Text(
                  '%',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),

          // Desktop nav links
          if (isDesktop) ...[
            const SizedBox(width: 32),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_navItems.length, (i) {
                    final isActive = i == activeNavIndex;
                    return Padding(
                      padding: EdgeInsets.only(
                          right: i < _navItems.length - 1 ? 24 : 0),
                      child: GestureDetector(
                        onTap: () => onNavTap?.call(i),
                        child: Container(
                          height: 56,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isActive
                                    ? AppColors.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Text(
                            _navItems[i],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isActive
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isActive
                                  ? AppColors.primary
                                  : const Color(0xFF333333),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ] else
            const Spacer(),

          // Right actions
          IconButton(
            onPressed: onSearch,
            icon: const Icon(Icons.search, size: 24),
            color: const Color(0xFF333333),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: onCart,
            icon: const Icon(Icons.shopping_cart_outlined, size: 24),
            color: const Color(0xFF333333),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
          if (isDesktop) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onLogin,
              child: const Text(
                '로그인',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF333333),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
