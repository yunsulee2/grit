import 'package:flutter/material.dart';
import '../models/extracted_product.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/app_radius.dart';
import '../widgets/extraction_result_form.dart';

/// Bottom sheet wrapper for the ExtractionResultForm.
/// Shows the full editable form when user taps "수정하면서 시작" on the result card.
class ExtractionDetailSheet extends StatefulWidget {
  final ExtractedProduct product;
  final ValueChanged<ExtractedProduct> onConfirm;

  const ExtractionDetailSheet({
    super.key,
    required this.product,
    required this.onConfirm,
  });

  /// Show the bottom sheet and return the (possibly edited) product.
  static Future<ExtractedProduct?> show(
    BuildContext context,
    ExtractedProduct product,
  ) {
    return showModalBottomSheet<ExtractedProduct>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => ExtractionDetailSheet(
        product: product,
        onConfirm: (updated) => Navigator.of(ctx).pop(updated),
      ),
    );
  }

  @override
  State<ExtractionDetailSheet> createState() => _ExtractionDetailSheetState();
}

class _ExtractionDetailSheetState extends State<ExtractionDetailSheet> {
  late ExtractedProduct _product;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.9),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.md),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: AppRadius.borderFull,
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.lg, AppSpacing.md, AppSpacing.md,
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    '상품 정보 수정',
                    style: AppTextStyles.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(null),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.border),

          // Scrollable form content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: ExtractionResultForm(
                product: _product,
                onChanged: (updated) => setState(() => _product = updated),
                onConfirm: () => widget.onConfirm(_product),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
