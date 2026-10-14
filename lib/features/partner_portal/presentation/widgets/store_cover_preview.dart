import 'dart:typed_data';

import 'package:flutter/material.dart';

class StoreCoverPreview extends StatelessWidget {
  final Uint8List? imageBytes;
  final String imageUrl;
  final double height;
  final BorderRadius borderRadius;

  const StoreCoverPreview({
    super.key,
    required this.imageBytes,
    required this.imageUrl,
    this.height = 200,
    this.borderRadius = const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
  });

  @override
  Widget build(BuildContext context) {
    final cleanUrl = imageUrl.trim();

    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(height: height, width: double.infinity, child: _buildImage(cleanUrl)),
    );
  }

  Widget _buildImage(String cleanUrl) {
    if (imageBytes != null) {
      return Image.memory(imageBytes!, height: height, width: double.infinity, fit: BoxFit.cover);
    }

    if (cleanUrl.isNotEmpty) {
      return Image.network(
        cleanUrl,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;

          return const _CoverFallback(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)));
        },
        errorBuilder: (_, _, _) {
          return const _CoverFallback();
        },
      );
    }

    return const _CoverFallback();
  }
}

class _CoverFallback extends StatelessWidget {
  final Widget? child;

  const _CoverFallback({this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      color: const Color(0xFFE5E7EB),
      alignment: Alignment.center,
      child: child ?? const Icon(Icons.image, color: Color(0xFF94A3B8), size: 34),
    );
  }
}
