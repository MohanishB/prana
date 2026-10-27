import 'package:intl/intl.dart';

import 'json_readers.dart';

/// A price from the server: amount + currency (INR for India, USD otherwise).
class Money {
  const Money({
    required this.amount,
    required this.currencyCode,
    required this.symbol,
  });

  final double amount;
  final String currencyCode;
  final String symbol;

  bool get isFree => amount <= 0;

  String get formatted {
    final format = NumberFormat.decimalPattern(
      currencyCode == 'INR' ? 'en_IN' : 'en_US',
    );
    final hasFraction = amount != amount.roundToDouble();
    format.minimumFractionDigits = hasFraction ? 2 : 0;
    format.maximumFractionDigits = 2;
    return '$symbol${format.format(amount)}';
  }

  factory Money.fromJson(Object? value) {
    final json = jsonMap(value);
    return Money(
      amount: jsonDouble(json['amount']),
      currencyCode: jsonString(json['currency_code']),
      symbol: jsonString(json['currency_symbol']),
    );
  }
}
