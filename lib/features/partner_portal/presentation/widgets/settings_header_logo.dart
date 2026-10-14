import 'dart:typed_data';

import 'package:flutter/material.dart';

class SettingsHeaderLogo extends StatelessWidget {
  final Uint8List? logoBytes;
  final String logoUrl;

  const SettingsHeaderLogo({super.key, required this.logoBytes, required this.logoUrl});

  @override
  Widget build(BuildContext context) {
    final cleanUrl = logoUrl.trim();

    return ClipOval(child: SizedBox(width: 44, height: 44, child: _buildLogo(cleanUrl)));
  }

  Widget _buildLogo(String cleanUrl) {
    if (logoBytes != null) {
      return Image.memory(logoBytes!, width: 44, height: 44, fit: BoxFit.cover);
    }

    if (cleanUrl.isNotEmpty) {
      return Image.network(
        cleanUrl,
        width: 44,
        height: 44,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return const _LogoFallback();
        },
      );
    }

    return const _LogoFallback();
  }
}

class _LogoFallback extends StatelessWidget {
  const _LogoFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      color: const Color(0xFFFAFAF8),
      alignment: Alignment.center,
      child: const Icon(Icons.store, color: Color(0xFF94A3B8), size: 24),
    );
  }
}
