import 'package:flutter/material.dart';
import 'package:grit/models/fund.dart';
import 'package:grit/theme/app_colors.dart';
import 'package:grit/utils/formatters.dart';

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
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
              padding: const EdgeInsets.only(top: 12, bottom: 8),
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '옵션 선택',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
          ),

          // Option dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _OptionDropdown(
              options: _options,
              selectedIndex: _selectedOptionIndex,
              onChanged: (i) => setState(() => _selectedOptionIndex = i),
            ),
          ),

          // Quantity selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text(
                  '수량',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.secondary,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '배송방법: 직접배송',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  fund.freeShipping ? '배송비: 무료' : '배송비: 유료',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.border),

          // Price summary
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '공구 시작가 ${formatPrice(fund.startPrice)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '공구 목표가 ${formatPrice(fund.targetPrice)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentRed,
                  ),
                ),
              ],
            ),
          ),

          // CTA button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: widget.onParticipate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surface,
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
                    color: AppColors.surface,
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
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedIndex,
          isExpanded: true,
          icon: const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          borderRadius: BorderRadius.circular(8),
          items: [
            for (int i = 0; i < options.length; i++)
              DropdownMenuItem(
                value: i,
                child: Text(
                  options[i],
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.secondary,
                  ),
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
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
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
            color: enabled ? AppColors.border : AppColors.textDisabled,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AppColors.secondary : AppColors.textDisabled,
        ),
      ),
    );
  }
}
