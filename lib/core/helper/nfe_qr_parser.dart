class NfeQrData {
  final String raw;
  final String nfCode;
  final String cnpj;
  final double? amount;
  final DateTime? date;

  const NfeQrData({required this.raw, required this.nfCode, required this.cnpj, this.amount, this.date});
}

class NfeQrParser {
  const NfeQrParser._();

  static NfeQrData parse(String raw) {
    final cleanRaw = raw.trim();

    if (cleanRaw.isEmpty) {
      throw Exception('QR Code vazio.');
    }

    final uri = Uri.tryParse(cleanRaw);
    final params = uri?.queryParameters ?? <String, String>{};

    final p = params['p'];
    final pParts = p == null ? <String>[] : p.split('|');

    final nfCode = _findNfCode(raw: cleanRaw, params: params, pParts: pParts);

    if (nfCode.length != 44) {
      throw Exception('Não foi possível identificar a chave da NF-e.');
    }

    final cnpj = nfCode.substring(6, 20);

    final amount = _parseAmount(params['vNF'] ?? params['valor'] ?? params['vCFe'] ?? params['vNFe'] ?? _partOrNull(pParts, 5));

    final date = _parseDate(params['dhEmi'] ?? params['dEmi'] ?? params['data'] ?? params['dtEmi'] ?? _partOrNull(pParts, 4));

    return NfeQrData(raw: cleanRaw, nfCode: nfCode, cnpj: cnpj, amount: amount, date: date);
  }

  static String _findNfCode({required String raw, required Map<String, String> params, required List<String> pParts}) {
    final candidates = <String?>[params['chNFe'], params['chave'], params['chaveAcesso'], params['chCTe'], params['chCFe'], _partOrNull(pParts, 0)];

    for (final candidate in candidates) {
      final code = _onlyDigits(candidate ?? '');
      if (code.length == 44) return code;
    }

    final match = RegExp(r'\d{44}').firstMatch(raw);
    return match?.group(0) ?? '';
  }

  static String? _partOrNull(List<String> parts, int index) {
    if (index < 0 || index >= parts.length) return null;
    final value = parts[index].trim();
    return value.isEmpty ? null : value;
  }

  static String _onlyDigits(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }

  static double? _parseAmount(String? value) {
    if (value == null) return null;

    final clean = value.replaceAll('R\$', '').replaceAll(' ', '').replaceAll(',', '.').trim();

    if (clean.isEmpty) return null;

    return double.tryParse(clean);
  }

  static DateTime? _parseDate(String? value) {
    if (value == null) return null;

    final clean = value.trim();
    if (clean.isEmpty) return null;

    final iso = DateTime.tryParse(clean);
    if (iso != null) return iso;

    final digits = clean.replaceAll(RegExp(r'\D'), '');

    if (digits.length >= 14) {
      final year = int.tryParse(digits.substring(0, 4));
      final month = int.tryParse(digits.substring(4, 6));
      final day = int.tryParse(digits.substring(6, 8));
      final hour = int.tryParse(digits.substring(8, 10));
      final minute = int.tryParse(digits.substring(10, 12));
      final second = int.tryParse(digits.substring(12, 14));

      if (year != null && month != null && day != null && hour != null && minute != null && second != null) {
        return DateTime(year, month, day, hour, minute, second);
      }
    }

    if (digits.length >= 8) {
      final year = int.tryParse(digits.substring(0, 4));
      final month = int.tryParse(digits.substring(4, 6));
      final day = int.tryParse(digits.substring(6, 8));

      if (year != null && month != null && day != null) {
        return DateTime(year, month, day);
      }
    }

    return null;
  }
}
