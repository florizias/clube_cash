import 'package:flutter/material.dart';

class AdminHeaderAvatar extends StatelessWidget {
  final String photoUrl;

  const AdminHeaderAvatar({super.key, required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    if (photoUrl.trim().isEmpty) {
      return const CircleAvatar(
        radius: 22,
        backgroundColor: Color(0xFFE5E7EB),
        child: Icon(Icons.person, color: Color(0xFF64748B)),
      );
    }

    return ClipOval(
      child: Image.network(
        photoUrl,
        width: 44,
        height: 44,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return const CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFFE5E7EB),
            child: Icon(Icons.person, color: Color(0xFF64748B)),
          );
        },
      ),
    );
  }
}
