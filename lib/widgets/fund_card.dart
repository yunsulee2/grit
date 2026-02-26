import 'dart:async';
import 'package:flutter/material.dart';
import '../models/fund.dart';
import '../theme/app_colors.dart';

class FundCard extends StatefulWidget {
  final Fund fund;
  final VoidCallback? onTap;
  final bool showProgressOverlay;

  const FundCard({
    super.key,
    required this.fund,
    this.onTap,
    this.showProgressOverlay = false,
  });

  @override
  State<FundCard> createState() => _FundCardState();
}

class _FundCardState extends State<FundCard> {
  late Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.fund.endAt.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _remaining = widget.fund.endAt.difference(DateTime.now());
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    if (d.isNegative) return '마감';
    if (d.inDays >= 1) return '마감 ${d.inDays}일전';
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s 남음';
  }

  String _formatPrice(int price) {
    final str = price.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return '${buffer.toString()}원';
  }

  @override
  Widget build(BuildContext context) {
    final fund = widget.fund;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF0F0F0), width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Image with timer badge and optional progress overlay
            AspectRatio(
              aspectRatio: 0.8,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image with top-only rounded corners
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Image.asset(
                      fund.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, _) => Container(
                        color: AppColors.background,
                        child: const Center(
                          child: Icon(
                            Icons.fastfood,
                            size: 40,
                            color: AppColors.textDisabled,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Timer badge — top left
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xCC000000),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _formatDuration(_remaining),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),

                  // Progress overlay — bottom of image, only for featured card
                  if (widget.showProgressOverlay)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        color: const Color(0xCC000000),
                        padding: const EdgeInsets.fromLTRB(8, 5, 8, 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_formatPrice(fund.currentParticipants).replaceAll('원', '')}개',
                                  style: const TextStyle(
                                    color: Color(0xFFFF6B35),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '목표 ${_formatPrice(fund.maxParticipants).replaceAll('원', '')}개',
                                  style: const TextStyle(
                                    color: Color(0xCCFFFFFF),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: fund.progressRatio,
                                minHeight: 3,
                                backgroundColor: const Color(0x55FFFFFF),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFFFF6B35),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 2. Text area
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 3. Tags row
                  if (fund.freeShipping)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          _Tag(label: '무료배송'),
                        ],
                      ),
                    ),

                  // 4. Product name
                  Text(
                    fund.productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF333333),
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // 5. Price section
                  // Line 1: 공구가 + main price + original price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      const Text(
                        '공구가 ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF3B30),
                        ),
                      ),
                      Text(
                        _formatPrice(fund.startPrice),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatPrice(fund.targetPrice),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                          decoration: TextDecoration.lineThrough,
                          decorationColor: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 2),

                  // Line 2: 최대혜택가
                  Text(
                    '최대혜택가 ${_formatPrice(fund.targetPrice)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF3B30),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;

  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          color: Color(0xFF666666),
        ),
      ),
    );
  }
}
