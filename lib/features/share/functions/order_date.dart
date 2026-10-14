DateTime parseDate(String date) {
  final parts = date.split('/');
  return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
}
