import 'package:intl/intl.dart';

abstract class AppFormatters {
  /// Formata número como Peças de Ouro (PO) do RPG.
  static String gold(num? value) {
    if (value == null) return '0 PO';
    final formatter = NumberFormat('#,##0.00', 'pt_BR');
    return '${formatter.format(value)} PO';
  }

  /// Formata data/hora em padrão brasileiro (dd/MM/yyyy HH:mm).
  static String dateTime(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd/MM/yyyy HH:mm', 'pt_BR').format(date);
  }

  /// Formata data em padrão brasileiro (dd/MM/yyyy).
  static String dateOnly(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd/MM/yyyy', 'pt_BR').format(date);
  }
}
