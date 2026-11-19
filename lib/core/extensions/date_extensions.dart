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

DateTime jalaliToDateTime(int jy, int jm, int jd) {
  const gDaysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  const jDaysInMonth = [31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 29];
  final jYear = jy - 979;
  final jMonth = jm - 1;
  final jDay = jd - 1;
  var jDayNo = 365 * jYear + (jYear ~/ 33) * 8 + ((jYear % 33 + 3) ~/ 4);
  for (var i = 0; i < jMonth; i++) {
    jDayNo += jDaysInMonth[i];
  }
  jDayNo += jDay;

  var gDayNo = jDayNo + 79;
  var gy = 1600 + 400 * (gDayNo ~/ 146097);
  gDayNo %= 146097;
  var leap = true;
  if (gDayNo >= 36525) {
    gDayNo -= 1;
    gy += 100 * (gDayNo ~/ 36524);
    gDayNo %= 36524;
    if (gDayNo >= 365) {
      gDayNo += 1;
    } else {
      leap = false;
    }
  }
  gy += 4 * (gDayNo ~/ 1461);
  gDayNo %= 1461;
  if (gDayNo >= 366) {
    leap = false;
    gDayNo -= 1;
    gy += gDayNo ~/ 365;
    gDayNo %= 365;
  }

  for (var i = 0; i < 12; i++) {
    final dim = gDaysInMonth[i] + (i == 1 && leap ? 1 : 0);
    if (gDayNo < dim) {
      return DateTime(gy, i + 1, gDayNo + 1);
    }
    gDayNo -= dim;
  }
  return DateTime(gy, 12, gDayNo + 1);
}

int jalaliDaysInMonth(int jy, int jm) {
  if (jm <= 6) return 31;
  if (jm <= 11) return 30;
  final d1 = jalaliToDateTime(jy, 1, 1);
  final d2 = jalaliToDateTime(jy + 1, 1, 1);
  return d2.difference(d1).inDays == 366 ? 30 : 29;
}

extension DateOnly on DateTime {
  (int, int, int) get jalali {
    const gDaysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    const jDaysInMonth = [31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 29];
    final gy = year - 1600;
    final gm = month - 1;
    final gd = day - 1;
    var gDayNo = 365 * gy + ((gy + 3) ~/ 4) - ((gy + 99) ~/ 100) + ((gy + 399) ~/ 400);
    for (var i = 0; i < gm; i++) {
      gDayNo += gDaysInMonth[i];
    }
    if (gm > 1 && ((gy % 4 == 0 && gy % 100 != 0) || (gy % 400 == 0))) {
      gDayNo += 1;
    }
    gDayNo += gd;

    var jDayNo = gDayNo - 79;
    final jNp = jDayNo ~/ 12053;
    jDayNo %= 12053;
    var jy = 979 + 33 * jNp + 4 * (jDayNo ~/ 1461);
    jDayNo %= 1461;
    if (jDayNo >= 366) {
      jy += (jDayNo - 1) ~/ 365;
      jDayNo = (jDayNo - 1) % 365;
    }

    for (var i = 0; i < 11; i++) {
      if (jDayNo < jDaysInMonth[i]) {
        return (jy, i + 1, jDayNo + 1);
      }
      jDayNo -= jDaysInMonth[i];
    }
    return (jy, 12, jDayNo + 1);
  }

  static const jalaliWeekdayNames = [
    '',
    'دوشنبه',
    'سه‌شنبه',
    'چهارشنبه',
    'پنج‌شنبه',
    'جمعه',
    'شنبه',
    'یکشنبه',
  ];

  String get shamsiWeekdayName => jalaliWeekdayNames[weekday];
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

  String get shamsiMonthName => DateOnly.jalaliMonthNames[shamsiMonth];
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
