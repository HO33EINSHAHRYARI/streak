import 'package:streak/core/extensions/date_extensions.dart';
import 'package:streak/core/i18n/app_dates.dart';
import 'package:streak/features/habits/data/habit.dart';

class AvoidMonth {
  const AvoidMonth({
    required this.cleanDays,
    required this.relapses,
    required this.saved,
    required this.spent,
    this.expenses = const [],
  });

  final int cleanDays;
  final int relapses;
  final double saved;
  final double spent;
  final List<(DateTime, double)> expenses;

  static DateTime firstOf(Habit habit, {bool jalali = false}) => jalali
      ? AppDates.jalaliMonthStart(habit.startedAt)
      : DateTime(habit.startedAt.year, habit.startedAt.month);

  static List<DateTime> monthsOf(Habit habit, {bool jalali = false}) {
    final today = AppClock.today();
    final last = jalali
        ? AppDates.jalaliMonthStart(today)
        : DateTime(today.year, today.month);
    return [
      for (
        var month = firstOf(habit, jalali: jalali);
        !month.isAfter(last);
        month = jalali
            ? _nextJalaliMonth(month, 1)
            : DateTime(month.year, month.month + 1)
      )
        month,
    ];
  }

  static DateTime _nextJalaliMonth(DateTime month, int by) {
    var (jy, jm) = AppDates.jalaliYearMonth(month);
    jm += by;
    if (jm > 12) {
      jm = 1;
      jy++;
    } else if (jm < 1) {
      jm = 12;
      jy--;
    }
    return jalaliToDateTime(jy, jm, 1);
  }

  factory AvoidMonth.of(Habit habit, DateTime month, {bool jalali = false}) {
    final first = jalali
        ? AppDates.jalaliMonthStart(month)
        : DateTime(month.year, month.month);
    final last = jalali
        ? first.addDays(jalaliDaysInMonth(month.shamsiYear, month.shamsiMonth) - 1)
        : DateTime(month.year, month.month + 1, 0);
    final today = AppClock.today();
    final from = first.isBefore(habit.startedAt) ? habit.startedAt : first;
    final to = last.isAfter(today) ? today : last;
    var clean = 0;
    var relapses = 0;
    var spent = 0.0;
    final expenses = <(DateTime, double)>[];
    for (var day = from; !day.isAfter(to); day = day.addDays(1)) {
      final entry = habit.completions[day.dayKey];
      if (entry == null) {
        clean++;
        continue;
      }
      relapses += entry.count.round().clamp(1, 999);
      spent += entry.spent;
      if (entry.spent > 0) expenses.insert(0, (day, entry.spent));
    }
    return AvoidMonth(
      cleanDays: clean,
      relapses: relapses,
      saved: habit.hasCost ? clean * habit.dailyCost : 0,
      spent: spent,
      expenses: expenses,
    );
  }
}
