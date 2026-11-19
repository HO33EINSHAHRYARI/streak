class AppClock {
  const AppClock._();

  static int _cutoffHour = 0;
  static DateTime? _today;
  static int _todayUntil = 0;

  static int get cutoffHour => _cutoffHour;

  static set cutoffHour(int value) {
    if (_cutoffHour == value) return;
    _cutoffHour = value;
    _today = null;
  }

  static DateTime now() => _cutoffHour == 0
      ? DateTime.now()
      : DateTime.now().subtract(Duration(hours: _cutoffHour));

  static DateTime wallNow() => DateTime.now();

  static DateTime today() {
    final cached = _today;
    if (cached != null &&
        DateTime.now().millisecondsSinceEpoch < _todayUntil) {
      return cached;
    }
    final midnight = now().atMidnight;
    _today = midnight;
    _todayUntil = midnight.addDays(1).millisecondsSinceEpoch +
        _cutoffHour * Duration.millisecondsPerHour;
    return midnight;
  }

  static bool isLogicalToday(DateTime date) => date.isSameDay(now());
}

extension DateOnly on DateTime {
  (int, int, int) get jalali {
    const gDaysInMonth = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334];
    final gy2 = (month > 2) ? (year - 1600) : (year - 1601);
    var days = 365 * gy2 + ((gy2 + 4) ~/ 4) - ((gy2 + 99) ~/ 100) + ((gy2 + 399) ~/ 400) - 80 + day + gDaysInMonth[month - 1];
    var jy = 979 + 33 * (days ~/ 12053);
    days %= 12053;
    jy += 4 * (days ~/ 1461);
    days %= 1461;
    if (days > 365) {
      jy += (days - 1) ~/ 365;
      days = (days - 1) % 365;
    }
    final int jm;
    final int jd;
    if (days < 186) {
      jm = 1 + (days ~/ 31);
      jd = 1 + (days % 31);
    } else {
      jm = 7 + ((days - 186) ~/ 30);
      jd = 1 + ((days - 186) % 30);
    }
    return (jy, jm, jd);
  }

  int get shamsiDay => jalali.$3;
  int get shamsiMonth => jalali.$2;
  int get shamsiYear => jalali.$1;

  static const jalaliMonthNames = [
    '',
    'فروردین', 'اردیبهشت', 'خرداد',
    'تیر', 'مرداد', 'شهریور',
    'مهر', 'آبان', 'آذر',
    'دی', 'بهمن', 'اسفند',
  ];

  String get shamsiMonthName => jalaliMonthNames[shamsiMonth];
  String get shamsiFormatted => '$shamsiDay $shamsiMonthName $shamsiYear';
  String get shamsiShort => '$shamsiDay $shamsiMonthName';

  String get dayKey => '${_pad(day)}-${_pad(month)}-$year';

  DateTime get atMidnight => DateTime(year, month, day);

  int get epochDay =>
      DateTime.utc(year, month, day).millisecondsSinceEpoch ~/
      Duration.millisecondsPerDay;

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  DateTime addDays(int count) => DateTime(year, month, day + count);

  DateTime startOfWeek(int weekStart) {
    final diff = (weekday - weekStart + 7) % 7;
    return addDays(-diff);
  }
}

DateTime parseDayKey(String value) => DateTime(
  int.parse(value.substring(6)),
  int.parse(value.substring(3, 5)),
  int.parse(value.substring(0, 2)),
);

int dayKeyEpoch(String value) {
  final day = _digits(value, 0, 2);
  final month = _digits(value, 3, 5);
  final year = _digits(value, 6, value.length);
  final y = month <= 2 ? year - 1 : year;
  final era = (y >= 0 ? y : y - 399) ~/ 400;
  final yearOfEra = y - era * 400;
  final dayOfYear = (153 * (month + (month > 2 ? -3 : 9)) + 2) ~/ 5 + day - 1;
  final dayOfEra =
      yearOfEra * 365 + yearOfEra ~/ 4 - yearOfEra ~/ 100 + dayOfYear;
  return era * 146097 + dayOfEra - 719468;
}

DateTime epochDayDate(int epochDay) {
  final utc = DateTime.utc(1970, 1, 1 + epochDay);
  return DateTime(utc.year, utc.month, utc.day);
}

int _digits(String value, int from, int to) {
  var out = 0;
  for (var i = from; i < to; i++) {
    out = out * 10 + value.codeUnitAt(i) - 48;
  }
  return out;
}

String _pad(int value) => value < 10 ? '0$value' : '$value';
