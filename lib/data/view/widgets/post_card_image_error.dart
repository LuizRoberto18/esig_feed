import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Widget de fallback para quando a imagem não carrega
class PostCardImageError extends StatelessWidget {
  const PostCardImageError({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: const Center(
        child: Icon(
          Icons.image_not_supported,
          color: AppColors.textHint,
          size: 60,
        ),
      ),
    );
  }
}
