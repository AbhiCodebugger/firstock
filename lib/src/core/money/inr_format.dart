/// Indian grouping (last 3 digits, then pairs): `1485200` → `14,85,200`.
String formatIndianNumber(num value, {int decimals = 2}) {
  final isNegative = value < 0;
  final absValue = value.abs();
  final fixed = absValue.toStringAsFixed(decimals);
  final parts = fixed.split('.');
  final whole = parts[0];
  final fraction = parts.length > 1 ? parts[1] : '';

  final buffer = StringBuffer();
  if (whole.length <= 3) {
    buffer.write(whole);
  } else {
    final lastThree = whole.substring(whole.length - 3);
    var rest = whole.substring(0, whole.length - 3);
    final pairs = <String>[];
    while (rest.length > 2) {
      pairs.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) {
      buffer.write(rest);
      buffer.write(',');
    }
    buffer.write(pairs.join(','));
    if (pairs.isNotEmpty) {
      buffer.write(',');
    }
    buffer.write(lastThree);
  }

  final grouped = decimals == 0
      ? buffer.toString()
      : '${buffer.toString()}.$fraction';
  return isNegative ? '-$grouped' : grouped;
}

String formatInr(num value, {int decimals = 2, bool signed = false}) {
  final absFormatted = formatIndianNumber(value.abs(), decimals: decimals);
  if (signed) {
    final sign = value > 0 ? '+' : value < 0 ? '-' : '';
    return '$sign₹$absFormatted';
  }
  if (value < 0) {
    return '-₹$absFormatted';
  }
  return '₹$absFormatted';
}

String formatPercent(num value, {int decimals = 2, bool signed = true}) {
  final body = value.abs().toStringAsFixed(decimals);
  if (!signed) {
    return '$body%';
  }
  final sign = value > 0 ? '+' : value < 0 ? '-' : '';
  return '$sign$body%';
}
