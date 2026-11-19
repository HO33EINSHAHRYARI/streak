import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:streak/app/theme/app_tokens.dart';
import 'package:streak/core/extensions/date_extensions.dart';

Future<DateTime?> showAppDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) async {
  final locale = Localizations.localeOf(context).toString();
  if (locale.startsWith('fa')) {
    return showShamsiDatePickerDialog(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
  }
  return showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
  );
}

Future<DateTime?> showShamsiDatePickerDialog({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => _ShamsiDatePickerSheet(
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    ),
  );
}

class _ShamsiDatePickerSheet extends StatefulWidget {
  const _ShamsiDatePickerSheet({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<_ShamsiDatePickerSheet> createState() => _ShamsiDatePickerSheetState();
}

class _ShamsiDatePickerSheetState extends State<_ShamsiDatePickerSheet> {
  late int _jy;
  late int _jm;
  late int _jd;

  @override
  void initState() {
    super.initState();
    final j = widget.initialDate.jalali;
    _jy = j.$1;
    _jm = j.$2;
    _jd = j.$3;
  }

  void _prevMonth() {
    setState(() {
      if (_jm == 1) {
        _jy--;
        _jm = 12;
      } else {
        _jm--;
      }
      final maxDays = jalaliDaysInMonth(_jy, _jm);
      if (_jd > maxDays) _jd = maxDays;
    });
  }

  void _nextMonth() {
    setState(() {
      if (_jm == 12) {
        _jy++;
        _jm = 1;
      } else {
        _jm++;
      }
      final maxDays = jalaliDaysInMonth(_jy, _jm);
      if (_jd > maxDays) _jd = maxDays;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final selectedDt = jalaliToDateTime(_jy, _jm, _jd);
    final daysInMonth = jalaliDaysInMonth(_jy, _jm);
    final firstDayDt = jalaliToDateTime(_jy, _jm, 1);
    final startOffset = (firstDayDt.weekday % 7 + 1) % 7;
    final todayJ = AppClock.today().jalali;
    const weekdays = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'انتخاب تاریخ',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: context.tokens.muted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${selectedDt.shamsiWeekdayName}، $_jd ${DateOnly.jalaliMonthNames[_jm]} $_jy',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: scheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final t = AppClock.today().jalali;
                    setState(() {
                      _jy = t.$1;
                      _jm = t.$2;
                      _jd = t.$3;
                    });
                  },
                  child: const Text('امروز'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.chevronRight, size: 20),
                    onPressed: _prevMonth,
                    tooltip: 'ماه قبل',
                  ),
                  Text(
                    '${DateOnly.jalaliMonthNames[_jm]} $_jy',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.chevronLeft, size: 20),
                    onPressed: _nextMonth,
                    tooltip: 'ماه بعد',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                for (final w in weekdays)
                  Expanded(
                    child: Center(
                      child: Text(
                        w,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: context.tokens.muted,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              children: [
                for (var i = 0; i < startOffset; i++)
                  SizedBox(
                    width: (MediaQuery.of(context).size.width - 40) / 7,
                    height: 40,
                  ),
                for (var d = 1; d <= daysInMonth; d++) ...[
                  Builder(
                    builder: (ctx) {
                      final itemDt = jalaliToDateTime(_jy, _jm, d);
                      final isSelected = d == _jd;
                      final isToday = _jy == todayJ.$1 && _jm == todayJ.$2 && d == todayJ.$3;
                      final isDisabled = itemDt.isBefore(widget.firstDate.atMidnight) ||
                          itemDt.isAfter(widget.lastDate.atMidnight);

                      return SizedBox(
                        width: (MediaQuery.of(context).size.width - 40) / 7,
                        height: 40,
                        child: Center(
                          child: InkWell(
                            onTap: isDisabled
                                ? null
                                : () => setState(() => _jd = d),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? scheme.primary
                                    : (isToday
                                        ? scheme.primary.withValues(alpha: 0.12)
                                        : Colors.transparent),
                                borderRadius: BorderRadius.circular(12),
                                border: isToday && !isSelected
                                    ? Border.all(color: scheme.primary, width: 1.2)
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  '$d',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected || isToday
                                        ? FontWeight.w800
                                        : FontWeight.w500,
                                    color: isDisabled
                                        ? context.tokens.muted.withValues(alpha: 0.3)
                                        : (isSelected
                                            ? scheme.onPrimary
                                            : (isToday ? scheme.primary : scheme.onSurface)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('انصراف'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(selectedDt),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('تأیید'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
