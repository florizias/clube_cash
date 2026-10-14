String getMarketTime(DateTime? openedAt) {
  if (openedAt == null) return 'Não informado';
  final now = DateTime.now();
  var years = now.year - openedAt.year;
  var months = now.month - openedAt.month;
  if (now.day < openedAt.day) {
    months--;
  }
  if (months < 0) {
    years--;
    months += 12;
  }
  if (years <= 0 && months <= 0) return 'Menos de 1 mês';
  if (years <= 0) {
    return months == 1 ? '1 mês' : '$months meses';
  }
  if (months <= 0) {
    return years == 1 ? '1 ano' : '$years anos';
  }
  final yearText = years == 1 ? '1 ano' : '$years anos';
  final monthText = months == 1 ? '1 mês' : '$months meses';

  return '$yearText e $monthText';
}
