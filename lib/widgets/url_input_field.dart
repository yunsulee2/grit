import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/app_radius.dart';
import '../services/site_detector.dart';
import 'link_help_sheet.dart';

/// Paste-first URL input field for businesses unfamiliar with URLs.
/// Primary action: big "붙여넣기" button that auto-reads clipboard.
/// Secondary: expandable text field for manual input.
class UrlInputField extends StatefulWidget {
  final void Function(String url, SupportedSite site) onSubmit;
  const UrlInputField({super.key, required this.onSubmit});

  @override
  State<UrlInputField> createState() => _UrlInputFieldState();
}

class _UrlInputFieldState extends State<UrlInputField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  bool _showManualInput = false;
  bool _showPasteError = false;
  String _pasteErrorMessage = '';

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _onPaste() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text?.trim() ?? '';

      if (text.isEmpty) {
        _showError('클립보드가 비어있어요. 먼저 상품 링크를 복사해 주세요.');
        return;
      }

      if (!SiteDetector.isValidUrl(text)) {
        _showError('복사한 내용이 링크가 아닌 것 같아요. 상품 페이지에서 링크를 다시 복사해 주세요.');
        _controller.text = text;
        setState(() => _showManualInput = true);
        return;
      }

      // Valid URL — auto-submit
      final site = SiteDetector.detect(text);
      _controller.text = text;
      setState(() {
        _showPasteError = false;
        _pasteErrorMessage = '';
      });
      widget.onSubmit(text, site);
    } catch (_) {
      _showError('클립보드를 읽을 수 없어요. 링크를 직접 입력해 주세요.');
      setState(() => _showManualInput = true);
    }
  }

  void _onManualSubmit() {
    final url = _controller.text.trim();
    if (url.isEmpty) {
      _showError('링크를 입력해 주세요.');
      return;
    }
    if (!SiteDetector.isValidUrl(url)) {
      _showError('올바른 링크가 아닌 것 같아요. http:// 또는 https://로 시작하는 상품 페이지 링크를 입력해 주세요.');
      return;
    }
    final site = SiteDetector.detect(url);
    setState(() {
      _showPasteError = false;
      _pasteErrorMessage = '';
    });
    widget.onSubmit(url, site);
  }

  void _showError(String message) {
    setState(() {
      _showPasteError = true;
      _pasteErrorMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main CTA: Paste button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _onPaste,
            icon: const Icon(Icons.content_paste, size: 22),
            label: Text(
              '링크 붙여넣기',
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.onPrimary,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.borderMd,
              ),
            ),
          ),
        ),

        // Paste error message
        if (_showPasteError) ...[
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: AppRadius.borderSm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, size: 16, color: AppColors.error),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _pasteErrorMessage,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: AppSpacing.lg),

        // Manual input toggle
        GestureDetector(
          onTap: () => setState(() => _showManualInput = !_showManualInput),
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '또는 직접 입력',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                _showManualInput ? Icons.expand_less : Icons.expand_more,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),

        // Manual text field (expandable)
        if (_showManualInput) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.borderSm,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const SizedBox(width: AppSpacing.md),
                const Icon(Icons.link, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: '쇼핑몰 상품 페이지 링크',
                      hintStyle: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _onManualSubmit(),
                  ),
                ),
                // Submit button inside field
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: _onManualSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.borderXs,
                        ),
                      ),
                      child: Text(
                        '가져오기',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: AppSpacing.lg),

        // Supported sites + help link
        Row(
          children: [
            _MiniSiteBadge(label: '쿠팡', color: const Color(0xFFE8192C)),
            const SizedBox(width: 6),
            _MiniSiteBadge(label: '네이버', color: const Color(0xFF03C75A)),
            const SizedBox(width: 6),
            _MiniSiteBadge(label: '카카오', color: const Color(0xFFFFE000), darkText: true),
            const SizedBox(width: 6),
            Text(
              '등 지원',
              style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => LinkHelpSheet.show(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.help_outline, size: 14, color: AppColors.textTertiary),
                  const SizedBox(width: 4),
                  Text(
                    '링크 찾는 법',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MiniSiteBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool darkText;

  const _MiniSiteBadge({
    required this.label,
    required this.color,
    this.darkText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppRadius.borderXs,
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: darkText ? AppColors.textPrimary : color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
