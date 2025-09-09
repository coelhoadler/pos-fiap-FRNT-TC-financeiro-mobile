import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

class FormatValorUtil {
  static String formatValor(dynamic v) {
    if (v == null) return 'R\$ 0,00';
    if (v is num) {
      return toCurrencyString(
        v.toString(),
        mantissaLength: 2,
        leadingSymbol: 'R\$ ',
        useSymbolPadding: true,
        thousandSeparator: ThousandSeparator.Period,
        shorteningPolicy: ShorteningPolicy.NoShortening,
      );
    }
    if (v is String) {
      final cleaned = v.replaceAll(RegExp(r'[^0-9,.\-]'), '');
      final normalized = cleaned.contains(',')
          ? cleaned.replaceAll('.', '').replaceAll(',', '.')
          : cleaned;
      final parsed = double.tryParse(normalized) ?? 0.0;

      return toCurrencyString(
        parsed.toString(),
        mantissaLength: 2,
        leadingSymbol: 'R\$ ',
        useSymbolPadding: true,
        thousandSeparator: ThousandSeparator.Period,
        shorteningPolicy: ShorteningPolicy.NoShortening,
      );
    }
    return 'R\$ 0,00';
  }
}
