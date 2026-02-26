import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_breakpoints.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

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
    final isDesktop = AppBreakpoints.isDesktop(context);

    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppBreakpoints.horizontalPadding(context),
      ),
      child: Row(
        children: [
          // Logo
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onLogoTap,
              child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('GRIT', style: AppTextStyles.logo),
                Text(
                  '%',
                  style: AppTextStyles.logo.copyWith(color: AppColors.accent),
                ),
              ],
              ),
            ),
          ),

          // Desktop nav links
          if (isDesktop) ...[
            const SizedBox(width: AppSpacing.xxxl),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_navItems.length, (i) {
                    final isActive = i == activeNavIndex;
                    return Padding(
                      padding: EdgeInsets.only(
                          right: i < _navItems.length - 1 ? AppSpacing.xxl : 0),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
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
                            style: AppTextStyles.labelMedium.copyWith(
                              fontWeight: isActive
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isActive
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
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
            icon: const Icon(Icons.search, size: 22),
            color: AppColors.textPrimary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
          const SizedBox(width: AppSpacing.xs),
          IconButton(
            onPressed: onCart,
            icon: const Icon(Icons.shopping_bag_outlined, size: 22),
            color: AppColors.textPrimary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
          if (isDesktop) ...[
            const SizedBox(width: AppSpacing.md),
            GestureDetector(
              onTap: onLogin,
              child: Text(
                '로그인',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
