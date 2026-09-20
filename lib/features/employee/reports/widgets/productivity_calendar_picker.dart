import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ProductivityCalendarPicker extends StatefulWidget {
  final DateTime initialDate;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final Function(DateTime date) onSingleDateSelected;
  final Function(DateTime start, DateTime end) onRangeSelected;
  final VoidCallback onClose;

  const ProductivityCalendarPicker({
    super.key,
    required this.initialDate,
    this.rangeStart,
    this.rangeEnd,
    required this.onSingleDateSelected,
    required this.onRangeSelected,
    required this.onClose,
  });

  @override
  State<ProductivityCalendarPicker> createState() => _ProductivityCalendarPickerState();
}

class _ProductivityCalendarPickerState extends State<ProductivityCalendarPicker> {
  late DateTime _displayedMonth;
  DateTime? _selectedStart;
  DateTime? _selectedEnd;
  bool _isRangeMode = false;

  @override
  void initState() {
    super.initState();
    _displayedMonth = DateTime(widget.initialDate.year, widget.initialDate.month, 1);
    _selectedStart = widget.rangeStart ?? widget.initialDate;
    _selectedEnd = widget.rangeEnd;
    _isRangeMode = (_selectedEnd != null && !_isSameDay(_selectedStart!, _selectedEnd!));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isInRange(DateTime day) {
    if (_selectedStart == null || _selectedEnd == null) return false;
    final start = _selectedStart!.isBefore(_selectedEnd!) ? _selectedStart! : _selectedEnd!;
    final end = _selectedStart!.isBefore(_selectedEnd!) ? _selectedEnd! : _selectedStart!;
    return day.isAfter(start) && day.isBefore(end);
  }

  void _onDayTapped(DateTime day) {
    setState(() {
      if (!_isRangeMode) {
        // Toggle into range or pick single
        _selectedStart = day;
        _selectedEnd = null;
      } else {
        if (_selectedStart == null) {
          _selectedStart = day;
        } else if (_selectedEnd == null) {
          if (day.isBefore(_selectedStart!)) {
            _selectedEnd = _selectedStart;
            _selectedStart = day;
          } else {
            _selectedEnd = day;
          }
        } else {
          _selectedStart = day;
          _selectedEnd = null;
        }
      }
    });
  }

  void _applySelection() {
    if (_isRangeMode && _selectedStart != null && _selectedEnd != null) {
      widget.onRangeSelected(_selectedStart!, _selectedEnd!);
    } else if (_selectedStart != null) {
      widget.onSingleDateSelected(_selectedStart!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(_displayedMonth.year, _displayedMonth.month);
    final firstDayOffset = DateTime(_displayedMonth.year, _displayedMonth.month, 1).weekday % 7;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Month Header & Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Color(0xFF111B18)),
                onPressed: () {
                  setState(() {
                    _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1, 1);
                  });
                },
              ),
              Column(
                children: [
                  Text(
                    '${_displayedMonth.year}',
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111B18),
                    ),
                  ),
                  Text(
                    DateFormat('MMMM', 'en_US').format(_displayedMonth),
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Color(0xFF111B18)),
                onPressed: () {
                  setState(() {
                    _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 1);
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Mode Switch Tabs (يوم محدد vs نطاق أسبوعي)
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _isRangeMode = false;
                        _selectedEnd = null;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: !_isRangeMode ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: !_isRangeMode
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                )
                              ]
                            : null,
                      ),
                      child: Text(
                        'single_day_tab'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 13,
                          fontWeight: !_isRangeMode ? FontWeight.bold : FontWeight.w500,
                          color: !_isRangeMode ? const Color(0xFF30913F) : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _isRangeMode = true;
                        _selectedStart = DateTime(2026, 9, 13);
                        _selectedEnd = DateTime(2026, 9, 20);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: _isRangeMode ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: _isRangeMode
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                )
                              ]
                            : null,
                      ),
                      child: Text(
                        'period_range_tab'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 13,
                          fontWeight: _isRangeMode ? FontWeight.bold : FontWeight.w500,
                          color: _isRangeMode ? const Color(0xFF30913F) : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Day Names Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _DayHeader('ح'),
              _DayHeader('ن'),
              _DayHeader('ث'),
              _DayHeader('ر'),
              _DayHeader('خ'),
              _DayHeader('ج'),
              _DayHeader('س'),
            ],
          ),

          const SizedBox(height: 8),

          // Days Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 42,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (context, index) {
              final dayNumber = index - firstDayOffset + 1;
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox.shrink();
              }

              final date = DateTime(_displayedMonth.year, _displayedMonth.month, dayNumber);
              final isStart = _selectedStart != null && _isSameDay(date, _selectedStart!);
              final isEnd = _selectedEnd != null && _isSameDay(date, _selectedEnd!);
              final inRange = _isInRange(date);

              Color? bg;
              Color textColor = const Color(0xFF111B18);

              if (isStart || isEnd) {
                bg = const Color(0xFF30913F);
                textColor = Colors.white;
              } else if (inRange) {
                bg = const Color(0xFFE8F5E9);
                textColor = const Color(0xFF1B5E20);
              }

              return InkWell(
                onTap: () => _onDayTapped(date),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$dayNumber',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      fontWeight: (isStart || isEnd) ? FontWeight.bold : FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // Bottom Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onClose,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6B7280),
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text('cancel_action'.tr, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applySelection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF30913F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                  ),
                  child: Text('apply_action'.tr, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  final String text;
  const _DayHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Tajawal',
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF9CA3AF),
        ),
      ),
    );
  }
}
