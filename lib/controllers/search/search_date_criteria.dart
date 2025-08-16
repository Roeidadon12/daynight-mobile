import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../constants.dart';
import '../../app_localizations.dart';

class CustomDatePicker extends StatefulWidget {
  const CustomDatePicker({super.key});
  
  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOn;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppLocalizations.of(context).get('filter-by-date'),
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 12),
          TableCalendar(
            locale: Localizations.localeOf(context).toString(),
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            rangeSelectionMode: _rangeSelectionMode,
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeEnd,
            onRangeSelected: (start, end, focusedDay) {
              setState(() {
                _rangeStart = start;
                _rangeEnd = end;
                _focusedDay = focusedDay;
                _rangeSelectionMode = RangeSelectionMode.toggledOn;
              });
            },
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(color: Colors.white, fontSize: 16),
              leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
              rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              defaultTextStyle: const TextStyle(color: Colors.white),
              weekendTextStyle: const TextStyle(color: Colors.white70),
              // pill style for range
              rangeHighlightColor: Colors.white.withAlpha(32),
              withinRangeTextStyle: const TextStyle(color: Colors.white), // Add this
              rangeStartTextStyle: const TextStyle(color: Colors.white), // Add this
              rangeEndTextStyle: const TextStyle(color: Colors.white), // Add this
              withinRangeDecoration: const BoxDecoration(
                color: Colors.transparent, // middle days = pill background only
              ),
              rangeStartDecoration: const BoxDecoration(
                color: kBrandPrimary,
                shape: BoxShape.circle, // Changed from borderRadius to shape
              ),
              rangeEndDecoration: const BoxDecoration(
                color: kBrandPrimary,
                shape: BoxShape.circle, // Changed from borderRadius to shape
              ),
              todayDecoration: BoxDecoration(
                color: kBrandPrimary.withAlpha(128),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: kBrandPrimary,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    setState(() {
                      _rangeStart = null;
                      _rangeEnd = null;
                    });
                  },
                  child: Text(
                    AppLocalizations.of(context).get('clear'),
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBrandPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(context, {
                      "start": _rangeStart,
                      "end": _rangeEnd,
                    });
                  },
                  child: Text(
                    AppLocalizations.of(context).get('search'),
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<Map<String, DateTime?>?> showCustomDatePicker(BuildContext context) async {
  return await showModalBottomSheet<Map<String, DateTime?>>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => const CustomDatePicker(),
  );
}