import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/app_radius.dart';
import '../widgets/responsive_container.dart';
import '../services/fund_service.dart';

class SellerApplyScreen extends StatefulWidget {
  const SellerApplyScreen({super.key});

  @override
  State<SellerApplyScreen> createState() => _SellerApplyScreenState();
}

class _SellerApplyScreenState extends State<SellerApplyScreen> {
  final _brandNameCtrl = TextEditingController();
  final _ownerNameCtrl = TextEditingController();
  final _bizNumberCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _channelUrlCtrl = TextEditingController();
  final _mainProductCtrl = TextEditingController();
  final _introCtrl = TextEditingController();

  @override
  void dispose() {
    _brandNameCtrl.dispose();
    _ownerNameCtrl.dispose();
    _bizNumberCtrl.dispose();
    _phoneCtrl.dispose();
    _channelUrlCtrl.dispose();
    _mainProductCtrl.dispose();
    _introCtrl.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  void _showError(String message) {
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
    // Validate required fields
    if (_brandNameCtrl.text.trim().isEmpty) {
      _showError('브랜드명을 입력해주세요.');
      return;
    }
    if (_ownerNameCtrl.text.trim().isEmpty) {
      _showError('대표자명을 입력해주세요.');
      return;
    }
    if (_phoneCtrl.text.trim().isEmpty) {
      _showError('연락처를 입력해주세요.');
      return;
    }
    if (_bizNumberCtrl.text.trim().isEmpty) {
      _showError('사업자등록번호를 입력해주세요.');
      return;
    }
    if (_mainProductCtrl.text.trim().isEmpty) {
      _showError('주요 판매 상품을 입력해주세요.');
      return;
    }

    setState(() => _isLoading = true);

    final success = await FundService.instance.submitSellerApplication({
      'brandName': _brandNameCtrl.text.trim(),
      'ownerName': _ownerNameCtrl.text.trim(),
      'bizNumber': _bizNumberCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'channelUrl': _channelUrlCtrl.text.trim(),
      'mainProduct': _mainProductCtrl.text.trim(),
      'intro': _introCtrl.text.trim(),
    });

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
          title: Text(
            '신청 완료',
            style: AppTextStyles.titleMedium,
          ),
          content: Text(
            '신청이 완료되었습니다!\n검토 후 영업일 3일 이내에 연락드리겠습니다.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.borderSm,
                ),
                elevation: 0,
              ),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('셀러 입점 신청'),
      ),
      body: ResponsiveContainer.form(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top copy
              Text(
                '광고비 0원으로 매출을 만드세요',
                style: AppTextStyles.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '지금 입점 신청하면 첫 3회 수수료 무료!',
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 28),

              // Form fields
              _FormField(
                label: '브랜드명',
                controller: _brandNameCtrl,
                hint: '브랜드명을 입력하세요',
              ),
              const SizedBox(height: AppSpacing.lg),
              _FormField(
                label: '대표자명',
                controller: _ownerNameCtrl,
                hint: '대표자명을 입력하세요',
              ),
              const SizedBox(height: AppSpacing.lg),
              _FormField(
                label: '사업자등록번호',
                controller: _bizNumberCtrl,
                hint: '000-00-00000',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.lg),
              _FormField(
                label: '연락처',
                controller: _phoneCtrl,
                hint: '010-0000-0000',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppSpacing.lg),
              _FormField(
                label: '기존 판매 채널 URL',
                controller: _channelUrlCtrl,
                hint: 'https://',
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: AppSpacing.lg),
              _FormField(
                label: '주요 판매 상품',
                controller: _mainProductCtrl,
                hint: '주요 판매 상품을 입력하세요',
              ),
              const SizedBox(height: AppSpacing.lg),
              _FormField(
                label: '자기소개/메시지',
                controller: _introCtrl,
                hint: '브랜드 소개 및 입점 신청 메시지를 작성해주세요',
                maxLines: 5,
              ),
              const SizedBox(height: 28),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.borderMd,
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
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
                          '입점 신청하기',
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.onPrimary,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType keyboardType;

  const _FormField({
    required this.label,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelLarge,
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textTertiary,
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 13),
            filled: true,
            fillColor: AppColors.surface,
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
        ),
      ],
    );
  }
}
