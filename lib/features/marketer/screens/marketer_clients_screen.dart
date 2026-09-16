import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/marketer/controllers/marketer_controller.dart';
import 'package:sixam_mart/features/marketer/widgets/sar_currency_widget.dart';

class MarketerClientsScreen extends StatefulWidget {
  final bool isRoot;
  const MarketerClientsScreen({super.key, this.isRoot = false});

  @override
  State<MarketerClientsScreen> createState() => _MarketerClientsScreenState();
}

class _MarketerClientsScreenState extends State<MarketerClientsScreen> {
  static const Color _primaryGreen = Color(0xFF30913F);
  static const Color _darkText = Color(0xFF111B18);

  int _selectedFilterIndex = 0; // 0: الكل, 1: دافعون (أتموا الشراء), 2: مسجلون فقط
  List<String> get _filters => ['filter_all'.tr, 'filter_paid'.tr, 'filter_registered_only'.tr];
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocalizationController>(
      builder: (locCtrl) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: !widget.isRoot,
            leading: widget.isRoot
                ? null
                : IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      locCtrl.isLtr ? IconlyLight.arrowLeft2 : IconlyLight.arrowRight2,
                      color: _darkText,
                    ),
                  ),
            title: Text(
              'clients_and_followup'.tr,
              style: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _darkText,
          ),
        ),
      ),
      body: SafeArea(
        child: GetBuilder<MarketerController>(
          builder: (c) {
            final txns = c.transactions;

            final filtered = txns.where((item) {
              final hasPaid = item['has_paid'] == true ||
                  item['status'] == 'paid' ||
                  (item['orders_count'] != null && (item['orders_count'] as int) > 0);

              if (_selectedFilterIndex == 1 && !hasPaid) return false;
              if (_selectedFilterIndex == 2 && hasPaid) return false;

              if (_searchQuery.trim().isNotEmpty) {
                final customerName = (item['customer'] ?? '').toString().toLowerCase();
                final phone = (item['phone'] ?? '').toString().toLowerCase();
                final q = _searchQuery.trim().toLowerCase();
                if (!customerName.contains(q) && !phone.contains(q)) return false;
              }
              return true;
            }).toList();

            return Column(
              children: [
                // Top Summary Stats Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      _buildMiniStat('registered_clients'.tr, '${c.registeredCustomers}', const Color(0xFF1D4ED8), const Color(0xFFEFF6FF)),
                      const SizedBox(width: 8),
                      _buildMiniStat('paying_clients'.tr, '${c.payingCustomers}', _primaryGreen, const Color(0xFFF0FDF4)),
                      const SizedBox(width: 8),
                      _buildMiniStat('pending_orders_clients'.tr, '${c.hesitantCustomers}', const Color(0xFFD97706), const Color(0xFFFFFBEB)),
                    ],
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'search_clients_hint'.tr,
                      hintStyle: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF9CA3AF)),
                      prefixIcon: const Icon(IconlyLight.search, color: Color(0xFF9CA3AF), size: 20),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _primaryGreen, width: 1.5),
                      ),
                    ),
                  ),
                ),

                // Filters Tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: List.generate(_filters.length, (index) {
                      final isSelected = _selectedFilterIndex == index;
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedFilterIndex = index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? _primaryGreen : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _filters[index],
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? Colors.white : const Color(0xFF4B5563),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1, color: Color(0xFFF3F4F6)),

                // List of Clients
                Expanded(
                  child: RefreshIndicator(
                    color: _primaryGreen,
                    onRefresh: c.loadDashboard,
                    child: filtered.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              const SizedBox(height: 80),
                              Center(
                                child: Column(
                                  children: [
                                    const Icon(IconlyLight.profile, size: 54, color: Color(0xFFD1D5DB)),
                                    const SizedBox(height: 12),
                                    Text(
                                      'no_clients_found'.tr,
                                      style: const TextStyle(
                                        fontFamily: 'Tajawal',
                                        fontSize: 14,
                                        color: Color(0xFF6B7280),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = filtered[index];
                              return _buildClientCard(item);
                            },
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
      },
    );
  }

  Widget _buildMiniStat(String label, String value, Color textColor, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: textColor.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientCard(dynamic item) {
    final hasPaid = item['has_paid'] == true ||
        item['status'] == 'paid' ||
        (item['orders_count'] != null && (item['orders_count'] as int) > 0);
    final customerName = (item['customer'] ?? 'عميل').toString();
    final phone = (item['phone'] ?? '').toString();
    final date = (item['date'] ?? '').toString();
    final time = (item['time'] ?? '').toString();
    final ordersCount = int.tryParse('${item['orders_count'] ?? 0}') ?? 0;
    final reward = double.tryParse('${item['reward'] ?? 1.0}') ?? 1.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasPaid ? const Color(0x6030913F) : const Color(0xFFE5E7EB),
          width: hasPaid ? 1.2 : 0.8,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar with indicator
          Stack(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: hasPaid ? const Color(0xFFEBFEEB) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    hasPaid ? IconlyLight.shieldDone : IconlyLight.profile,
                    color: hasPaid ? _primaryGreen : const Color(0xFF9CA3AF),
                    size: 24,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: hasPaid ? _primaryGreen : const Color(0xFFF59E0B),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      customerName,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _darkText,
                      ),
                    ),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: hasPaid ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        hasPaid ? '${'client_purchased_and_paid'.tr} ($ordersCount)' : 'client_registered_only'.tr,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: hasPaid ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (phone.isNotEmpty) ...[
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          phone,
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                      const Text(' • ', style: TextStyle(color: Color(0xFF9CA3AF))),
                    ],
                    Text(
                      '$date $time',
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Reward
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '+${reward.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const SarCurrencyWidget(size: 11, color: _primaryGreen),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                hasPaid ? 'confirmed_commission'.tr : 'registration_commission'.tr,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 9,
                  color: hasPaid ? _primaryGreen : const Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
