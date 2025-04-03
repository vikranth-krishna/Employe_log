import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarPopup extends StatefulWidget {
  final DateTime initialDate;
  final bool limitedQuickOptions; // true: show only "No Date" and "Today" buttons

  const CalendarPopup({
    Key? key,
    required this.initialDate,
    this.limitedQuickOptions = false,
  }) : super(key: key);

  @override
  State<CalendarPopup> createState() => _CalendarPopupState();
}

class _CalendarPopupState extends State<CalendarPopup> {
  late DateTime _selectedDate;
  late DateTime _displayedMonth;
  String? _selectedQuickOption;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _displayedMonth = DateTime(_selectedDate.year, _selectedDate.month);
    _selectedQuickOption = null;
  }

  Widget _buildQuickSelectButton(String label, String optionKey) {
    bool isSelected = (_selectedQuickOption == optionKey);
    return Container(
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFF1DA1F2) : const Color(0xFFEDF8FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          padding: EdgeInsets.zero,
        ),
        onPressed: () {
          DateTime newSelected = _selectedDate;
          if (optionKey == "today") {
            newSelected = DateTime.now();
          } else if (optionKey == "nextMonday") {
            while (newSelected.weekday != DateTime.monday) {
              newSelected = newSelected.add(const Duration(days: 1));
            }
          } else if (optionKey == "nextTuesday") {
            while (newSelected.weekday != DateTime.tuesday) {
              newSelected = newSelected.add(const Duration(days: 1));
            }
          } else if (optionKey == "after1Week") {
            newSelected = newSelected.add(const Duration(days: 7));
          }
          setState(() {
            _selectedDate = newSelected;
            _displayedMonth = DateTime(newSelected.year, newSelected.month);
            _selectedQuickOption = optionKey;
          });
        },
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: isSelected ? Colors.white : const Color(0xFF1DA1F2),
          ),
        ),
      ),
    );
  }

  Widget _buildLimitedQuickSelectRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 36,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1DA1F2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: EdgeInsets.zero,
              ),
              onPressed: () {
                Navigator.pop(context, null);
              },
              child: const Text(
                'No Date',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 36,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEDF8FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: EdgeInsets.zero,
              ),
              onPressed: () {
                DateTime newSelected = DateTime.now();
                setState(() {
                  _selectedDate = newSelected;
                  _displayedMonth = DateTime(newSelected.year, newSelected.month);
                  _selectedQuickOption = 'today';
                });
              },
              child: const Text(
                'Today',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Color(0xFF1DA1F2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCalendarGrid() {
    List<Widget> rows = [];
    DateTime firstOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    int offset = firstOfMonth.weekday - 1;
    DateTime gridStart = firstOfMonth.subtract(Duration(days: offset));
    for (int week = 0; week < 6; week++) {
      List<Widget> weekRow = [];
      for (int day = 0; day < 7; day++) {
        DateTime cellDate = gridStart.add(Duration(days: week * 7 + day));
        bool isCurrentMonth = cellDate.month == _displayedMonth.month;
        bool isSelected = (cellDate.year == _selectedDate.year &&
            cellDate.month == _selectedDate.month &&
            cellDate.day == _selectedDate.day);
        weekRow.add(
          Expanded(
            child: GestureDetector(
              onTap: isCurrentMonth
                  ? () {
                setState(() {
                  _selectedDate = cellDate;
                  _selectedQuickOption = null;
                });
              }
                  : null,
              child: Container(
                height: 32,
                alignment: Alignment.center,
                decoration: isSelected
                    ? BoxDecoration(
                  color: const Color(0xFF1DA1F2).withOpacity(0.15),
                  shape: BoxShape.circle,
                )
                    : null,
                child: isCurrentMonth
                    ? Text(
                  '${cellDate.day}',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? const Color(0xFF1DA1F2) : Colors.black,
                  ),
                )
                    : Container(),
              ),
            ),
          ),
        );
      }
      rows.add(Row(children: weekRow));
      rows.add(const SizedBox(height: 8));
    }
    return rows;
  }

  Widget _buildDayOfWeekLabel(String label) {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
      ),
    );
  }

  String _monthName(int month) {
    const List<String> months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  String _formatSelectedDate(DateTime date) {
    final DateFormat formatter = DateFormat('d MMM yyyy');
    return formatter.format(date);
  }

  Widget _buildPopupActionButton({
    required String label,
    required double width,
    required double height,
    required Color backgroundColor,
    required Color textColor,
    required double borderRadius,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: EdgeInsets.zero,
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: textColor,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String displayedMonthYear = "${_monthName(_displayedMonth.month)} ${_displayedMonth.year}";
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9 < 600
            ? MediaQuery.of(context).size.width * 0.9
            : 600,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                widget.limitedQuickOptions
                    ? _buildLimitedQuickSelectRow()
                    : Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildQuickSelectButton('Today', 'today')),
                        Expanded(child: _buildQuickSelectButton('Next Monday', 'nextMonday')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _buildQuickSelectButton('Next Tuesday', 'nextTuesday')),
                        Expanded(child: _buildQuickSelectButton('After 1 Week', 'after1Week')),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1);
                        });
                      },
                      child: Transform.rotate(
                        angle: math.pi,
                        child: const Icon(Icons.play_arrow, color: Colors.grey, size: 24),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        displayedMonthYear,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        softWrap: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1);
                        });
                      },
                      child: const Icon(Icons.play_arrow, color: Colors.grey, size: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildDayOfWeekLabel('Mon'),
                    _buildDayOfWeekLabel('Tue'),
                    _buildDayOfWeekLabel('Wed'),
                    _buildDayOfWeekLabel('Thu'),
                    _buildDayOfWeekLabel('Fri'),
                    _buildDayOfWeekLabel('Sat'),
                    _buildDayOfWeekLabel('Sun'),
                  ],
                ),
                const SizedBox(height: 8),
                ..._buildCalendarGrid(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.calendar_today, color: Color(0xFF1DA1F2)),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _formatSelectedDate(_selectedDate),
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              softWrap: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildPopupActionButton(
                          label: 'Cancel',
                          width: 73,
                          height: 40,
                          backgroundColor: const Color(0xFFEDF8FF),
                          textColor: const Color(0xFF1DA1F2),
                          borderRadius: 6,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildPopupActionButton(
                          label: 'Save',
                          width: 73,
                          height: 40,
                          backgroundColor: const Color(0xFF1DA1F2),
                          textColor: Colors.white,
                          borderRadius: 6,
                          onPressed: () {
                            Navigator.pop(context, _selectedDate);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
