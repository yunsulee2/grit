import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

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
    return Image.network(
      url,
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
        child: Icon(Icons.broken_image_outlined, color: AppColors.textDisabled, size: 40),
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
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        // ── Toggle row ───────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  '원본 상세페이지 그대로 사용',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
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
        const SizedBox(height: 12),

        // ── Content area ─────────────────────────────────────────────────────
        if (widget.useOriginal) ...[
          if (displayImages.isEmpty)
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(
                child: Text(
                  '상세 이미지가 없습니다',
                  style: TextStyle(
                    color: AppColors.textDisabled,
                    fontSize: 14,
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
          const SizedBox(height: 8),
          // ── Info text ──────────────────────────────────────────────────────
          Row(
            children: const [
              Icon(Icons.info_outline, size: 13, color: AppColors.textSecondary),
              SizedBox(width: 4),
              Text(
                '최대 30장까지 표시됩니다',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ] else ...[
          // ── Text editor ─────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.edit_note, color: AppColors.primary, size: 18),
                    SizedBox(width: 6),
                    Text(
                      '상세페이지 직접 작성',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _textController,
                  maxLines: 6,
                  enabled: true,
                  decoration: InputDecoration(
                    hintText: '상세페이지 내용을 입력하세요',
                    hintStyle: const TextStyle(
                      color: AppColors.textDisabled,
                      fontSize: 13,
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
                    contentPadding: const EdgeInsets.all(12),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
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
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),

            // ── Delete button (top-right) ────────────────────────────────────
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => _deleteImage(index),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),

            // ── Image number label (bottom-left) ─────────────────────────────
            Positioned(
              bottom: 8,
              left: 44,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.50),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${index + 1}/$total',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
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
