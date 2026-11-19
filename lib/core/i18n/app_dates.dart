import 'package:intl/intl.dart';
import 'package:streak/core/extensions/date_extensions.dart';
import 'package:streak/core/i18n/date_labels.dart';

/// Locale-aware date display: Jalali (Shamsi) for fa, Gregorian otherwise.
///
/// Every user-visible date goes through here so the fa locale always shows
/// Jalali day/month names, and other locales keep their intl formats.
class AppDates {
  const AppDates._();

  static bool isFa(String locale) => locale.startsWith('fa');

  static String _l(String locale) => locale.isEmpty ? 'fa' : locale;

  /// 'پنج‌شنبه، ۲۸ آبان ۱۴۰۵' / 'Thursday, November 19, 2026'
  static String full(DateTime d, String locale) => isFa(locale)
      ? '${d.shamsiWeekdayName}، ${d.shamsiFormatted}'
      : DateFormat.yMMMMEEEEd(_l(locale)).format(d);

  /// 'پنج‌شنبه، ۲۸ آبان' / 'Thursday, November 19'
  static String weekdayDayMonth(DateTime d, String locale) => isFa(locale)
      ? '${d.shamsiWeekdayName}، ${d.shamsiDay} ${d.shamsiMonthName}'
      : DateFormat.MMMEd(_l(locale)).format(d);

  /// '۲۸ آبان ۱۴۰۵' / 'Nov 19, 2026'
  static String medium(DateTime d, String locale) => isFa(locale)
      ? d.shamsiFormatted
      : DateFormat.yMMMd(_l(locale)).format(d);

  /// '۲۸ آبان ۱۴۰۵' / 'November 19, 2026'
  static String long(DateTime d, String locale) => isFa(locale)
      ? d.shamsiFormatted
      : DateFormat.yMMMMd(_l(locale)).format(d);

  /// '۲۸ آبان' / 'Nov 19'
  static String dayMonth(DateTime d, String locale) => isFa(locale)
      ? d.shamsiShort
      : DateFormat.MMMd(_l(locale)).format(d);

  /// 'آبان ۱۴۰۵' / 'November 2026'
  static String monthYear(DateTime d, String locale) => isFa(locale)
      ? '${d.shamsiMonthName} ${d.shamsiYear}'
      : DateFormat.yMMMM(_l(locale)).format(d);

  /// 'آبان' / 'November'
  static String monthName(DateTime d, String locale) => isFa(locale)
      ? d.shamsiMonthName
      : DateFormat.MMMM(_l(locale)).format(d);

  /// 'نوامبر ۲۰۲۶' / 'Nov 2026'
  static String monthShortYear(DateTime d, String locale) => isFa(locale)
      ? '${d.shamsiMonthName} ${d.shamsiYear}'
      : DateFormat.yMMM(_l(locale)).format(d);

  /// 'نوامبر' / 'Nov'
  static String monthShort(DateTime d, String locale) => isFa(locale)
      ? d.shamsiMonthName
      : DateFormat.MMM(_l(locale)).format(d);

  /// 'پنج‌شنبه' / 'Thursday'
  static String weekday(DateTime d, String locale) => isFa(locale)
      ? d.shamsiWeekdayName
      : DateFormat.EEEE(_l(locale)).format(d);

  /// Jalali month names when fa, Gregorian month names otherwise.
  static List<String> monthNames(String locale) => MonthLabels.full(locale);

  /// First Gregorian day of the Jalali month containing [reference].
  static DateTime jalaliMonthStart(DateTime reference) {
    final (jy, jm, _) = reference.jalali;
    return jalaliToDateTime(jy, jm, 1);
  }

  /// Jalali (year, month) pair of [date].
  static (int, int) jalaliYearMonth(DateTime date) {
    final (jy, jm, _) = date.jalali;
    return (jy, jm);
  }

  /// Whether [date] falls in the Jalali month of [reference].
  static bool sameJalaliMonth(DateTime date, DateTime reference) {
    final (jy, jm, _) = reference.jalali;
    final (y, m, _) = date.jalali;
    return y == jy && m == jm;
  }
}
