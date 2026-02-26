import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StepIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;

  const StepIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          for (int i = 1; i <= totalSteps; i++) ...[
            _StepCircle(step: i, currentStep: currentStep),
            if (i < totalSteps)
              Expanded(
                child: _StepLine(completed: i < currentStep),
              ),
          ],
        ],
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  final int step;
  final int currentStep;

  const _StepCircle({required this.step, required this.currentStep});

  bool get _isCompleted => step < currentStep;
  bool get _isCurrent => step == currentStep;

  @override
  Widget build(BuildContext context) {
    final bool active = _isCompleted || _isCurrent;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? AppColors.primary : AppColors.border,
      ),
      child: Center(
        child: _isCompleted
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : Text(
                '$step',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color:
                      _isCurrent ? Colors.white : AppColors.textSecondary,
                ),
              ),
      ),
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool completed;

  const _StepLine({required this.completed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      color: completed ? AppColors.primary : AppColors.border,
    );
  }
}
