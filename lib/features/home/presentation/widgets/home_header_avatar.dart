import 'package:flutter/material.dart';

class HomeHeaderAvatar extends StatelessWidget {
  final String photoUrl;

  const HomeHeaderAvatar({super.key, required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    final cleanUrl = photoUrl.trim();

    return Container(
      width: 42,
      height: 42,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFE2E8F0)),
      clipBehavior: Clip.antiAlias,
      child: cleanUrl.isEmpty
          ? const Icon(Icons.person_rounded, color: Color(0xFF64748B))
          : Image.network(
              cleanUrl,
              fit: BoxFit.cover,
              key: ValueKey(cleanUrl),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;

                return const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)));
              },
              errorBuilder: (context, error, stackTrace) {
                debugPrint('ERRO AO CARREGAR FOTO DO CLIENTE: $error');
                debugPrint('PHOTO URL: $cleanUrl');

                return const Icon(Icons.person_rounded, color: Color(0xFF64748B));
              },
            ),
    );
  }
}
