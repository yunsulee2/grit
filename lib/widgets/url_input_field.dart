import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/app_radius.dart';
import '../services/site_detector.dart';

class UrlInputField extends StatefulWidget {
  final void Function(String url, SupportedSite site) onSubmit;
  const UrlInputField({super.key, required this.onSubmit});

  @override
  State<UrlInputField> createState() => _UrlInputFieldState();
}

class _UrlInputFieldState extends State<UrlInputField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  String _url = '';
  bool _checkedOwnership = false;
  bool _showValidationError = false;

  SupportedSite? _detectedSite;

  bool get _isValidUrl => SiteDetector.isValidUrl(_url);
  bool get _canSubmit => _isValidUrl && _checkedOwnership;

  void _onUrlChanged(String value) {
    setState(() {
      _url = value;
      _showValidationError = false;
      if (value.isEmpty) {
        _detectedSite = null;
      } else {
        _detectedSite = SiteDetector.detect(value);
      }
    });
  }

  void _onSubmit() {
    if (!_isValidUrl) {
      setState(() => _showValidationError = true);
      return;
    }
    if (!_checkedOwnership) return;
    widget.onSubmit(_url, _detectedSite ?? SupportedSite.other);
  }

  Color get _borderColor {
    if (_showValidationError && !_isValidUrl) return AppColors.error;
    if (_focusNode.hasFocus) return AppColors.primary;
    return AppColors.border;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final warning = _detectedSite != null
        ? SiteDetector.getWarningMessage(_detectedSite!)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // URL text field
        AnimatedBuilder(
          animation: _focusNode,
          builder: (context, child) {
            return Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.borderSm,
                border: Border.all(color: _borderColor),
              ),
              child: Row(
                children: [
                  const SizedBox(width: AppSpacing.md),
                  Icon(
                    Icons.link,
                    size: 20,
                    color: _focusNode.hasFocus
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      onChanged: _onUrlChanged,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'https://www.coupang.com/vp/products/...',
                        hintStyle: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _onSubmit(),
                    ),
                  ),
                  // Site badge
                  if (_detectedSite != null && _url.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: _SiteBadge(site: _detectedSite!),
                    ),
                ],
              ),
            );
          },
        ),

        // Validation error
        if (_showValidationError && !_isValidUrl) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            'URL 형식이 올바르지 않습니다',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.error,
            ),
          ),
        ],

        // Non-P0 site warning
        if (warning != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            warning,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],

        const SizedBox(height: 6),

        // Supported sites hint
        Text(
          '쿠팡, 네이버 스마트스토어, 카카오 톡딜 URL을 지원합니다',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Ownership checkbox
        GestureDetector(
          onTap: () => setState(() => _checkedOwnership = !_checkedOwnership),
          behavior: HitTestBehavior.opaque,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: _checkedOwnership,
                  onChanged: (v) =>
                      setState(() => _checkedOwnership = v ?? false),
                  activeColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.border, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderXs,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '해당 URL의 상품은 본인이 판매 권한을 가진 상품입니다',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Submit button
        SizedBox(
          width: double.infinity,
          height: AppSpacing.xxxxl,
          child: ElevatedButton(
            onPressed: _canSubmit ? _onSubmit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.textTertiary,
              foregroundColor: AppColors.surface,
              disabledForegroundColor: AppColors.surface,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.borderSm,
              ),
            ),
            child: Text(
              '가져오기',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.onPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SiteBadge extends StatelessWidget {
  final SupportedSite site;
  const _SiteBadge({required this.site});

  Color get _badgeColor {
    switch (site) {
      case SupportedSite.coupang:
        return const Color(0xFFE8192C); // Coupang red
      case SupportedSite.naver:
        return const Color(0xFF03C75A); // Naver green
      case SupportedSite.kakao:
        return const Color(0xFFFFE000); // Kakao yellow
      case SupportedSite.other:
        return AppColors.textSecondary;
    }
  }

  Color get _textColor {
    return site == SupportedSite.kakao
        ? AppColors.textPrimary
        : AppColors.surface;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
      decoration: BoxDecoration(
        color: _badgeColor,
        borderRadius: AppRadius.borderXs,
      ),
      child: Text(
        SiteDetector.displayName(site),
        style: AppTextStyles.labelSmall.copyWith(
          fontWeight: FontWeight.w600,
          color: _textColor,
        ),
      ),
    );
  }
}
