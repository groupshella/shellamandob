import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/campaign/controllers/dynamic_gift_controller.dart';
import 'package:sixam_mart/features/campaign/domain/models/dynamic_gift_campaign_model.dart';
import 'package:sixam_mart/util/images.dart';

class FigmaStoreView extends StatelessWidget {
  final DynamicGiftController controller;
  final int? storeId;

  const FigmaStoreView({
    super.key,
    required this.controller,
    this.storeId,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DynamicGiftController>(
      builder: (ctrl) {
        final campaign = ctrl.giftCampaign?.campaign;
        final store = campaign?.store;

        // Use items from campaign or fallback list matching Figma mock
        List<SelectableGiftItem> allItems = campaign?.selectableItems ?? [];
        if (allItems.isEmpty) {
          allItems = List.generate(
            2,
            (i) => SelectableGiftItem(
              campaignItemId: i + 1,
              itemId: 100 + i,
              name: i == 0 ? 'عصير مانجو بريميم طازج' : 'شوكولاتة ساخنة بالمارشميلو',
              description: i == 0 ? 'عصير مانجو طبيعي 100%' : 'شوكولاتة ساخنة فاخرة',
              originalPrice: i == 0 ? 15.0 : 17.0,
              discountPrice: 0.0,
              isFree: true,
              image: '',
            ),
          );
        }

        final selectedId = ctrl.selectedItem?.campaignItemId ?? ctrl.selectedItem?.itemId;

        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              // ─────────────────────────────────────────────────────────
              // Main Scrollable Body
              // ─────────────────────────────────────────────────────────
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ── 1. Store Cover Header + Overlapping Info Card ─────
                  SliverToBoxAdapter(
                    child: _buildHeaderAndStoreInfo(context, campaign, store),
                  ),

                  // ── 2. Category Tab & Section Title ──────────────────
                  SliverToBoxAdapter(
                    child: _buildCategoryAndHeader(),
                  ),

                  // ── 3. Products List ─────────────────────────────────
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = allItems[index];
                        final itemId = item.campaignItemId ?? item.itemId ?? index;
                        final isSelected = selectedId != null &&
                            (item.campaignItemId == selectedId || item.itemId == selectedId);

                        return _buildProductCard(
                          ctrl: ctrl,
                          item: item,
                          itemId: itemId,
                          isSelected: isSelected,
                        );
                      },
                      childCount: allItems.length,
                    ),
                  ),

                  // Bottom Spacing
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),

              // ── 4. Floating Cart Button Attached to Right Edge ───────
              _buildFloatingCart(context, ctrl),
            ],
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // 1. Cover Header + Facebook-Style Overlapping Store Info Card
  // ─────────────────────────────────────────────────────────────────
  Widget _buildHeaderAndStoreInfo(
    BuildContext context,
    CampaignDetails? campaign,
    CampaignStore? store,
  ) {
    final hasCover = store?.coverPhoto != null && store!.coverPhoto!.isNotEmpty;
    final ratingText = store?.rating != null ? store!.rating!.toStringAsFixed(1) : '5.0';

    return Column(
      children: [
        // ── A. Top Cover Header (140dp) ──
        Stack(
          children: [
            // Background: Dynamic Cover Photo OR Lush Botanical Green Gradient
            Container(
              width: double.infinity,
              height: 140,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF095A26), Color(0xFF1E823D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: hasCover
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        CustomImage(
                          image: store.coverPhoto!,
                          width: double.infinity,
                          height: 140,
                          fit: BoxFit.cover,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: 0.35),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.45),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Stack(
                      children: [
                        Positioned(
                          top: 0,
                          right: 0,
                          bottom: 0,
                          width: 190,
                          child: CustomPaint(
                            painter: _BotanicalLeavesPainter(),
                          ),
                        ),
                      ],
                    ),
            ),

            // Top Action Buttons Row (Forced LTR)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left: Heart & Search Buttons
                      Row(
                        children: [
                          _circleHeaderBtn(
                            icon: Icons.favorite_border_rounded,
                            onTap: () {},
                          ),
                          const SizedBox(width: 10),
                          _circleHeaderBtn(
                            icon: Icons.search_rounded,
                            onTap: () {},
                          ),
                        ],
                      ),

                      // Right: Back Arrow Button (>)
                      _circleHeaderBtn(
                        icon: Icons.arrow_forward_ios_rounded,
                        iconSize: 16,
                        onTap: () => Get.back(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        // ── B. Store Info Section (Overlapping Logo + Text on White) ──
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 1. RIGHT: Store Logo Overlapping the Cover Top (-38dp) ──
                Transform.translate(
                  offset: const Offset(0, -38),
                  child: Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F5E29),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: store?.logo != null && store!.logo!.isNotEmpty
                          ? CustomImage(image: store.logo!, fit: BoxFit.cover)
                          : _buildAlwalimahLogo(),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // ── 2. LEFT: Badges, Title, Description ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      // Top Row: Delivery Badges + Rating Tag
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Delivery Chips
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildDeliveryBadge(
                                icon: Icons.delivery_dining_rounded,
                                label: 'free_delivery'.tr,
                                iconColor: const Color(0xFF1B8A3C),
                              ),
                              const SizedBox(width: 6),
                              _buildDeliveryBadge(
                                icon: Icons.access_time_rounded,
                                label: store?.deliveryTime ?? '30 دقيقة',
                              ),
                            ],
                          ),

                          // Rating Tag
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF9DFCA3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  ratingText,
                                  style: const TextStyle(
                                    color: Color(0xFF111B18),
                                    fontSize: 12,
                                    fontFamily: 'Tajawal',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                const Icon(
                                  Icons.star_rounded,
                                  size: 13,
                                  color: Color(0xFF111B18),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Store Name
                      Text(
                        store?.name ?? campaign?.title ?? 'اسم المتجر',
                        style: const TextStyle(
                          color: Color(0xFF111B18),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Tajawal',
                        ),
                      ),

                      const SizedBox(height: 2),

                      // Store Description
                      Text(
                        campaign?.description ?? 'وصف لمنتجات المتجر',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF4B5563),
                          fontSize: 13,
                          fontFamily: 'Tajawal',
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // 2. Category Tab & Section Header
  // ─────────────────────────────────────────────────────────────────
  Widget _buildCategoryAndHeader() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // "المنتجات المجانية" Filter Tab
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F8EE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'المنتجات المجانية',
                style: TextStyle(
                  color: Color(0xFF0F5E2B),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),

            const SizedBox(height: 14),

            // "كل المنتجات" Section Title
            const Text(
              'كل المنتجات',
              style: TextStyle(
                color: Color(0xFF111B18),
                fontSize: 17,
                fontWeight: FontWeight.w800,
                fontFamily: 'Tajawal',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // 3. Product Card (Clean RTL Layout, SAR Glyph, No Overflow)
  // ─────────────────────────────────────────────────────────────────
  Widget _buildProductCard({
    required DynamicGiftController ctrl,
    required SelectableGiftItem item,
    required int itemId,
    required bool isSelected,
  }) {
    final isFree = item.isFree == true || (item.discountPrice == 0.0 && item.originalPrice != null && item.originalPrice! > 0);
    final badgeText = isFree ? 'مجاناً' : (item.discountPrice != null && item.originalPrice != null && item.originalPrice! > item.discountPrice! ? '-${(((item.originalPrice! - item.discountPrice!) / item.originalPrice!) * 100).round()}%' : '-6%');
    final displayPrice = isFree ? '00.00' : (item.discountPrice != null && item.discountPrice! > 0 ? item.discountPrice!.toStringAsFixed(2) : '250');

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF3F4F6), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── 1. RIGHT: Product Image Container with Badge ──
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: item.image != null && item.image!.isNotEmpty
                        ? CustomImage(
                            image: item.image!,
                            width: 76,
                            height: 76,
                            fit: BoxFit.contain,
                          )
                        : _buildAlwalimahRiceImage(),
                  ),
                ),

                // Discount Badge on Top Right
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFEAEA),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomLeft: Radius.circular(6),
                      ),
                    ),
                    child: Text(
                      badgeText,
                      style: const TextStyle(
                        color: Color(0xFFDC2626),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 12),

            // ── 2. MIDDLE: Title, Weight, Price Row with SAR Icon ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    item.name ?? 'الوليمة أرز مزة بسمتي هندي 5 كجم',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF111B18),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Tajawal',
                      height: 1.25,
                    ),
                  ),

                  const SizedBox(height: 3),

                  // Weight / Subtitle
                  Text(
                    item.description ?? '5 كجم',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF4B5563),
                      fontSize: 12,
                      fontFamily: 'Tajawal',
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Price Row with standard Shella SAR Image Asset
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Current Price
                      Text(
                        displayPrice,
                        style: const TextStyle(
                          color: Color(0xFF111B18),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      const SizedBox(width: 3),
                      Image.asset(
                        Images.sar,
                        height: 13,
                        color: const Color(0xFF111B18),
                      ),

                      if (item.originalPrice != null && item.originalPrice! > 0) ...[
                        const SizedBox(width: 8),
                        // Strikethrough Original Price with SAR
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  item.originalPrice!.toStringAsFixed(2),
                                  style: const TextStyle(
                                    color: Color(0xFF707784),
                                    fontSize: 11,
                                    fontFamily: 'Tajawal',
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Image.asset(
                                  Images.sar,
                                  height: 9,
                                  color: const Color(0xFF707784),
                                ),
                              ],
                            ),
                            Positioned.fill(
                              child: Center(
                                child: Container(
                                  height: 1.2,
                                  color: const Color(0xFFDC2626),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ── 3. LEFT: Heart + Stepper / Plus Button ──
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Heart Favorite Button
                GestureDetector(
                  onTap: () => ctrl.toggleItemSelection(item),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF6F7F9),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        isSelected ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        size: 18,
                        color: isSelected ? const Color(0xFF2E913E) : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Stepper Pill or Plus Circle Button (Single Selection Only!)
                if (isSelected)
                  Container(
                    height: 28,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E913E),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () => ctrl.decrementQuantity(itemId),
                          child: const Icon(Icons.remove, size: 14, color: Colors.white),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '1',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => ctrl.incrementQuantity(itemId, item),
                          child: const Icon(Icons.add, size: 14, color: Colors.white),
                        ),
                      ],
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () => ctrl.selectItem(item),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD1FDD2),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add_rounded,
                          size: 20,
                          color: Color(0xFF2E913E),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // 4. Floating Cart Button (Attached to Right Edge using Images.bag_v2_active)
  // ─────────────────────────────────────────────────────────────────
  Widget _buildFloatingCart(BuildContext context, DynamicGiftController ctrl) {
    final totalQty = ctrl.totalGiftQuantity;

    return Positioned(
      right: 0,
      bottom: 120,
      child: GestureDetector(
        onTap: () => ctrl.setStep(1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: const BoxDecoration(
            color: Color(0xFF2E913E),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(22),
              bottomLeft: Radius.circular(22),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Image.asset(
                Images.bag_v2_active,
                width: 24,
                height: 24,
                color: Colors.white,
              ),
              if (totalQty > 0)
                Positioned(
                  bottom: -2,
                  left: -2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Color(0xFFDC2626),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                    child: Center(
                      child: Text(
                        '$totalQty',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Tajawal',
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Helper Widgets: Circle Buttons, Delivery Badges, Alwalimah Artworks
  // ─────────────────────────────────────────────────────────────────
  Widget _circleHeaderBtn({
    required IconData icon,
    required VoidCallback onTap,
    double iconSize = 20,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(icon, size: iconSize, color: const Color(0xFF1F2937)),
        ),
      ),
    );
  }

  Widget _buildDeliveryBadge({
    required IconData icon,
    required String label,
    Color iconColor = const Color(0xFF111B18),
  }) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 13, color: iconColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF111B18),
              fontSize: 11,
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlwalimahLogo() {
    return Container(
      color: const Color(0xFF0F5E29),
      padding: const EdgeInsets.all(4),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.eco_rounded, color: Colors.white, size: 22),
          SizedBox(height: 2),
          Text(
            'الوليمة',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Tajawal',
              height: 1.0,
            ),
          ),
          Text(
            'ALWALIMAH',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 6.5,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.5,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlwalimahRiceImage() {
    return Center(
      child: Container(
        width: 58,
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFFF3EDE2),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFE2D6C3), width: 1),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Red Top Ribbon / Handles
            Positioned(
              top: 2,
              child: Container(
                width: 24,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Rice Sack Label
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 6),
                const Icon(Icons.eco_rounded, size: 14, color: Color(0xFF0F5E29)),
                const Text(
                  'الوليمة',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDC2626),
                    fontFamily: 'Tajawal',
                    height: 1.0,
                  ),
                ),
                Text(
                  'ALWALIMAH',
                  style: TextStyle(
                    fontSize: 5,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade700,
                    height: 1.1,
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

// ─────────────────────────────────────────────────────────────────
// Custom Painter for Botanical Leaves Illustration
// ─────────────────────────────────────────────────────────────────
class _BotanicalLeavesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.16)
      ..style = PaintingStyle.fill;

    // Leaf 1: Top Right Curved Leaf
    final path1 = Path();
    path1.moveTo(size.width * 0.95, 0);
    path1.quadraticBezierTo(
      size.width * 0.45,
      size.height * 0.15,
      size.width * 0.60,
      size.height * 0.65,
    );
    path1.quadraticBezierTo(
      size.width * 0.90,
      size.height * 0.35,
      size.width * 0.95,
      0,
    );
    path1.close();
    canvas.drawPath(path1, paint);

    // Leaf 2: Middle Spreading Leaf
    final path2 = Path();
    path2.moveTo(size.width * 0.90, size.height * 0.10);
    path2.quadraticBezierTo(
      size.width * 0.20,
      size.height * 0.45,
      size.width * 0.35,
      size.height * 0.90,
    );
    path2.quadraticBezierTo(
      size.width * 0.80,
      size.height * 0.65,
      size.width * 0.90,
      size.height * 0.10,
    );
    path2.close();
    canvas.drawPath(path2, paint);

    // Leaf 3: Lower Background Leaf
    final paintFaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..style = PaintingStyle.fill;

    final path3 = Path();
    path3.moveTo(size.width * 0.85, size.height * 0.30);
    path3.quadraticBezierTo(
      size.width * 0.05,
      size.height * 0.70,
      size.width * 0.20,
      size.height * 1.10,
    );
    path3.quadraticBezierTo(
      size.width * 0.70,
      size.height * 0.95,
      size.width * 0.85,
      size.height * 0.30,
    );
    path3.close();
    canvas.drawPath(path3, paintFaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
