import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class CountdownTimer extends StatefulWidget {
  const CountdownTimer({
    super.key,
    required this.endAt,
    this.isBadge = true,
  });

  final DateTime endAt;
  final bool isBadge;

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.endAt.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _remaining = widget.endAt.difference(DateTime.now());
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    if (d.isNegative || d == Duration.zero) return '마감';

    final days = d.inDays;
    final hours = d.inHours.remainder(24).toString().padLeft(2, '0');
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');

    if (days >= 1) {
      // ignore: unnecessary_brace_in_string_interps
      return '${days}일 $hours:$minutes:$seconds';
    } else {
      return '$hours:$minutes:$seconds 남음';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnded = _remaining.isNegative || _remaining == Duration.zero;
    final text = _formatDuration(_remaining);

    if (widget.isBadge) {
      return Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: 2),
        decoration: BoxDecoration(
          color: isEnded ? AppColors.textSecondary : AppColors.error,
          borderRadius: AppRadius.borderXs,
        ),
        child: Text(
          text,
          style: AppTextStyles.countdownSmall.copyWith(
            color: AppColors.textInverse,
          ),
        ),
      );
    }

    // inline mode
    return Text(
      text,
      style: AppTextStyles.bodyLarge.copyWith(
        color: isEnded ? AppColors.textSecondary : AppColors.error,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
