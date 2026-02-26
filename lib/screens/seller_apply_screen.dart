import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

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

  void _submit() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '신청 완료',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          '신청이 완료되었습니다!\n검토 후 영업일 3일 이내에 연락드리겠습니다.',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('셀러 입점 신청'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top copy
            const Text(
              '광고비 0원으로 매출을 만드세요',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '지금 입점 신청하면 첫 3회 수수료 무료!',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 28),

            // Form fields
            _FormField(
              label: '브랜드명',
              controller: _brandNameCtrl,
              hint: '브랜드명을 입력하세요',
            ),
            const SizedBox(height: 16),
            _FormField(
              label: '대표자명',
              controller: _ownerNameCtrl,
              hint: '대표자명을 입력하세요',
            ),
            const SizedBox(height: 16),
            _FormField(
              label: '사업자등록번호',
              controller: _bizNumberCtrl,
              hint: '000-00-00000',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _FormField(
              label: '연락처',
              controller: _phoneCtrl,
              hint: '010-0000-0000',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _FormField(
              label: '기존 판매 채널 URL',
              controller: _channelUrlCtrl,
              hint: 'https://',
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            _FormField(
              label: '주요 판매 상품',
              controller: _mainProductCtrl,
              hint: '주요 판매 상품을 입력하세요',
            ),
            const SizedBox(height: 16),
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
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '입점 신청하기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
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
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textDisabled),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}
