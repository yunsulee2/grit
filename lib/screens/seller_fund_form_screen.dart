import 'package:flutter/material.dart';
import '../models/fund.dart';
import '../models/extracted_product.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/app_radius.dart';
import '../utils/formatters.dart';
import '../widgets/step_indicator.dart';
import '../widgets/price_tier_input.dart';
import '../widgets/price_tier_preview.dart';
import '../widgets/responsive_container.dart';
import '../services/fund_service.dart';

class SellerFundFormScreen extends StatefulWidget {
  const SellerFundFormScreen({super.key});

  @override
  State<SellerFundFormScreen> createState() => _SellerFundFormScreenState();
}

class _SellerFundFormScreenState extends State<SellerFundFormScreen> {
  int _currentStep = 0;
  static const int _totalSteps = 6;

  // Step 1
  final _productNameCtrl = TextEditingController();
  String _category = '닭가슴살';
  final _descriptionCtrl = TextEditingController();

  // Step 2
  List<String> _options = ['기본'];

  // Step 3
  List<_TierData> _tiers = [
    _TierData(minParticipants: 1, price: 0),
    _TierData(minParticipants: 100, price: 0),
  ];

  // Step 4
  final _startDateCtrl = TextEditingController(text: '2026-03-01');
  final _endDateCtrl = TextEditingController(text: '2026-03-31');
  final _minParticipantsCtrl = TextEditingController();
  final _maxParticipantsCtrl = TextEditingController(text: '500');
  final _shippingFeeCtrl = TextEditingController(text: '0');
  String _shippingMethod = '택배';

  static const List<String> _categories = [
    '닭가슴살',
    '프로틴',
    '간식/간편식',
    '음료',
    '도시락',
    '샐러드',
  ];

  static const List<String> _shippingMethods = [
    '택배',
    '새벽배송',
    '직접배송',
    '편의점 픽업',
  ];

  @override
  void dispose() {
    _productNameCtrl.dispose();
    _descriptionCtrl.dispose();
    _startDateCtrl.dispose();
    _endDateCtrl.dispose();
    _minParticipantsCtrl.dispose();
    _maxParticipantsCtrl.dispose();
    _shippingFeeCtrl.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    }
  }

  void _goPrev() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _onUrlScrapeSelected() async {
    final result = await Navigator.pushNamed(context, '/seller/fund/url-scrape');
    if (result is ExtractedProduct) {
      _applyExtractedProduct(result);
    }
    setState(() => _currentStep = 1);
  }

  void _applyExtractedProduct(ExtractedProduct product) {
    if (product.productName.value != null) {
      _productNameCtrl.text = product.productName.value!;
    }
    if (product.description.value != null) {
      _descriptionCtrl.text = product.description.value!;
    }
    if (product.category.value != null) {
      final matched = _categories.firstWhere(
        (c) => c.contains(product.category.value!) ||
            product.category.value!.contains(c),
        orElse: () => _category,
      );
      _category = matched;
    }
    if (product.options.value != null && product.options.value!.isNotEmpty) {
      _options = product.options.value!
          .expand((opt) => opt.values.isNotEmpty ? opt.values : [opt.name])
          .toList();
    }
  }

  bool _isSubmitting = false;

  void _showFieldError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _submit() async {
    // Validate Step 1: basic info
    if (_productNameCtrl.text.trim().isEmpty) {
      _showFieldError('상품명을 입력해주세요.');
      setState(() => _currentStep = 1);
      return;
    }
    if (_descriptionCtrl.text.trim().isEmpty) {
      _showFieldError('상품 설명을 입력해주세요.');
      setState(() => _currentStep = 1);
      return;
    }

    // Validate Step 3: pricing — at least one tier with valid price
    if (_tiers.isEmpty || _tiers.any((t) => t.price <= 0)) {
      _showFieldError('가격을 올바르게 입력해주세요.');
      setState(() => _currentStep = 3);
      return;
    }

    // Validate Step 4: dates and max participants
    if (_startDateCtrl.text.trim().isEmpty ||
        _endDateCtrl.text.trim().isEmpty) {
      _showFieldError('펀드 기간을 입력해주세요.');
      setState(() => _currentStep = 4);
      return;
    }
    if (_maxParticipantsCtrl.text.trim().isEmpty) {
      _showFieldError('최대 참여 인원을 입력해주세요.');
      setState(() => _currentStep = 4);
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await FundService.instance.submitFund({
      'productName': _productNameCtrl.text.trim(),
      'category': _category,
      'description': _descriptionCtrl.text.trim(),
      'options': _options,
      'tiers': _tiers
          .map((t) => {
                'minParticipants': t.minParticipants,
                'price': t.price,
              })
          .toList(),
      'startDate': _startDateCtrl.text.trim(),
      'endDate': _endDateCtrl.text.trim(),
      'minParticipants': _minParticipantsCtrl.text.trim(),
      'maxParticipants': _maxParticipantsCtrl.text.trim(),
      'shippingFee': _shippingFeeCtrl.text.trim(),
      'shippingMethod': _shippingMethod,
    });

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('펀드가 성공적으로 게시되었습니다!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Navigate to seller dashboard
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pushNamed(context, '/seller/dashboard');
    }
  }

  List<PriceTier> get _priceTiers => _tiers
      .map((t) => PriceTier(minParticipants: t.minParticipants, price: t.price))
      .toList();

  int get _maxParticipantsValue =>
      int.tryParse(_maxParticipantsCtrl.text) ?? 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('새 펀드 만들기'),
      ),
      body: ResponsiveContainer.form(
        child: Column(
          children: [
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.lg),
              child: StepIndicator(
                totalSteps: _totalSteps,
                currentStep: _currentStep + 1,
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _currentStep,
                children: [
                  _Step0(
                    onUrlScrape: _onUrlScrapeSelected,
                    onManual: () => setState(() => _currentStep = 1),
                  ),
                  _Step1(
                    productNameCtrl: _productNameCtrl,
                    category: _category,
                    categories: _categories,
                    descriptionCtrl: _descriptionCtrl,
                    onCategoryChanged: (v) => setState(() => _category = v!),
                  ),
                  _Step2(
                    options: _options,
                    onOptionsChanged: (opts) => setState(() => _options = opts),
                  ),
                  _Step3(
                    tiers: _tiers,
                    maxParticipants: _maxParticipantsValue,
                    onTiersChanged: (t) => setState(() => _tiers = t),
                  ),
                  _Step4(
                    startDateCtrl: _startDateCtrl,
                    endDateCtrl: _endDateCtrl,
                    minParticipantsCtrl: _minParticipantsCtrl,
                    maxParticipantsCtrl: _maxParticipantsCtrl,
                    shippingFeeCtrl: _shippingFeeCtrl,
                    shippingMethod: _shippingMethod,
                    shippingMethods: _shippingMethods,
                    onShippingMethodChanged: (v) =>
                        setState(() => _shippingMethod = v!),
                  ),
                  _Step5(
                    productName: _productNameCtrl.text,
                    category: _category,
                    description: _descriptionCtrl.text,
                    options: _options,
                    tiers: _priceTiers,
                    maxParticipants: _maxParticipantsValue,
                    startDate: _startDateCtrl.text,
                    endDate: _endDateCtrl.text,
                    minParticipants: _minParticipantsCtrl.text,
                    shippingFee: _shippingFeeCtrl.text,
                    shippingMethod: _shippingMethod,
                    onSubmit: _submit,
                    onEdit: _goPrev,
                    isSubmitting: _isSubmitting,
                  ),
                ],
              ),
            ),
            if (_currentStep > 0)
              _BottomButtons(
                currentStep: _currentStep,
                totalSteps: _totalSteps,
                onPrev: _goPrev,
                onNext: _goNext,
                onSubmit: _submit,
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Step 0: 등록 방식 선택 ────────────────────────────────────────────────────

class _Step0 extends StatelessWidget {
  final VoidCallback onUrlScrape;
  final VoidCallback onManual;

  const _Step0({required this.onUrlScrape, required this.onManual});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepTitle('등록 방식 선택'),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '상품을 어떻게 등록하시겠어요?',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          GestureDetector(
            onTap: onUrlScrape,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: AppRadius.borderMd,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: AppRadius.borderSm,
                        ),
                        child: const Icon(
                          Icons.link,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'URL로 빠른 등록',
                                  style: AppTextStyles.titleSmall,
                                ),
                                SizedBox(width: AppSpacing.sm),
                                _RecommendedBadge(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '기존 쇼핑몰 URL을 붙여넣으면 자동으로 상품 정보를 가져옵니다',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GestureDetector(
            onTap: onManual,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                borderRadius: AppRadius.borderMd,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: AppRadius.borderSm,
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          color: AppColors.textSecondary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      const Text(
                        '직접 입력',
                        style: AppTextStyles.titleSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '상품 정보를 처음부터 직접 입력합니다',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendedBadge extends StatelessWidget {
  const _RecommendedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: AppRadius.borderFull,
      ),
      child: Text(
        '추천',
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ─── Bottom Navigation Buttons ────────────────────────────────────────────────

class _BottomButtons extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onSubmit;

  const _BottomButtons({
    required this.currentStep,
    required this.totalSteps,
    required this.onPrev,
    required this.onNext,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    // On last step, the action buttons are inside the step itself
    if (currentStep == totalSteps - 1) return const SizedBox.shrink();

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xxl),
      child: Row(
        children: [
          if (currentStep > 1) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: onPrev,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderSm,
                  ),
                ),
                child: Text(
                  '이전',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.borderSm,
                ),
                elevation: 0,
              ),
              child: Text(
                '다음',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 1: 기본 정보 ─────────────────────────────────────────────────────────

class _Step1 extends StatelessWidget {
  final TextEditingController productNameCtrl;
  final String category;
  final List<String> categories;
  final TextEditingController descriptionCtrl;
  final ValueChanged<String?> onCategoryChanged;

  const _Step1({
    required this.productNameCtrl,
    required this.category,
    required this.categories,
    required this.descriptionCtrl,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepTitle('기본 정보'),
          const SizedBox(height: AppSpacing.lg),
          const _FormLabel('상품명'),
          const SizedBox(height: 6),
          _StyledTextField(
            controller: productNameCtrl,
            hint: '상품명을 입력하세요',
          ),
          const SizedBox(height: AppSpacing.lg),
          const _FormLabel('카테고리'),
          const SizedBox(height: 6),
          _StyledDropdown<String>(
            value: category,
            items: categories,
            onChanged: onCategoryChanged,
          ),
          const SizedBox(height: AppSpacing.lg),
          const _FormLabel('상품 설명'),
          const SizedBox(height: 6),
          _StyledTextField(
            controller: descriptionCtrl,
            hint: '상품에 대한 자세한 설명을 입력하세요',
            maxLines: 4,
          ),
          const SizedBox(height: AppSpacing.lg),
          const _FormLabel('상품 이미지'),
          const SizedBox(height: 6),
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border.all(
                color: AppColors.border,
                style: BorderStyle.solid,
              ),
              borderRadius: AppRadius.borderSm,
            ),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera_alt_outlined,
                      size: 32, color: AppColors.textSecondary),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    '이미지 추가',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 2: 옵션 설정 ─────────────────────────────────────────────────────────

class _Step2 extends StatelessWidget {
  final List<String> options;
  final ValueChanged<List<String>> onOptionsChanged;

  const _Step2({required this.options, required this.onOptionsChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepTitle('옵션 설정'),
          const SizedBox(height: AppSpacing.lg),
          ...List.generate(options.length, (i) {
            final ctrl = TextEditingController(text: options[i]);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: ctrl,
                      decoration: InputDecoration(
                        labelText: '옵션명',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md, vertical: AppSpacing.md),
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.borderSm,
                          borderSide:
                              const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppRadius.borderSm,
                          borderSide:
                              const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppRadius.borderSm,
                          borderSide:
                              const BorderSide(color: AppColors.primary),
                        ),
                      ),
                      onChanged: (val) {
                        final updated = List<String>.from(options);
                        updated[i] = val;
                        onOptionsChanged(updated);
                      },
                    ),
                  ),
                  if (i > 0) ...[
                    const SizedBox(width: AppSpacing.sm),
                    GestureDetector(
                      onTap: () {
                        final updated = List<String>.from(options)
                          ..removeAt(i);
                        onOptionsChanged(updated);
                      },
                      child: const Icon(Icons.close,
                          color: AppColors.textSecondary, size: 20),
                    ),
                  ],
                ],
              ),
            );
          }),
          const SizedBox(height: AppSpacing.xs),
          GestureDetector(
            onTap: () {
              onOptionsChanged([...options, '']);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primary,
                  style: BorderStyle.solid,
                ),
                borderRadius: AppRadius.borderSm,
              ),
              child: Center(
                child: Text(
                  '+ 옵션 추가',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primary,
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

// ─── Step 3: 가격 설정 ─────────────────────────────────────────────────────────

class _TierData {
  int minParticipants;
  int price;

  _TierData({required this.minParticipants, required this.price});
}

class _Step3 extends StatelessWidget {
  final List<_TierData> tiers;
  final int maxParticipants;
  final ValueChanged<List<_TierData>> onTiersChanged;

  const _Step3({
    required this.tiers,
    required this.maxParticipants,
    required this.onTiersChanged,
  });

  List<PriceTier> get _priceTiers => tiers
      .map((t) =>
          PriceTier(minParticipants: t.minParticipants, price: t.price))
      .toList();

  @override
  Widget build(BuildContext context) {
    final basePrice = tiers.isNotEmpty ? tiers[0].price : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepTitle('가격 설정'),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: AppRadius.borderSm,
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '사람이 많이 모일수록 가격이 내려가는 구조입니다.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...List.generate(tiers.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: PriceTierInput(
                index: i,
                minParticipants: tiers[i].minParticipants,
                price: tiers[i].price,
                basePrice: i > 0 ? basePrice : null,
                onChange: (min, price) {
                  final updated = List<_TierData>.from(tiers);
                  updated[i] = _TierData(minParticipants: min, price: price);
                  onTiersChanged(updated);
                },
                onDelete: i == 0
                    ? null
                    : () {
                        final updated = List<_TierData>.from(tiers)
                          ..removeAt(i);
                        onTiersChanged(updated);
                      },
              ),
            );
          }),
          if (tiers.length < 5) ...[
            GestureDetector(
              onTap: () {
                onTiersChanged([
                  ...tiers,
                  _TierData(minParticipants: 0, price: 0),
                ]);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.primary,
                  ),
                  borderRadius: AppRadius.borderSm,
                ),
                child: Center(
                  child: Text(
                    '+ 단계 추가',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          PriceTierPreview(
            tiers: _priceTiers,
            maxParticipants: maxParticipants,
          ),
        ],
      ),
    );
  }
}

// ─── Step 4: 펀드 설정 ─────────────────────────────────────────────────────────

class _Step4 extends StatelessWidget {
  final TextEditingController startDateCtrl;
  final TextEditingController endDateCtrl;
  final TextEditingController minParticipantsCtrl;
  final TextEditingController maxParticipantsCtrl;
  final TextEditingController shippingFeeCtrl;
  final String shippingMethod;
  final List<String> shippingMethods;
  final ValueChanged<String?> onShippingMethodChanged;

  const _Step4({
    required this.startDateCtrl,
    required this.endDateCtrl,
    required this.minParticipantsCtrl,
    required this.maxParticipantsCtrl,
    required this.shippingFeeCtrl,
    required this.shippingMethod,
    required this.shippingMethods,
    required this.onShippingMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepTitle('펀드 설정'),
          const SizedBox(height: AppSpacing.lg),
          const _FormLabel('펀드 기간'),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _StyledTextField(
                  controller: startDateCtrl,
                  hint: '시작일 (YYYY-MM-DD)',
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Text('~',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.textSecondary,
                    )),
              ),
              Expanded(
                child: _StyledTextField(
                  controller: endDateCtrl,
                  hint: '종료일 (YYYY-MM-DD)',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const _FormLabel('최소 참여 인원'),
          const SizedBox(height: 6),
          _StyledTextField(
            controller: minParticipantsCtrl,
            hint: '최소 참여 인원 수',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.lg),
          const _FormLabel('최대 참여 인원'),
          const SizedBox(height: 6),
          _StyledTextField(
            controller: maxParticipantsCtrl,
            hint: '최대 참여 인원 수',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.lg),
          const _FormLabel('배송비'),
          const SizedBox(height: 6),
          _StyledTextField(
            controller: shippingFeeCtrl,
            hint: '0원 = 무료배송',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.lg),
          const _FormLabel('배송 방법'),
          const SizedBox(height: 6),
          _StyledDropdown<String>(
            value: shippingMethod,
            items: shippingMethods,
            onChanged: onShippingMethodChanged,
          ),
        ],
      ),
    );
  }
}

// ─── Step 5: 미리보기 ──────────────────────────────────────────────────────────

class _Step5 extends StatelessWidget {
  final String productName;
  final String category;
  final String description;
  final List<String> options;
  final List<PriceTier> tiers;
  final int maxParticipants;
  final String startDate;
  final String endDate;
  final String minParticipants;
  final String shippingFee;
  final String shippingMethod;
  final VoidCallback onSubmit;
  final VoidCallback onEdit;
  final bool isSubmitting;

  const _Step5({
    required this.productName,
    required this.category,
    required this.description,
    required this.options,
    required this.tiers,
    required this.maxParticipants,
    required this.startDate,
    required this.endDate,
    required this.minParticipants,
    required this.shippingFee,
    required this.shippingMethod,
    required this.onSubmit,
    required this.onEdit,
    this.isSubmitting = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepTitle('미리보기'),
          const SizedBox(height: AppSpacing.lg),
          _PreviewSection(
            title: '기본 정보',
            rows: [
              _PreviewRow('상품명', productName.isEmpty ? '-' : productName),
              _PreviewRow('카테고리', category),
              _PreviewRow('설명', description.isEmpty ? '-' : description),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _PreviewSection(
            title: '옵션',
            rows: [
              _PreviewRow('옵션', options.where((o) => o.isNotEmpty).join(', ')),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _PreviewSection(
            title: '가격 구조',
            rows: [
              for (int i = 0; i < tiers.length; i++)
                _PreviewRow(
                  '단계 ${i + 1}',
                  '${formatNumber(tiers[i].minParticipants)}명 이상 → ${formatPrice(tiers[i].price)}',
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (tiers.isNotEmpty) ...[
            PriceTierPreview(
              tiers: tiers,
              maxParticipants: maxParticipants,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          _PreviewSection(
            title: '펀드 설정',
            rows: [
              _PreviewRow('기간', '$startDate ~ $endDate'),
              _PreviewRow('최소 참여', minParticipants.isEmpty ? '-' : '$minParticipants명'),
              _PreviewRow('최대 참여', '${formatNumber(maxParticipants)}명'),
              _PreviewRow('배송비', shippingFee == '0' || shippingFee.isEmpty ? '무료' : '$shippingFee원'),
              _PreviewRow('배송 방법', shippingMethod),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          ElevatedButton(
            onPressed: isSubmitting ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              disabledBackgroundColor:
                  AppColors.primary.withValues(alpha: 0.6),
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.borderSm,
              ),
              elevation: 0,
            ),
            child: isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                    ),
                  )
                : Text(
                    '이대로 게시하기',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.onPrimary,
                    ),
                  ),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: onEdit,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border),
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.borderSm,
              ),
            ),
            child: Text(
              '수정하기',
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _PreviewSection extends StatelessWidget {
  final String title;
  final List<_PreviewRow> rows;

  const _PreviewSection({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
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
          Text(
            title,
            style: AppTextStyles.labelLarge,
          ),
          const SizedBox(height: 10),
          ...rows,
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _PreviewRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared Helpers ───────────────────────────────────────────────────────────

class _StepTitle extends StatelessWidget {
  final String text;
  const _StepTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.titleMedium,
    );
  }
}

class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.labelLarge,
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType keyboardType;

  const _StyledTextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.textTertiary,
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.md),
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
        filled: true,
        fillColor: AppColors.surface,
      ),
    );
  }
}

class _StyledDropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  const _StyledDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: AppRadius.borderSm,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        onChanged: onChanged,
        items: items
            .map((item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    item.toString(),
                    style: AppTextStyles.bodyLarge,
                  ),
                ))
            .toList(),
      ),
    );
  }
}
