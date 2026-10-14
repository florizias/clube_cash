import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/theme_exports.dart';

class NewsCardItem extends StatelessWidget {
  final String title;
  final String buttonText;
  final String thumbnailUrl;
  final VoidCallback onPressed;

  const NewsCardItem({super.key, required this.title, required this.buttonText, required this.thumbnailUrl, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final imageUrl = thumbnailUrl.trim();

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Positioned.fill(
            child: imageUrl.isEmpty
                ? const _NewsImageFallback()
                : Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;

                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('Erro ao carregar imagem do banner: $error');
                      debugPrint('URL do banner: $imageUrl');

                      return const _NewsImageFallback();
                    },
                  ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withValues(alpha: 0.70), Colors.black.withValues(alpha: 0.10)],
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFFFFFFFF)),
                ),
                SizedBox(height: AppSpacing.sm),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    foregroundColor: const Color(0xFFFFFFFF),
                    side: const BorderSide(color: Color(0xFFFFFFFF)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  onPressed: onPressed,
                  child: Text(buttonText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsImageFallback extends StatelessWidget {
  const _NewsImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE5E7EB),
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported_outlined, color: Color(0xFF64748B)),
    );
  }
}
