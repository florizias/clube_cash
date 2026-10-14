class RewardsConfig {
  const RewardsConfig._();

  /// Define quantos pontos equivalem a R$ 1,00 de cashback.
  ///
  /// Exemplo:
  /// 100 pontos = R$ 1,00
  static const int pointsPerCashbackReal = 100;

  /// Converte valor em reais para pontos.
  static int cashbackValueToPoints(double cashbackValue) {
    return (cashbackValue * pointsPerCashbackReal).round();
  }

  /// Converte pontos para valor em reais.
  static double pointsToCashbackValue(int points) {
    return points / pointsPerCashbackReal;
  }
}
