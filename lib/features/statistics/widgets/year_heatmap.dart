import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:streak/app/theme/app_tokens.dart';
import 'package:streak/core/extensions/date_extensions.dart';
import 'package:streak/core/i18n/app_dates.dart';
import 'package:streak/features/habits/data/habit.dart';
import 'package:provider/provider.dart';
import 'package:streak/features/habits/widgets/habit_heatmap.dart';
import 'package:streak/features/settings/state/settings_controller.dart';

const _gap = 3.0;

class YearHeatmap extends StatefulWidget {
  const YearHeatmap({
    super.key,
    required this.year,
    required this.color,
    this.dailyCounts = const {},
    this.maxCount = 1,
    this.habit,
    this.express = false,
  });

  final int year;
  final Map<String, int> dailyCounts;
  final int maxCount;
  final Color color;
  final Habit? habit;
  final bool express;

  @override
  State<YearHeatmap> createState() => _YearHeatmapState();
}

class _YearHeatmapState extends State<YearHeatmap> {
  final _scroll = ScrollController();

  double get _cell => widget.express ? 15 : 12;

  double get _step => _cell + _gap;

  // The `year` param stays Gregorian (app-wide convention); in fa it maps to
  // a Jalali year and the whole grid spans that Jalali year instead.
  bool _fa(BuildContext context) =>
      AppDates.isFa(Localizations.localeOf(context).toString());

  int _jalaliYear(BuildContext context) => _fa(context)
      ? AppClock.now().shamsiYear + (widget.year - AppClock.now().year)
      : widget.year;

  bool _isDisplayedYear(DateTime date, BuildContext context) => _fa(context)
      ? date.shamsiYear == _jalaliYear(context)
      : date.year == widget.year;

  bool _rollingFor(bool on, BuildContext context) =>
      on && widget.year == AppClock.now().year;

  bool _wholeHistory(BuildContext context) =>
      widget.habit != null && widget.year == AppClock.now().year;

  DateTime _startFrom(bool rolling, int weekStart, BuildContext context) {
    final habit = widget.habit;
    if (rolling) {
      final recent = AppClock.today()
          .startOfWeek(weekStart)
          .addDays(-(7 * 52));
      if (!_wholeHistory(context)) return recent;
      final first = habit!.startedAt.startOfWeek(weekStart);
      final floor = recent.addDays(-7 * 467);
      if (!first.isBefore(recent)) return recent;
      return first.isBefore(floor) ? floor : first;
    }
    if (_fa(context)) {
      final jy = _jalaliYear(context);
      final firstYear = _wholeHistory(context)
          ? habit!.startedAt.shamsiYear.clamp(jy - 9, jy)
          : jy;
      return jalaliToDateTime(firstYear, 1, 1).startOfWeek(weekStart);
    }
    final firstYear = _wholeHistory(context)
        ? habit!.startedAt.year.clamp(widget.year - 9, widget.year)
        : widget.year;
    return DateTime(firstYear, 1, 1).startOfWeek(weekStart);
  }

  @override
  void initState() {
    super.initState();
    _focusToday();
  }

  @override
  void didUpdateWidget(YearHeatmap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.year != oldWidget.year) _focusToday();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _focusToday() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      final position = _scroll.position;
      final today = AppClock.today();
      final settings = context.read<SettingsController>();
      final rolling = _rollingFor(settings.heatmapRolling, context);
      final target = !_isDisplayedYear(today, context) && !rolling
          ? 0.0
          : ((today.epochDay - _startFrom(rolling, settings.weekStart, context).epochDay) ~/ 7) * _step +
                _cell / 2 -
                position.viewportDimension / 2;
      position.jumpTo(
        target.clamp(position.minScrollExtent, position.maxScrollExtent),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = AppClock.today();
    final settings = context.watch<SettingsController>();
    final rolling = _rollingFor(settings.heatmapRolling, context);
    final start = _startFrom(rolling, settings.weekStart, context);
    final jy = _jalaliYear(context);
    final lastOfYear = _fa(context)
        ? jalaliToDateTime(jy, 12, 1)
            .addDays(jalaliDaysInMonth(jy, 12) - 1)
        : DateTime(widget.year, 12, 31);
    final columns = rolling
        ? (today.startOfWeek(settings.weekStart).epochDay - start.epochDay) ~/ 7 + 1
        : (lastOfYear.epochDay - start.epochDay) ~/ 7 + 1;
    final empty = context.colors.surfaceContainerHighest;
    final max = widget.maxCount <= 0 ? 1 : widget.maxCount;
    final locale = Localizations.localeOf(context).languageCode;

    Color cellColor(DateTime date) {
      final futureYear = _fa(context)
          ? date.shamsiYear > jy
          : date.year > widget.year;
      if (!rolling && (futureYear ||
          (!_wholeHistory(context) && !_isDisplayedYear(date, context)))) {
        return Colors.transparent;
      }
      final habit = widget.habit;
      if (habit != null) return heatmapCellColor(context, habit, date);
      if (date.isAfter(today)) return empty.withValues(alpha: 0.4);
      final count = widget.dailyCounts[date.dayKey] ?? 0;
      if (count <= 0) return empty;
      final ratio = (count / max).clamp(0.25, 1.0);
      return Color.lerp(widget.color.withValues(alpha: 0.35), widget.color, ratio)!;
    }

    return LayoutBuilder(
      builder: (context, box) => SingleChildScrollView(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: box.maxWidth),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(columns, (col) {
              final colDate = start.addDays(col * 7);
              final prevDate = start.addDays((col - 1) * 7);
              final isFa = locale.startsWith('fa');
              final isNewMonth = (rolling || _wholeHistory(context) || (isFa ? colDate.shamsiYear == jy : colDate.year == widget.year)) &&
                  (col == 0 || (isFa ? colDate.shamsiMonth != prevDate.shamsiMonth : colDate.month != prevDate.month));
              return Padding(
                padding: const EdgeInsets.only(right: _gap),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 14,
                      width: _cell,
                      child: isNewMonth
                          ? OverflowBox(
                              maxWidth: 55,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                isFa
                                    ? (_wholeHistory(context) && colDate.shamsiMonth == 1
                                        ? '${colDate.shamsiMonthName} ${colDate.shamsiYear % 100}'
                                        : colDate.shamsiMonthName)
                                    : (_wholeHistory(context) && colDate.month == 1
                                        ? DateFormat('MMM yy', locale)
                                        : DateFormat.MMM(locale))
                                        .format(colDate),
                                textScaler: MediaQuery.textScalerOf(context)
                                    .clamp(maxScaleFactor: 1.2),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: context.tokens.muted,
                                ),
                              ),
                            )
                          : null,
                    ),
                    for (var row = 0; row < 7; row++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: _gap),
                        child: Container(
                          width: _cell,
                          height: _cell,
                          decoration: BoxDecoration(
                            color: cellColor(
                              start.addDays(col * 7 + row),
                            ),
                            borderRadius: BorderRadius.circular(
                              widget.express ? 4 : 3,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
