import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String format(double amount) => _formatter.format(amount);

  static String formatCompact(double amount) {
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(amount % 1000000 == 0 ? 0 : 1)}jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)}rb';
    }
    return format(amount);
  }
}

class DateFormatter {
  static DateFormat get _dateFormat => DateFormat('d MMMM yyyy', 'id_ID');
  static DateFormat get _shortFormat => DateFormat('d MMM yyyy', 'id_ID');

  static String format(DateTime date) => _dateFormat.format(date);
  static String formatShort(DateTime date) => _shortFormat.format(date);
}
