import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/LanguageProvider/l10n_provider.dart';
import 'package:wefix/Business/orders/profile_api.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/model/holiday_model.dart';

class CalenderWidget extends StatefulWidget {
  DateTime? focusedDay;
  DateTime? selectedDay;
  final Function? onday;

  CalenderWidget({super.key, this.focusedDay, this.selectedDay, this.onday});

  @override
  State<CalenderWidget> createState() => _CalenderWidgetState();
}

class _CalenderWidgetState extends State<CalenderWidget> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime? _selectedDay;
  HolidayModel? holidayModel;

  List<DateTime> holidays = [];

  bool _isHoliday(DateTime day) {
    // Treat every Friday as a holiday + holidays from API
    return day.weekday == DateTime.friday ||
        holidays.any((holiday) =>
            holiday.year == day.year &&
            holiday.month == day.month &&
            holiday.day == day.day);
  }

  // Find next non-holiday day recursively
  DateTime findNextNonHolidayDay(DateTime day) {
    DateTime nextDay = day.add(const Duration(days: 1));
    while (_isHoliday(nextDay)) {
      nextDay = nextDay.add(const Duration(days: 1));
    }
    return nextDay;
  }

  @override
  void initState() {
    super.initState();
    // Wait for holidays to load, then update selected day accordingly
    getHoliday().then((_) {
      AppProvider appProvider =
          Provider.of<AppProvider>(context, listen: false);

      DateTime initialDay = appProvider.appoitmentInfo["date"] != null
          ? DateTime.tryParse(appProvider.appoitmentInfo["date"]
                  .toString()
                  .substring(0, 10)) ??
              DateTime.now()
          : DateTime.now();

      if (_isHoliday(initialDay)) {
        // If initial day is a holiday, pick next non-holiday day
        initialDay = findNextNonHolidayDay(initialDay);
      }

      setState(() {
        _selectedDay = initialDay;
        widget.focusedDay = initialDay;
      });

      appProvider.createSelectedDate(_selectedDay ?? DateTime.now());

      if (widget.onday != null) widget.onday!();
    });
  }

  @override
  Widget build(BuildContext context) {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    LanguageProvider languageProvider = Provider.of<LanguageProvider>(context);
    return TableCalendar(
      locale: languageProvider.lang == "ar" ? 'ar' : "en",
      daysOfWeekHeight: AppSize(context).height * 0.03,
      calendarStyle: CalendarStyle(
        rangeHighlightColor: AppColors.redColor,
        todayDecoration: BoxDecoration(
          color: AppColors(context).primaryColor,
          shape: BoxShape.rectangle,
        ),
      ),
      firstDay: DateTime.now(),
      lastDay: DateTime.now().add(const Duration(days: 1900)),
      focusedDay: widget.focusedDay ?? DateTime.now(),
      currentDay: _selectedDay,
      startingDayOfWeek: StartingDayOfWeek.saturday,
      weekNumbersVisible: false,
      calendarFormat: _calendarFormat,
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        leftChevronIcon: Icon(
          Icons.chevron_left,
          color: AppColors(context).primaryColor,
        ),
        rightChevronIcon: Icon(
          Icons.chevron_right,
          color: AppColors(context).primaryColor,
        ),
      ),
      enabledDayPredicate: (day) => !_isHoliday(day),
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      onDaySelected: (selectedDay, focusedDay) async {
        setState(() {
          widget.focusedDay = focusedDay;
          _selectedDay = selectedDay;
          appProvider.createSelectedDate(_selectedDay ?? DateTime.now());
        });
        if (widget.onday != null) await widget.onday!();

        log(_selectedDay.toString());
        log(widget.focusedDay.toString());
      },
      onPageChanged: (focusedDay) {
        setState(() {
          widget.focusedDay = focusedDay;
        });
      },
      calendarBuilders: CalendarBuilders(
        disabledBuilder: (context, day, focusedDay) {
          final isFriday = day.weekday == DateTime.friday;
          final isApiHoliday = holidays.any((holiday) =>
              holiday.year == day.year &&
              holiday.month == day.month &&
              holiday.day == day.day);

          if (isFriday) {
            return Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  margin: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.15),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.red),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${day.day}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Positioned(
                  top: 2,
                  right: 2,
                  child: Text("📛"),
                ),
              ],
            );
          }

          return Center(
            child: Text(
              '${day.day}',
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> getHoliday() async {
    AppProvider appProvider = Provider.of(context, listen: false);

    final result = await ProfileApis.getHoliday(
      token: '${appProvider.userModel?.token}',
    );

    if (result != null && result is HolidayModel) {
      setState(() {
        holidayModel = result;

        holidays = result.holidays.map<DateTime>((holiday) {
          final parts = holiday.date.split(',').map((e) => e.trim()).toList();
          return DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
        }).toList();
      });
    }
  }
}
