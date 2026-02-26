import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/extracted_product.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/app_radius.dart';
import '../widgets/extraction_status_icon.dart';
import '../widgets/image_grid_editor.dart';
import '../widgets/detail_image_list.dart';

class ExtractionResultForm extends StatefulWidget {
  final ExtractedProduct product;
  final ValueChanged<ExtractedProduct> onChanged;
  final VoidCallback onConfirm;

  const ExtractionResultForm({
    super.key,
    required this.product,
    required this.onChanged,
    required this.onConfirm,
  });

  @override
  State<ExtractionResultForm> createState() => _ExtractionResultFormState();
}

class _ExtractionResultFormState extends State<ExtractionResultForm> {
  late TextEditingController _productNameCtrl;
  late TextEditingController _brandNameCtrl;
  late TextEditingController _originCtrl;
  late TextEditingController _weightCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _descriptionCtrl;

  late String? _selectedCategory;
  late bool _useOriginalDetail;

  static const _categories = [
    '닭가슴살',
    '프로틴',
    '간식/간편식',
    '음료',
    '도시락',
    '샐러드',
    '소스/시즌닝',
    '기타',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _productNameCtrl = TextEditingController(text: p.productName.value ?? '');
    _brandNameCtrl = TextEditingController(text: p.brandName.value ?? '');
    _originCtrl = TextEditingController(text: p.origin.value ?? '');
    _weightCtrl = TextEditingController(text: p.weight.value ?? '');
    _priceCtrl = TextEditingController(
      text: p.originalPrice.value != null ? p.originalPrice.value.toString() : '',
    );
    _descriptionCtrl = TextEditingController(text: p.description.value ?? '');

    final cat = p.category.value;
    _selectedCategory = (cat != null && _categories.contains(cat)) ? cat : null;
    _useOriginalDetail = true;
  }

  @override
  void dispose() {
    _productNameCtrl.dispose();
    _brandNameCtrl.dispose();
    _originCtrl.dispose();
    _weightCtrl.dispose();
    _priceCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  void _notifyChanged({
    String? productName,
    String? brandName,
    String? category,
    String? origin,
    String? weight,
    String? price,
    String? description,
  }) {
    final p = widget.product;
    widget.onChanged(p.copyWith(
      productName: productName != null
          ? ExtractedField<String>(value: productName, confidence: p.productName.confidence)
          : null,
      brandName: brandName != null
          ? ExtractedField<String>(value: brandName, confidence: p.brandName.confidence)
          : null,
      category: category != null
          ? ExtractedField<String>(value: category, confidence: p.category.confidence)
          : null,
      origin: origin != null
          ? ExtractedField<String>(value: origin, confidence: p.origin.confidence)
          : null,
      weight: weight != null
          ? ExtractedField<String>(value: weight, confidence: p.weight.confidence)
          : null,
      originalPrice: price != null
          ? ExtractedField<int>(
              value: int.tryParse(price.replaceAll(RegExp(r'[^0-9]'), '')),
              confidence: p.originalPrice.confidence,
            )
          : null,
      description: description != null
          ? ExtractedField<String>(value: description, confidence: p.description.confidence)
          : null,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final nutrition = p.nutritionInfo.value;
    final options = p.options.value;

    // Combine mainImage + galleryImages for the grid editor (deduplicated)
    final mainImg = p.mainImage.value;
    final gallery = p.galleryImages.value ?? [];
    final seen = <String>{};
    final allImages = <String>[
      if (mainImg != null && mainImg.isNotEmpty) mainImg,
      ...gallery,
    ].where((img) => seen.add(img)).toList();

    final detailImgs = p.detailImages.value ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ────────────────────────────────────────────────────────────
        _SectionHeader(
          title: '추출 결과',
          trailing: GestureDetector(
            onTap: () {},
            child: Text(
              '원본: ${p.sourceUrl}',
              style: AppTextStyles.bodySmall.copyWith(
                decoration: TextDecoration.underline,
                decorationColor: AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // ── 상품명 ─────────────────────────────────────────────────────────────
        _FieldLabel(label: '상품명', confidence: p.productName.confidence),
        const SizedBox(height: 6),
        _buildTextField(
          controller: _productNameCtrl,
          hintText: '상품명을 입력하세요',
          onChanged: (v) => _notifyChanged(productName: v),
        ),

        const SizedBox(height: AppSpacing.lg),

        // ── 브랜드명 ───────────────────────────────────────────────────────────
        _FieldLabel(label: '브랜드명', confidence: p.brandName.confidence),
        const SizedBox(height: 6),
        _buildTextField(
          controller: _brandNameCtrl,
          hintText: '브랜드명을 입력하세요',
          onChanged: (v) => _notifyChanged(brandName: v),
        ),

        const SizedBox(height: AppSpacing.lg),

        // ── 카테고리 ───────────────────────────────────────────────────────────
        _FieldLabel(label: '카테고리', confidence: p.category.confidence),
        const SizedBox(height: 6),
        _buildCategoryDropdown(),

        const SizedBox(height: AppSpacing.lg),

        // ── 원산지 ─────────────────────────────────────────────────────────────
        _FieldLabel(label: '원산지', confidence: p.origin.confidence),
        const SizedBox(height: 6),
        _buildTextField(
          controller: _originCtrl,
          hintText: '원산지를 입력하세요',
          onChanged: (v) => _notifyChanged(origin: v),
        ),

        const SizedBox(height: AppSpacing.lg),

        // ── 용량/중량 ──────────────────────────────────────────────────────────
        _FieldLabel(label: '용량/중량', confidence: p.weight.confidence),
        const SizedBox(height: 6),
        _buildTextField(
          controller: _weightCtrl,
          hintText: '예: 200g, 1kg',
          onChanged: (v) => _notifyChanged(weight: v),
        ),

        const SizedBox(height: AppSpacing.lg),

        // ── 참고 가격 ──────────────────────────────────────────────────────────
        _FieldLabel(label: '원본 판매가 (참고용)', confidence: p.originalPrice.confidence),
        const SizedBox(height: 6),
        _buildTextField(
          controller: _priceCtrl,
          hintText: '0',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (v) => _notifyChanged(price: v),
        ),

        const SizedBox(height: AppSpacing.lg),

        // ── 상품 설명 ──────────────────────────────────────────────────────────
        _FieldLabel(label: '상품 설명', confidence: p.description.confidence),
        const SizedBox(height: 6),
        _buildTextField(
          controller: _descriptionCtrl,
          hintText: '상품 설명을 입력하세요',
          maxLines: 5,
          onChanged: (v) => _notifyChanged(description: v),
        ),

        const SizedBox(height: AppSpacing.xxl),

        // ── 이미지 섹션 ────────────────────────────────────────────────────────
        ImageGridEditor(
          imageUrls: allImages,
          title: '상품 이미지',
          onChanged: (updated) {
            final newMain = updated.isNotEmpty ? updated.first : null;
            final newGallery = updated.length > 1 ? updated.sublist(1) : <String>[];
            widget.onChanged(p.copyWith(
              mainImage: ExtractedField<String>(
                value: newMain,
                confidence: p.mainImage.confidence,
              ),
              galleryImages: ExtractedField<List<String>>(
                value: newGallery,
                confidence: p.galleryImages.confidence,
              ),
            ));
          },
        ),

        const SizedBox(height: AppSpacing.xxl),

        // ── 상세페이지 이미지 섹션 ─────────────────────────────────────────────
        DetailImageList(
          imageUrls: detailImgs,
          useOriginal: _useOriginalDetail,
          onUseOriginalChanged: (v) => setState(() => _useOriginalDetail = v),
          onChanged: (updated) {
            widget.onChanged(p.copyWith(
              detailImages: ExtractedField<List<String>>(
                value: updated,
                confidence: p.detailImages.confidence,
              ),
            ));
          },
        ),

        const SizedBox(height: AppSpacing.xxl),

        // ── 옵션 섹션 ──────────────────────────────────────────────────────────
        if (options != null && options.isNotEmpty) ...[
          const _SectionDividerLabel(label: '옵션'),
          const SizedBox(height: AppSpacing.md),
          _buildOptionsSection(options),
          const SizedBox(height: AppSpacing.xxl),
        ],

        // ── 영양 정보 섹션 ─────────────────────────────────────────────────────
        if (nutrition != null) ...[
          const _SectionDividerLabel(label: '영양 정보'),
          const SizedBox(height: AppSpacing.md),
          _buildNutritionGrid(nutrition),
          const SizedBox(height: AppSpacing.xxl),
        ],

        // ── CTA ────────────────────────────────────────────────────────────────
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: widget.onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.borderSm,
              ),
            ),
            child: Text(
              '이 정보로 계속하기',
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required ValueChanged<String> onChanged,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderSm,
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.textTertiary),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 10,
          ),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderSm,
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          hint: Text(
            '카테고리를 선택하세요',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textTertiary),
          ),
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
          items: _categories
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (v) {
            setState(() => _selectedCategory = v);
            if (v != null) _notifyChanged(category: v);
          },
        ),
      ),
    );
  }

  Widget _buildOptionsSection(List<ProductOption> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: options.map((opt) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                opt.name,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: opt.values.map((v) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: AppRadius.borderLg,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      v,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNutritionGrid(NutritionInfo nutrition) {
    final items = <_NutritionItem>[
      _NutritionItem(
        label: '열량',
        value: nutrition.calories != null ? '${nutrition.calories} kcal' : '-',
      ),
      _NutritionItem(
        label: '단백질',
        value: nutrition.protein != null ? '${nutrition.protein} g' : '-',
      ),
      _NutritionItem(
        label: '지방',
        value: nutrition.fat != null ? '${nutrition.fat} g' : '-',
      ),
      _NutritionItem(
        label: '탄수화물',
        value: nutrition.carbs != null ? '${nutrition.carbs} g' : '-',
      ),
      _NutritionItem(
        label: '나트륨',
        value: nutrition.sodium != null ? '${nutrition.sodium} mg' : '-',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderSm,
        border: Border.all(color: AppColors.border),
      ),
      child: Wrap(
        spacing: 0,
        runSpacing: 0,
        children: items.map((item) {
          return SizedBox(
            width: 100,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.value,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Supporting widgets ───────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _SectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: AppTextStyles.titleMedium,
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.md),
          Expanded(child: trailing!),
        ],
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final ExtractionConfidence confidence;

  const _FieldLabel({required this.label, required this.confidence});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ExtractionStatusIcon(confidence: confidence, size: 16),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _SectionDividerLabel extends StatelessWidget {
  final String label;

  const _SectionDividerLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: AppTextStyles.titleSmall,
        ),
        const SizedBox(width: AppSpacing.md),
        const Expanded(
          child: Divider(color: AppColors.border, thickness: 1),
        ),
      ],
    );
  }
}

class _NutritionItem {
  final String label;
  final String value;
  const _NutritionItem({required this.label, required this.value});
}
