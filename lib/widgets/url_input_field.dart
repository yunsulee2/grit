import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
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
    if (_showValidationError && !_isValidUrl) return AppColors.accentRed;
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
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _borderColor),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(
                    Icons.link,
                    size: 20,
                    color: _focusNode.hasFocus
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      onChanged: _onUrlChanged,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'https://www.coupang.com/vp/products/...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: AppColors.textDisabled,
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
                      padding: const EdgeInsets.only(right: 8),
                      child: _SiteBadge(site: _detectedSite!),
                    ),
                ],
              ),
            );
          },
        ),

        // Validation error
        if (_showValidationError && !_isValidUrl) ...[
          const SizedBox(height: 4),
          const Text(
            'URL 형식이 올바르지 않습니다',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.accentRed,
            ),
          ),
        ],

        // Non-P0 site warning
        if (warning != null) ...[
          const SizedBox(height: 4),
          Text(
            warning,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.primary,
            ),
          ),
        ],

        const SizedBox(height: 6),

        // Supported sites hint
        const Text(
          '쿠팡, 네이버 스마트스토어, 카카오 톡딜 URL을 지원합니다',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: 16),

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
                    borderRadius: BorderRadius.circular(4),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '해당 URL의 상품은 본인이 판매 권한을 가진 상품입니다',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Submit button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _canSubmit ? _onSubmit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.textDisabled,
              foregroundColor: AppColors.surface,
              disabledForegroundColor: AppColors.surface,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              '가져오기',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
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
        ? AppColors.secondary
        : AppColors.surface;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _badgeColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        SiteDetector.displayName(site),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _textColor,
        ),
      ),
    );
  }
}
