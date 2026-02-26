import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

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
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '단계 ${index + 1}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (onDelete != null)
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(
                    Icons.close,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
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
              const SizedBox(width: 12),
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
            const SizedBox(height: 8),
            Text(
              '$discount% 할인',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.successGreen,
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
        suffixStyle: const TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
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
