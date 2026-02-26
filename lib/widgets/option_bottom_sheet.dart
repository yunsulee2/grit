import 'package:flutter/material.dart';
import '../models/fund.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/app_radius.dart';
import '../utils/formatters.dart';

class OptionBottomSheet extends StatefulWidget {
  final Fund fund;
  final VoidCallback? onParticipate;

  const OptionBottomSheet({
    super.key,
    required this.fund,
    this.onParticipate,
  });

  static Future<void> show(
    BuildContext context, {
    required Fund fund,
    VoidCallback? onParticipate,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OptionBottomSheet(
        fund: fund,
        onParticipate: onParticipate,
      ),
    );
  }

  @override
  State<OptionBottomSheet> createState() => _OptionBottomSheetState();
}

class _OptionBottomSheetState extends State<OptionBottomSheet> {
  int _quantity = 1;
  int _selectedOptionIndex = 0;

  // Synthetic option list derived from tiers; fall back to a default option.
  List<String> get _options {
    if (widget.fund.tiers.isEmpty) return ['기본 옵션'];
    return widget.fund.tiers
        .map((t) => '${formatNumber(t.minParticipants)}개 이상 달성가')
        .toList();
  }

  void _decrement() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  void _increment() {
    setState(() => _quantity++);
  }

  @override
  Widget build(BuildContext context) {
    final fund = widget.fund;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Text(
              '옵션 선택',
              style: AppTextStyles.titleMedium,
            ),
          ),

          // Option dropdown
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: _OptionDropdown(
              options: _options,
              selectedIndex: _selectedOptionIndex,
              onChanged: (i) => setState(() => _selectedOptionIndex = i),
            ),
          ),

          // Quantity selector
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Text(
                  '수량',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                _QuantityStepper(
                  quantity: _quantity,
                  onDecrement: _decrement,
                  onIncrement: _increment,
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.border),

          // Delivery info
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '배송방법: 직접배송',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  fund.freeShipping ? '배송비: 무료' : '배송비: 유료',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.border),

          // Price summary
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '공구 시작가 ${formatPrice(fund.startPrice)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '공구 목표가 ${formatPrice(fund.targetPrice)}',
                  style: AppTextStyles.priceCard.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),

          // CTA button
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xs,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: widget.onParticipate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderSm,
                  ),
                ),
                child: Text(
                  '공동구매 참여하기',
                  style: AppTextStyles.priceCard.copyWith(
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Option dropdown ──────────────────────────────────────────────────────────

class _OptionDropdown extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _OptionDropdown({
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: AppRadius.borderSm,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedIndex,
          isExpanded: true,
          icon: const Padding(
            padding: EdgeInsets.only(right: AppSpacing.md),
            child: Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          borderRadius: AppRadius.borderSm,
          items: [
            for (int i = 0; i < options.length; i++)
              DropdownMenuItem(
                value: i,
                child: Text(
                  options[i],
                  style: AppTextStyles.bodyLarge,
                ),
              ),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

// ─── Quantity stepper ─────────────────────────────────────────────────────────

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QuantityStepper({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepperButton(
          icon: Icons.remove,
          onTap: onDecrement,
          enabled: quantity > 1,
        ),
        Container(
          width: 44,
          alignment: Alignment.center,
          child: Text(
            '$quantity',
            style: AppTextStyles.labelLarge,
          ),
        ),
        _StepperButton(
          icon: Icons.add,
          onTap: onIncrement,
          enabled: true,
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _StepperButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(
            color: enabled ? AppColors.border : AppColors.textTertiary,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AppColors.textPrimary : AppColors.textTertiary,
        ),
      ),
    );
  }
}
