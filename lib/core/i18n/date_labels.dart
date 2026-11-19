import 'package:intl/intl.dart';

class WeekdayLabels {
  const WeekdayLabels._();

  static List<String> shortMonFirst(String locale) {
    if (locale == 'fa') {
      return ['د', 'س', 'چ', 'پ', 'ج', 'ش', 'ی'];
    }
    final s = DateFormat('', _resolve(locale)).dateSymbols.SHORTWEEKDAYS;
    return [s[1], s[2], s[3], s[4], s[5], s[6], s[0]];
  }

  static List<String> shortSunFirst(String locale) {
    if (locale == 'fa') {
      return ['ی', 'د', 'س', 'چ', 'پ', 'ج', 'ش'];
    }
    return List<String>.from(DateFormat('', _resolve(locale)).dateSymbols.SHORTWEEKDAYS);
  }

  static List<String> narrowFrom(String locale, int weekStart) {
    if (locale == 'fa') {
      const faDays = ['ی', 'د', 'س', 'چ', 'پ', 'ج', 'ش'];
      return _rotate(faDays, weekStart);
    }
    final n = DateFormat('', _resolve(locale)).dateSymbols.NARROWWEEKDAYS;
    return _rotate(n, weekStart);
  }

  static List<String> shortFrom(String locale, int weekStart) {
    if (locale == 'fa') {
      const faDays = ['یک‌شنبه', 'دوشنبه', 'سه‌شنبه', 'چهارشنبه', 'پنج‌شنبه', 'جمعه', 'شنبه'];
      return _rotate(faDays, weekStart);
    }
    final s = DateFormat('', _resolve(locale)).dateSymbols.SHORTWEEKDAYS;
    return _rotate(s, weekStart);
  }

  static List<String> _rotate(List<String> sunFirst, int weekStart) =>
      List.generate(7, (i) {
        final weekday = ((weekStart - 1 + i) % 7) + 1;
        return sunFirst[weekday % 7];
      });

  static String _resolve(String locale) => locale.isEmpty ? 'fa' : locale;
}

class MonthLabels {
  const MonthLabels._();

  static List<String> short(String locale) {
    if (locale == 'fa') {
      return ['فرو', 'ارد', 'خرد', 'تیر', 'مرد', 'شهر', 'مهر', 'آبان', 'آذر', 'دی', 'بهم', 'اسف'];
    }
    return [
      for (final month
          in DateFormat('', WeekdayLabels._resolve(locale)).dateSymbols.SHORTMONTHS)
        month.replaceAll('.', ''),
    ];
  }

  static List<String> full(String locale) {
    if (locale == 'fa') {
      return ['فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور', 'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند'];
    }
    return List<String>.from(
      DateFormat('', WeekdayLabels._resolve(locale)).dateSymbols.MONTHS,
    );
  }
}
