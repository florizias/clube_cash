import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  final String imageUrl;

  const ProductImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final cleanUrl = imageUrl.trim();

    if (cleanUrl.isEmpty) {
      return const _ProductImageFallback();
    }

    return Image.network(
      cleanUrl,
      width: 96,
      height: 96,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;

        return const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)));
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
      child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF64748B), size: 26),
    );
  }
}
