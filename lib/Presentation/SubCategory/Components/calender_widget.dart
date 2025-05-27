import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';

class CalenderWidget extends StatefulWidget {
  DateTime? focusedDay;
  DateTime? selectedDay;

  CalenderWidget({super.key, this.focusedDay, this.selectedDay});

  @override
  State<CalenderWidget> createState() => _CalenderWidgetState();
}

class _CalenderWidgetState extends State<CalenderWidget> {
  CalendarFormat _calendarFormat = CalendarFormat.month;

  DateTime? _selectedDay;

  @override
  void initState() {
    // TODO: implement initState
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);

    setState(() {
      _selectedDay = appProvider.appoitmentInfo["date"] != null
          ? DateTime.tryParse(
              appProvider.appoitmentInfo["date"].toString().substring(0, 10))
          : DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    return TableCalendar(
      daysOfWeekHeight: AppSize(context).height * 0.03,
      calendarStyle: CalendarStyle(
        rangeHighlightColor: AppColors.redColor,
        todayDecoration: BoxDecoration(
          color: AppColors(context).primaryColor,
          shape: BoxShape.rectangle,
        ),
      ),
      firstDay: DateTime.now(),
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
        formatButtonTextStyle:
            TextStyle(fontSize: 14.0, color: AppColors(context).primaryColor),
      ),
      lastDay: DateTime.now().add(const Duration(days: 90)),
      focusedDay: widget.focusedDay ?? DateTime.now(),
      currentDay: _selectedDay,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      weekNumbersVisible: false,
      calendarFormat: _calendarFormat,
      onFormatChanged: (format) {
        setState(() {});
      },
      onDaySelected: (selectedDay, focusedDay) async {
        setState(() {
          widget.focusedDay = focusedDay;
          _selectedDay = selectedDay;

          appProvider.createSelectedDate(_selectedDay ?? DateTime.now());
        });

        log(_selectedDay.toString());
        log(widget.focusedDay.toString());
      },
      onPageChanged: (focusedDay) {
        setState(() {
          widget.focusedDay = focusedDay;
        });
      },
    );
  }
}
