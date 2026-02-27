import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Renders an image from either an asset path or a network URL.
/// Used everywhere fund.imageUrl is displayed.
class FundImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final IconData errorIcon;
  final double errorIconSize;
  final Color errorIconColor;
  final Color errorBgColor;

  const FundImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorIcon = Icons.fastfood,
    this.errorIconSize = 40,
    this.errorIconColor = AppColors.textTertiary,
    this.errorBgColor = AppColors.background,
  });

  @override
  Widget build(BuildContext context) {
    final errorWidget = Container(
      width: width,
      height: height,
      color: errorBgColor,
      child: Center(
        child: Icon(errorIcon, size: errorIconSize, color: errorIconColor),
      ),
    );

    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => errorWidget,
      );
    }
    return Image.asset(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, _, _) => errorWidget,
    );
  }
}
