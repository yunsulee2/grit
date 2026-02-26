import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grit/theme/app_colors.dart';

class ShareButtons extends StatelessWidget {
  final String shareUrl;
  final String productName;

  const ShareButtons({
    super.key,
    required this.shareUrl,
    required this.productName,
  });

  void _copyLink(BuildContext context) {
    Clipboard.setData(ClipboardData(text: shareUrl)).then((_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('링크가 복사되었습니다!'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ShareButton(
          icon: Icons.chat_bubble,
          label: '카카오톡 공유',
          background: _KakaoBackground(),
          iconColor: const Color(0xFF3A1D1D),
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('카카오톡 공유는 앱에서 사용 가능합니다'),
              duration: Duration(seconds: 2),
            ),
          ),
        ),
        const SizedBox(width: 24),
        _ShareButton(
          icon: Icons.camera_alt,
          label: '인스타 스토리',
          background: _InstaBackground(),
          iconColor: AppColors.surface,
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('인스타그램 공유는 앱에서 사용 가능합니다'),
              duration: Duration(seconds: 2),
            ),
          ),
        ),
        const SizedBox(width: 24),
        _ShareButton(
          icon: Icons.link,
          label: '링크 복사',
          background: _SolidBackground(color: const Color(0xFFF0F0F0)),
          iconColor: AppColors.textSecondary,
          onTap: () => _copyLink(context),
        ),
      ],
    );
  }
}

// ─── Individual button ────────────────────────────────────────────────────────

class _ShareButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget background;
  final Color iconColor;
  final VoidCallback onTap;

  const _ShareButton({
    required this.icon,
    required this.label,
    required this.background,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              children: [
                ClipOval(child: background),
                Center(
                  child: Icon(icon, color: iconColor, size: 22),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Background helpers ───────────────────────────────────────────────────────

class _KakaoBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      color: const Color(0xFFFEE500),
    );
  }
}

class _InstaBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            Color(0xFFF9CE34),
            Color(0xFFEE2A7B),
            Color(0xFF6228D7),
          ],
        ),
      ),
    );
  }
}

class _SolidBackground extends StatelessWidget {
  final Color color;

  const _SolidBackground({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(width: 48, height: 48, color: color);
  }
}
