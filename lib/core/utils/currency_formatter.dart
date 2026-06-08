import 'package:intl/intl.dart';

/// Utility for formatting currency amounts in Indian Rupee (₹) format.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final _inrFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final _inrFormatterDecimal = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static String format(double amount, {bool showDecimal = false}) {
    if (showDecimal) return _inrFormatterDecimal.format(amount);
    return _inrFormatter.format(amount);
  }

  static String formatCompact(double amount) {
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(2)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount);
  }
}
