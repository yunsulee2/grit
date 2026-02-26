import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/app_radius.dart';

class PriceTierInput extends StatelessWidget {
  final int index;
  final int minParticipants;
  final int price;
  final int? basePrice;
  final Function(int minParticipants, int price) onChange;
  final VoidCallback? onDelete;

  const PriceTierInput({
    super.key,
    required this.index,
    required this.minParticipants,
    required this.price,
    this.basePrice,
    required this.onChange,
    this.onDelete,
  });

  int? get _discountPercent {
    if (basePrice == null || basePrice == 0 || index == 0) return null;
    final pct = ((1 - price / basePrice!) * 100).round();
    return pct > 0 ? pct : null;
  }

  @override
  Widget build(BuildContext context) {
    final discount = _discountPercent;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: AppRadius.borderMd,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '단계 ${index + 1}',
                style: AppTextStyles.titleSmall,
              ),
              if (onDelete != null)
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(
                    Icons.close,
                    size: AppSpacing.xl,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Input row
          Row(
            children: [
              Expanded(
                child: _NumberField(
                  initialValue: minParticipants,
                  suffix: '명 이상',
                  onChanged: (val) => onChange(val, price),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _NumberField(
                  initialValue: price,
                  suffix: '원',
                  onChanged: (val) => onChange(minParticipants, val),
                ),
              ),
            ],
          ),
          if (discount != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              '$discount% 할인',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.success,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NumberField extends StatefulWidget {
  final int initialValue;
  final String suffix;
  final ValueChanged<int> onChanged;

  const _NumberField({
    required this.initialValue,
    required this.suffix,
    required this.onChanged,
  });

  @override
  State<_NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<_NumberField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialValue == 0 ? '' : widget.initialValue.toString(),
    );
  }

  @override
  void didUpdateWidget(_NumberField old) {
    super.didUpdateWidget(old);
    if (old.initialValue != widget.initialValue) {
      final newText =
          widget.initialValue == 0 ? '' : widget.initialValue.toString();
      if (_controller.text != newText) {
        _controller.text = newText;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        suffixText: widget.suffix,
        suffixStyle: AppTextStyles.bodyMedium,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.borderSm,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderSm,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderSm,
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
      onChanged: (val) {
        final parsed = int.tryParse(val) ?? 0;
        widget.onChanged(parsed);
      },
    );
  }
}
