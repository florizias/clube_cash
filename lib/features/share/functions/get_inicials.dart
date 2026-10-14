String getInitials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));

  if (parts.isEmpty || parts.first.isEmpty) return '?';

  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }

  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}
