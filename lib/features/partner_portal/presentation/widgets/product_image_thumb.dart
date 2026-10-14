import 'package:flutter/material.dart';

class ProductImageThumb extends StatelessWidget {
  final String imageUrl;

  const ProductImageThumb({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final cleanUrl = imageUrl.trim();

    if (cleanUrl.isEmpty) {
      return const _ProductImageFallback();
    }

    return Image.network(
      cleanUrl,
      key: ValueKey(cleanUrl),
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;

        return Container(
          color: const Color(0xFFF1F5F9),
          alignment: Alignment.center,
          child: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
      errorBuilder: (_, _, _) {
        return const _ProductImageFallback();
      },
    );
  }
}

class _ProductImageFallback extends StatelessWidget {
  const _ProductImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F5F9),
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported_outlined, color: Color(0xFF6A1B9A), size: 26),
    );
  }
}
