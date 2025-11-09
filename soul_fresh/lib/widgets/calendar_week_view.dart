import 'package:flutter/material.dart';
import '../models/app_models.dart';

class CalendarWeekView extends StatelessWidget {
  final List<CalendarDay> days;
  final Function(int) onDaySelected;

  const CalendarWeekView({
    required this.days,
    required this.onDaySelected,
    super.key,
  });

  String _getDayLabel(DayOfWeek day) {
    switch (day) {
      case DayOfWeek.mon:
        return 'Mon';
      case DayOfWeek.tue:
        return 'Tu';
      case DayOfWeek.wed:
        return 'Wed';
      case DayOfWeek.thu:
        return 'Thu';
      case DayOfWeek.fri:
        return 'Fri';
      case DayOfWeek.sat:
        return 'Sat';
      case DayOfWeek.sun:
        return 'Sun';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: days.map((day) {
        return GestureDetector(
          onTap: () => onDaySelected(day.date),
          child: Column(
            children: [
              Text(
                _getDayLabel(day.day),
                style: TextStyle(
                  color: day.isSelected ? Colors.black : Colors.grey,
                  fontSize: 12,
                  fontWeight:
                      day.isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: day.isSelected ? Colors.black : Colors.transparent,
                  shape: BoxShape.circle,
                  border: day.isSelected
                      ? null
                      : Border.all(color: Colors.grey.shade300),
                ),
                child: Center(
                  child: Text(
                    '${day.date}',
                    style: TextStyle(
                      color: day.isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
