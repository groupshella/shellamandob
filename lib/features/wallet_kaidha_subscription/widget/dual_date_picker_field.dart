import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:sixam_mart/util/styles.dart';

/// Interactive dual date picker field supporting both Hijri and Gregorian dates
/// with real-time automatic conversion between both calendars.
class DualDatePickerField extends StatelessWidget {
  final String label;
  final String? isoDateValue; // YYYY-MM-DD (Gregorian)
  final Function(String isoDate) onDateSelected;
  final bool hasError;
  final String? errorMessage;
  final GlobalKey? scrollKey;
  final FocusNode? focusNode;
  final bool isBirthDate; // true for birth date (past only), false for expiry (future dates allowed)

  const DualDatePickerField({
    super.key,
    required this.label,
    required this.isoDateValue,
    required this.onDateSelected,
    this.hasError = false,
    this.errorMessage,
    this.scrollKey,
    this.focusNode,
    this.isBirthDate = true,
  });

  static const Color _ink = Color(0xFF111B18);
  static const Color _green = Color(0xFF30913F);
  static const Color _bg = Color(0xFFF6F5F8);
  static const Color _border = Color(0xFFE5E7EB);
  static const Color _error = Color(0xFFEF4444);

  /// Converts ISO string ("YYYY-MM-DD") to formatted Hijri ("YYYY/MM/DD")
  static String gregorianToHijriDisplay(String isoDate) {
    if (isoDate.trim().isEmpty) return '';
    try {
      final parts = isoDate.split('-');
      if (parts.length != 3) return '';
      final y = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final d = int.parse(parts[2]);
      final hijri = HijriCalendar.fromDate(DateTime(y, m, d));
      final hy = hijri.hYear.toString().padLeft(4, '0');
      final hm = hijri.hMonth.toString().padLeft(2, '0');
      final hd = hijri.hDay.toString().padLeft(2, '0');
      return '$hy/$hm/$hd';
    } catch (_) {
      return '';
    }
  }

  /// Converts Hijri numbers to Gregorian ISO date ("YYYY-MM-DD")
  static String hijriToGregorianIso(int hYear, int hMonth, int hDay) {
    try {
      final h = HijriCalendar();
      final DateTime gDate = h.hijriToGregorian(hYear, hMonth, hDay);
      final gy = gDate.year.toString().padLeft(4, '0');
      final gm = gDate.month.toString().padLeft(2, '0');
      final gd = gDate.day.toString().padLeft(2, '0');
      return '$gy-$gm-$gd';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasValue = isoDateValue != null && isoDateValue!.trim().isNotEmpty;
    final String gregText = hasValue ? isoDateValue!.trim() : 'yyyy / mm / dd';
    final String hijriText = hasValue ? gregorianToHijriDisplay(isoDateValue!.trim()) : 'yyyy / mm / dd';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with required red mark
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '*',
              style: robotoBold.copyWith(color: _error, fontSize: 14),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: robotoMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _ink,
                fontFamily: 'Tajawal',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Split Row for Hijri & Gregorian Selector
        Focus(
          focusNode: focusNode,
          child: GestureDetector(
            key: scrollKey,
            onTap: () => _showPickerSheet(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasError ? _error : _border,
                  width: hasError ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month_outlined,
                    size: 20,
                    color: Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 12),

                  // Gregorian Segment
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: _green.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'ميلادي',
                                style: robotoBold.copyWith(
                                  fontSize: 10,
                                  color: _green,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                gregText,
                                style: robotoMedium.copyWith(
                                  fontSize: 13,
                                  color: hasValue ? _ink : const Color(0xFF9CA3AF),
                                  fontFamily: 'Tajawal',
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 28,
                    color: const Color(0xFFD1D5DB),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),

                  // Hijri Segment
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'هجري',
                                style: robotoBold.copyWith(
                                  fontSize: 10,
                                  color: const Color(0xFFD97706),
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                hijriText,
                                style: robotoMedium.copyWith(
                                  fontSize: 13,
                                  color: hasValue ? _ink : const Color(0xFF9CA3AF),
                                  fontFamily: 'Tajawal',
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons.arrow_drop_down_rounded,
                    color: Color(0xFF6B7280),
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Error message
        if (hasError && (errorMessage?.isNotEmpty ?? false)) ...[
          const SizedBox(height: 4),
          Text(
            errorMessage!,
            style: robotoRegular.copyWith(
              color: _error,
              fontSize: 11,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ],
    );
  }

  void _showPickerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _DualDatePickerBottomSheet(
        title: label,
        initialIsoDate: isoDateValue,
        isBirthDate: isBirthDate,
        onConfirmed: onDateSelected,
      ),
    );
  }
}

class _DualDatePickerBottomSheet extends StatefulWidget {
  final String title;
  final String? initialIsoDate;
  final bool isBirthDate;
  final Function(String isoDate) onConfirmed;

  const _DualDatePickerBottomSheet({
    required this.title,
    required this.initialIsoDate,
    required this.isBirthDate,
    required this.onConfirmed,
  });

  @override
  State<_DualDatePickerBottomSheet> createState() => _DualDatePickerBottomSheetState();
}

class _DualDatePickerBottomSheetState extends State<_DualDatePickerBottomSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateTime _selectedGregorian;
  late HijriCalendar _selectedHijri;

  static const Color _green = Color(0xFF30913F);
  static const Color _ink = Color(0xFF111B18);

  final List<String> _hijriMonthNamesAr = [
    'محرم',
    'صفر',
    'ربيع الأول',
    'ربيع الآخر',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    DateTime initialDate = DateTime.now();
    if (widget.isBirthDate) {
      initialDate = DateTime(2000, 1, 1);
    }

    if (widget.initialIsoDate != null && widget.initialIsoDate!.trim().isNotEmpty) {
      try {
        final parts = widget.initialIsoDate!.trim().split('-');
        if (parts.length == 3) {
          initialDate = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        }
      } catch (_) {}
    }

    _selectedGregorian = initialDate;
    _selectedHijri = HijriCalendar.fromDate(_selectedGregorian);
  }

  void _onGregorianChanged(DateTime date) {
    setState(() {
      _selectedGregorian = date;
      _selectedHijri = HijriCalendar.fromDate(date);
    });
  }

  void _onHijriChanged(int year, int month, int day) {
    setState(() {
      _selectedHijri.hYear = year;
      _selectedHijri.hMonth = month;
      _selectedHijri.hDay = day;
      _selectedGregorian = _selectedHijri.hijriToGregorian(year, month, day);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String gFormatted =
        "${_selectedGregorian.year}-${_selectedGregorian.month.toString().padLeft(2, '0')}-${_selectedGregorian.day.toString().padLeft(2, '0')}";
    final String hFormatted =
        "${_selectedHijri.hYear}/${_selectedHijri.hMonth.toString().padLeft(2, '0')}/${_selectedHijri.hDay.toString().padLeft(2, '0')}";

    final firstDate = widget.isBirthDate ? DateTime(1920) : DateTime.now();
    final lastDate = widget.isBirthDate ? DateTime.now() : DateTime(DateTime.now().year + 30);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: robotoBold.copyWith(
                    fontSize: 16,
                    color: _ink,
                    fontFamily: 'Tajawal',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF6B7280)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Tabs for Calendar Switch
            Container(
              height: 42,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: _green,
                unselectedLabelColor: const Color(0xFF6B7280),
                labelStyle: robotoBold.copyWith(fontSize: 13, fontFamily: 'Tajawal'),
                unselectedLabelStyle: robotoMedium.copyWith(fontSize: 13, fontFamily: 'Tajawal'),
                tabs: const [
                  Tab(text: 'التقويم الميلادي (Gregorian)'),
                  Tab(text: 'التقويم الهجري (Hijri)'),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Real-time Selected Summary Preview Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      const Text(
                        'ميلادي: ',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _green, fontFamily: 'Tajawal'),
                      ),
                      Text(
                        gFormatted,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _ink, fontFamily: 'Tajawal'),
                      ),
                    ],
                  ),
                  Container(width: 1, height: 18, color: const Color(0xFFD1D5DB)),
                  Row(
                    children: [
                      const Text(
                        'هجري: ',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFD97706), fontFamily: 'Tajawal'),
                      ),
                      Text(
                        hFormatted,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _ink, fontFamily: 'Tajawal'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Tab View Pickers
            SizedBox(
              height: 280,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 1. Gregorian Calendar Picker
                  CalendarDatePicker(
                    initialDate: _selectedGregorian.isAfter(lastDate)
                        ? lastDate
                        : (_selectedGregorian.isBefore(firstDate) ? firstDate : _selectedGregorian),
                    firstDate: firstDate,
                    lastDate: lastDate,
                    onDateChanged: _onGregorianChanged,
                  ),

                  // 2. Hijri Wheel / Select Picker
                  _buildHijriPicker(),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  widget.onConfirmed(gFormatted);
                  Navigator.pop(context);
                },
                child: Text(
                  'تأكيد التاريخ',
                  style: robotoBold.copyWith(
                    fontSize: 15,
                    color: Colors.white,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHijriPicker() {
    final int minYear = widget.isBirthDate ? 1340 : HijriCalendar.now().hYear;
    final int maxYear = widget.isBirthDate ? HijriCalendar.now().hYear : HijriCalendar.now().hYear + 30;

    final years = List.generate(maxYear - minYear + 1, (i) => maxYear - i);
    final days = List.generate(30, (i) => i + 1);

    int currentHYear = _selectedHijri.hYear;
    if (currentHYear < minYear) currentHYear = minYear;
    if (currentHYear > maxYear) currentHYear = maxYear;

    int currentHMonth = _selectedHijri.hMonth;
    if (currentHMonth < 1) currentHMonth = 1;
    if (currentHMonth > 12) currentHMonth = 12;

    int currentHDay = _selectedHijri.hDay;
    if (currentHDay < 1) currentHDay = 1;
    if (currentHDay > 30) currentHDay = 30;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Column(
        children: [
          Row(
            children: [
              // Day Dropdown
              Expanded(
                flex: 2,
                child: _buildDropdownItem<int>(
                  label: 'اليوم',
                  value: currentHDay,
                  items: days,
                  itemLabel: (d) => '$d',
                  onChanged: (val) {
                    if (val != null) _onHijriChanged(currentHYear, currentHMonth, val);
                  },
                ),
              ),
              const SizedBox(width: 8),

              // Month Dropdown
              Expanded(
                flex: 4,
                child: _buildDropdownItem<int>(
                  label: 'الشهر',
                  value: currentHMonth,
                  items: List.generate(12, (i) => i + 1),
                  itemLabel: (m) => '$m - ${_hijriMonthNamesAr[m - 1]}',
                  onChanged: (val) {
                    if (val != null) _onHijriChanged(currentHYear, val, currentHDay);
                  },
                ),
              ),
              const SizedBox(width: 8),

              // Year Dropdown
              Expanded(
                flex: 3,
                child: _buildDropdownItem<int>(
                  label: 'السنة',
                  value: currentHYear,
                  items: years,
                  itemLabel: (y) => '$y هـ',
                  onChanged: (val) {
                    if (val != null) _onHijriChanged(val, currentHMonth, currentHDay);
                  },
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFFD97706)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'يتم تحويل التاريخ الهجري إلى التاريخ الميلادي المقابل له تلقائياً وبدقة.',
                    style: robotoMedium.copyWith(
                      fontSize: 12,
                      color: const Color(0xFF92400E),
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownItem<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: robotoMedium.copyWith(
            fontSize: 12,
            color: const Color(0xFF4B5563),
            fontFamily: 'Tajawal',
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFD1D5DB)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF6B7280)),
              items: items.map((item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    itemLabel(item),
                    style: robotoMedium.copyWith(
                      fontSize: 12,
                      color: _ink,
                      fontFamily: 'Tajawal',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
