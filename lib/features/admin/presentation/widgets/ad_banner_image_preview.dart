import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AdBannerImagePreview extends StatelessWidget {
  final Uint8List? imageBytes;
  final String imageUrl;
  final VoidCallback? onTap;
  final bool enabled;
  final double aspectRatio;

  const AdBannerImagePreview({
    super.key,
    required this.imageBytes,
    required this.imageUrl,
    required this.onTap,
    this.enabled = true,
    this.aspectRatio = 16 / 9,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              _buildImage(),
              Container(color: Colors.black.withValues(alpha: 0.18)),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.28), borderRadius: BorderRadius.circular(100)),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'assets/icons/edit.svg',
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(Color(0xFFFFFFFF), BlendMode.srcIn),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (imageBytes != null) {
      return Image.memory(imageBytes!, width: double.infinity, height: double.infinity, fit: BoxFit.cover);
    }

    final cleanUrl = imageUrl.trim();

    if (cleanUrl.isNotEmpty) {
      return Image.network(
        cleanUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;

          return const _BannerFallback(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)));
        },
        errorBuilder: (_, _, _) {
          return const _BannerFallback();
        },
      );
    }

    return const _BannerFallback();
  }
}

class _BannerFallback extends StatelessWidget {
  final Widget? child;

  const _BannerFallback({this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F5F9),
      alignment: Alignment.center,
      child:
          child ??
          SvgPicture.asset('assets/icons/image.svg', width: 36, height: 36, colorFilter: const ColorFilter.mode(Color(0xFF0038BC), BlendMode.srcIn)),
    );
  }
}
