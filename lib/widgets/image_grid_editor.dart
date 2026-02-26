import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../services/scrape_service.dart';

class ImageGridEditor extends StatefulWidget {
  final List<String> imageUrls;
  final ValueChanged<List<String>> onChanged;
  final String title;
  final int maxImages;

  const ImageGridEditor({
    super.key,
    required this.imageUrls,
    required this.onChanged,
    this.title = '상품 이미지',
    this.maxImages = 10,
  });

  @override
  State<ImageGridEditor> createState() => _ImageGridEditorState();
}

class _ImageGridEditorState extends State<ImageGridEditor> {
  late List<String> _images;

  @override
  void initState() {
    super.initState();
    _images = List<String>.from(widget.imageUrls);
  }

  @override
  void didUpdateWidget(ImageGridEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrls != widget.imageUrls) {
      _images = List<String>.from(widget.imageUrls);
    }
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

  void _onAddTap() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: AppRadius.borderFull,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '이미지 추가',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              leading: const Icon(Icons.link, color: AppColors.primary),
              title: const Text('URL에서 가져오기'),
              onTap: () {
                Navigator.pop(ctx);
                _showUrlDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image_outlined,
                  color: AppColors.textSecondary),
              title: const Text('기본 이미지 사용'),
              onTap: () {
                Navigator.pop(ctx);
                _addDefaultImage();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showUrlDialog() {
    final urlCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
        title: Text(
          'URL로 이미지 추가',
          style: AppTextStyles.titleMedium,
        ),
        content: TextField(
          controller: urlCtrl,
          autofocus: true,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            hintText: 'https://example.com/image.jpg',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: AppRadius.borderSm,
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderSm,
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              '취소',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final url = urlCtrl.text.trim();
              if (url.isNotEmpty) {
                setState(() => _images.add(url));
                widget.onChanged(List<String>.from(_images));
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.borderSm,
              ),
            ),
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  void _addDefaultImage() {
    const placeholder = 'assets/images/placeholder.jpg';
    setState(() => _images.add(placeholder));
    widget.onChanged(List<String>.from(_images));
  }

  Widget _buildImage(String url) {
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => _buildErrorPlaceholder(),
      );
    }
    // Use proxy for external URLs to avoid CORS
    final displayUrl = ScrapeService.proxyImageUrl(url);
    return Image.network(
      displayUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) => _buildErrorPlaceholder(),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: AppColors.border,
      child: const Center(
        child: Icon(Icons.broken_image_outlined, color: AppColors.textTertiary, size: 32),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showAdd = _images.length < widget.maxImages;
    // Build flat list of items for the reorderable grid.
    // We use a ReorderableListView with a custom GridView-like approach
    // by wrapping items in rows of 3.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title row
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            '${widget.title} (${_images.length}/${widget.maxImages}장)',
            style: AppTextStyles.titleSmall,
          ),
        ),
        // Grid using Wrap for reordering via long-press drag
        _buildDraggableGrid(showAdd),
      ],
    );
  }

  Widget _buildDraggableGrid(bool showAdd) {
    return _ReorderableImageGrid(
      images: _images,
      showAdd: showAdd,
      onReorder: _reorder,
      onDelete: _deleteImage,
      onAdd: _onAddTap,
      buildImage: _buildImage,
      buildErrorPlaceholder: _buildErrorPlaceholder,
    );
  }
}

// ─── Reorderable grid widget ────────────────────────────────────────────────

class _ReorderableImageGrid extends StatefulWidget {
  final List<String> images;
  final bool showAdd;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(int index) onDelete;
  final VoidCallback onAdd;
  final Widget Function(String url) buildImage;
  final Widget Function() buildErrorPlaceholder;

  const _ReorderableImageGrid({
    required this.images,
    required this.showAdd,
    required this.onReorder,
    required this.onDelete,
    required this.onAdd,
    required this.buildImage,
    required this.buildErrorPlaceholder,
  });

  @override
  State<_ReorderableImageGrid> createState() => _ReorderableImageGridState();
}

class _ReorderableImageGridState extends State<_ReorderableImageGrid> {
  int? _draggingIndex;
  int? _hoverIndex;

  @override
  Widget build(BuildContext context) {
    const columns = 3;
    const spacing = 8.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;

        final items = <Widget>[];

        for (int i = 0; i < widget.images.length; i++) {
          final index = i;
          items.add(_buildDraggableCell(index, cellWidth));
        }

        if (widget.showAdd) {
          items.add(SizedBox(
            width: cellWidth,
            child: AspectRatio(
              aspectRatio: 1,
              child: GestureDetector(
                onTap: widget.onAdd,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.borderSm,
                    color: AppColors.background,
                  ),
                  child: CustomPaint(
                    painter: _DashedBorderPainter(),
                    child: const Center(
                      child: Icon(Icons.add, color: AppColors.textTertiary, size: 32),
                    ),
                  ),
                ),
              ),
            ),
          ));
        }

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items,
        );
      },
    );
  }

  Widget _buildDraggableCell(int index, double cellWidth) {
    final isDragging = _draggingIndex == index;
    final isHover = _hoverIndex == index && _draggingIndex != index;

    return LongPressDraggable<int>(
      key: ValueKey('img-$index-${widget.images[index]}'),
      data: index,
      delay: const Duration(milliseconds: 300),
      onDragStarted: () => setState(() => _draggingIndex = index),
      onDragEnd: (_) => setState(() {
        _draggingIndex = null;
        _hoverIndex = null;
      }),
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.85,
          child: SizedBox(
            width: cellWidth,
            child: _buildCellContent(index, showDelete: false),
          ),
        ),
      ),
      childWhenDragging: SizedBox(
        width: cellWidth,
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: AppRadius.borderSm,
            ),
          ),
        ),
      ),
      child: DragTarget<int>(
        onWillAcceptWithDetails: (details) {
          setState(() => _hoverIndex = index);
          return details.data != index;
        },
        onLeave: (_) => setState(() => _hoverIndex = null),
        onAcceptWithDetails: (details) {
          setState(() => _hoverIndex = null);
          widget.onReorder(details.data, index);
        },
        builder: (context, candidateData, rejectedData) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: cellWidth,
            decoration: BoxDecoration(
              borderRadius: AppRadius.borderSm,
              border: isHover
                  ? Border.all(color: AppColors.primary, width: 2)
                  : null,
            ),
            child: Opacity(
              opacity: isDragging ? 0.0 : 1.0,
              child: _buildCellContent(index, showDelete: true),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCellContent(int index, {required bool showDelete}) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: AppRadius.borderSm,
          child: AspectRatio(
            aspectRatio: 1,
            child: widget.buildImage(widget.images[index]),
          ),
        ),
        if (showDelete)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => widget.onDelete(index),
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 12, color: AppColors.onPrimary),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Dashed border painter ───────────────────────────────────────────────────

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    const radius = 8.0;
    final paint = Paint()
      ..color = AppColors.textTertiary
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.75, 0.75, size.width - 1.5, size.height - 1.5),
      const Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final len = draw ? dashWidth : dashSpace;
        if (draw) {
          canvas.drawPath(
            metric.extractPath(distance, distance + len),
            paint,
          );
        }
        distance += len;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) => false;
}
