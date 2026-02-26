import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('로그인 기능은 준비 중입니다'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),
              // Logo
              const Text(
                'GRIT',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              // Tagline
              const Text(
                '피트니스 식품을 가장 싸게',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 48),
              // Kakao button
              _LoginButton(
                label: '카카오로 시작하기',
                backgroundColor: const Color(0xFFFEE500),
                textColor: const Color(0xFF3A1D1D),
                icon: Icons.chat_bubble,
                iconColor: const Color(0xFF3A1D1D),
                onTap: () => _showComingSoon(context),
              ),
              const SizedBox(height: 12),
              // Naver button
              _LoginButton(
                label: '네이버로 시작하기',
                backgroundColor: const Color(0xFF03C75A),
                textColor: AppColors.surface,
                icon: Icons.shield,
                iconColor: AppColors.surface,
                onTap: () => _showComingSoon(context),
              ),
              const SizedBox(height: 12),
              // Email button
              _LoginButton(
                label: '이메일로 시작하기',
                backgroundColor: const Color(0xFFF0F0F0),
                textColor: AppColors.textPrimary,
                icon: Icons.email_outlined,
                iconColor: AppColors.textPrimary,
                onTap: () => _showComingSoon(context),
              ),
              const Spacer(),
              // Terms notice
              const Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: Text(
                  '계속 진행하면 이용약관 및 개인정보 처리방침에 동의하는 것으로 간주합니다.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _LoginButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: iconColor, size: 20),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
