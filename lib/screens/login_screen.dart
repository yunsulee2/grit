import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _handleLogin(Future<void> Function() loginFn) async {
    setState(() => _isLoading = true);
    try {
      await loginFn();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('로그인되었습니다'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showEmailDialog() async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('이메일 로그인'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: '이메일',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '비밀번호',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.surface,
            ),
            child: const Text('로그인'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _handleLogin(
        () => AuthService.instance.loginWithEmail(
          emailController.text,
          passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          SafeArea(
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
                    onTap: _isLoading
                        ? null
                        : () => _handleLogin(
                              AuthService.instance.loginWithKakao,
                            ),
                  ),
                  const SizedBox(height: 12),
                  // Naver button
                  _LoginButton(
                    label: '네이버로 시작하기',
                    backgroundColor: const Color(0xFF03C75A),
                    textColor: AppColors.surface,
                    icon: Icons.shield,
                    iconColor: AppColors.surface,
                    onTap: _isLoading
                        ? null
                        : () => _handleLogin(
                              AuthService.instance.loginWithNaver,
                            ),
                  ),
                  const SizedBox(height: 12),
                  // Email button
                  _LoginButton(
                    label: '이메일로 시작하기',
                    backgroundColor: const Color(0xFFF0F0F0),
                    textColor: AppColors.textPrimary,
                    icon: Icons.email_outlined,
                    iconColor: AppColors.textPrimary,
                    onTap: _isLoading ? null : _showEmailDialog,
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
          // Loading overlay
          if (_isLoading)
            const ColoredBox(
              color: Color(0x55000000),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
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
  final VoidCallback? onTap;

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
