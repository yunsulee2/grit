import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/app_radius.dart';
import '../services/scrape_service.dart';

class DetailImageList extends StatefulWidget {
  final List<String> imageUrls;
  final ValueChanged<List<String>> onChanged;
  final bool useOriginal;
  final ValueChanged<bool> onUseOriginalChanged;

  const DetailImageList({
    super.key,
    required this.imageUrls,
    required this.onChanged,
    this.useOriginal = true,
    required this.onUseOriginalChanged,
  });

  @override
  State<DetailImageList> createState() => _DetailImageListState();
}

class _DetailImageListState extends State<DetailImageList> {
  late List<String> _images;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _images = List<String>.from(widget.imageUrls);
  }

  @override
  void didUpdateWidget(DetailImageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrls != widget.imageUrls) {
      _images = List<String>.from(widget.imageUrls);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _deleteImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
    widget.onChanged(List<String>.from(_images));
  }

  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _images.removeAt(oldIndex);
      _images.insert(newIndex, item);
    });
    widget.onChanged(List<String>.from(_images));
  }

  Widget _buildImage(String url) {
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stack) => _buildErrorPlaceholder(),
      );
    }
    final displayUrl = ScrapeService.proxyImageUrl(url);
    return Image.network(
      displayUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (context, error, stack) => _buildErrorPlaceholder(),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      height: 200,
      color: AppColors.border,
      child: const Center(
        child: Icon(Icons.broken_image_outlined, color: AppColors.textTertiary, size: 40),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayCount = _images.length > 30 ? 30 : _images.length;
    final displayImages = _images.take(30).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──────────────────────────────────────────────────────────
        Text(
          '상세페이지 이미지 (${_images.length}장)',
          style: AppTextStyles.titleSmall,
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Toggle row ───────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.borderSm,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '원본 상세페이지 그대로 사용',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Switch(
                value: widget.useOriginal,
                onChanged: widget.onUseOriginalChanged,
                activeThumbColor: AppColors.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Content area ─────────────────────────────────────────────────────
        if (widget.useOriginal) ...[
          if (displayImages.isEmpty)
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: AppRadius.borderSm,
                border: Border.all(color: AppColors.border),
              ),
              child: Center(
                child: Text(
                  '상세 이미지가 없습니다',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            )
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayCount,
              onReorder: _reorder,
              proxyDecorator: (child, index, animation) {
                return Material(
                  color: Colors.transparent,
                  child: child,
                );
              },
              itemBuilder: (context, index) {
                final url = displayImages[index];
                return _buildImageCard(index, url, displayCount, key: ValueKey(url + index.toString()));
              },
            ),
          const SizedBox(height: AppSpacing.sm),
          // ── Info text ──────────────────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.info_outline, size: 13, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '최대 30장까지 표시됩니다',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ] else ...[
          // ── Text editor ─────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: AppRadius.borderSm,
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.edit_note, color: AppColors.primary, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '상세페이지 직접 작성',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _textController,
                  maxLines: 6,
                  enabled: true,
                  decoration: InputDecoration(
                    hintText: '상세페이지 내용을 입력하세요',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    contentPadding: const EdgeInsets.all(AppSpacing.md),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImageCard(int index, String url, int total, {required Key key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderSm,
          side: const BorderSide(color: AppColors.border),
        ),
        color: AppColors.surface,
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // ── Full-width image ─────────────────────────────────────────────
            _buildImage(url),

            // ── Drag handle (left) ───────────────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              bottom: 0,
              child: Container(
                width: 36,
                color: Colors.black.withValues(alpha: 0.18),
                child: const Center(
                  child: Icon(
                    Icons.drag_handle,
                    color: AppColors.textInverse,
                    size: 20,
                  ),
                ),
              ),
            ),

            // ── Delete button (top-right) ────────────────────────────────────
            Positioned(
              top: AppSpacing.sm,
              right: AppSpacing.sm,
              child: GestureDetector(
                onTap: () => _deleteImage(index),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 16, color: AppColors.textInverse),
                ),
              ),
            ),

            // ── Image number label (bottom-left) ─────────────────────────────
            Positioned(
              bottom: AppSpacing.sm,
              left: 44,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.50),
                  borderRadius: AppRadius.borderMd,
                ),
                child: Text(
                  '${index + 1}/$total',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textInverse,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
