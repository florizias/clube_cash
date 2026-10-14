import 'dart:typed_data';

import 'package:flutter/material.dart';

class StoreLogoPreview extends StatelessWidget {
  final Uint8List? imageBytes;
  final String imageUrl;
  final double size;

  const StoreLogoPreview({super.key, required this.imageBytes, required this.imageUrl, this.size = 120});

  @override
  Widget build(BuildContext context) {
    if (imageBytes != null) {
      return Image.memory(imageBytes!, width: size, height: size, fit: BoxFit.cover);
    }

    if (imageUrl.trim().isNotEmpty) {
      return Image.network(
        imageUrl.trim(),
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;

          return _LogoFallback(
            size: size,
            child: const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
        errorBuilder: (_, _, _) {
          return _LogoFallback(size: size);
        },
      );
    }

    return _LogoFallback(size: size);
  }
}

class _LogoFallback extends StatelessWidget {
  final double size;
  final Widget? child;

  const _LogoFallback({required this.size, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: const Color(0xFFF1F5F9),
      alignment: Alignment.center,
      child: child ?? const Icon(Icons.store, color: Color(0xFF94A3B8), size: 34),
    );
  }
}
