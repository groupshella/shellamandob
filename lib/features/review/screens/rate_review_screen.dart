import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/order/domain/models/order_details_model.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/features/review/controllers/review_controller.dart';
import 'package:sixam_mart/features/review/widgets/deliver_man_review_widget.dart';
import 'package:sixam_mart/features/review/widgets/item_review_widget.dart';
import 'package:sixam_mart/features/review/widgets/store_review_widget.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';

class RateReviewScreen extends StatefulWidget {
  final List<OrderDetailsModel> orderDetailsList;
  final DeliveryMan? deliveryMan;
  final Store? store;
  final OrderModel? order;
  final int? orderID;

  const RateReviewScreen({
    super.key,
    required this.orderDetailsList,
    required this.deliveryMan,
    this.store,
    this.order,
    required this.orderID,
  });

  @override
  RateReviewScreenState createState() => RateReviewScreenState();
}

class RateReviewScreenState extends State<RateReviewScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  static const Color _ink = Color(0xFF121C19);
  static const Color _green = Color(0xFF1FA64A);
  static const Color _muted = Color(0xFF8A8A8A);
  static const Color _bg = Color(0xFFF7F8FA);

  bool get _hasStore => widget.store != null;
  bool get _hasDeliveryMan => widget.deliveryMan != null;
  bool get _hasItems => widget.orderDetailsList.isNotEmpty;

  int get _tabCount {
    int count = 0;
    if (_hasItems) count++;
    if (_hasStore) count++;
    if (_hasDeliveryMan) count++;
    return count > 0 ? count : 1;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabCount, vsync: this);
    _tabController?.addListener(() {
      if (mounted) setState(() {});
    });

    final reviewController = Get.find<ReviewController>();
    reviewController.initRatingData(
      widget.orderDetailsList,
      initialStoreRating: widget.order?.storeReviewRating,
      initialStoreComment: widget.order?.storeReviewComment,
      initialStoreSubmitted: (widget.order?.isStoreReviewed == 1),
    );
    if (widget.order?.isDmReviewed == 1 && widget.order?.dmReviewRating != null) {
      reviewController.setDeliveryManRating(widget.order!.dmReviewRating!);
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool showTabBar = _tabCount > 1;

    final List<Widget> tabs = [];
    final List<Widget> tabViews = [];

    if (_hasItems) {
      tabs.add(
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fastfood_rounded, size: 16),
              const SizedBox(width: 6),
              Text(widget.orderDetailsList.length > 1
                  ? 'items'.tr
                  : 'item'.tr),
            ],
          ),
        ),
      );
      tabViews.add(ItemReviewWidget(orderDetailsList: widget.orderDetailsList));
    }

    if (_hasStore) {
      tabs.add(
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.storefront_rounded, size: 16),
              const SizedBox(width: 6),
              Text(Get.locale?.languageCode == 'ar' ? 'المطعم' : 'Store'),
            ],
          ),
        ),
      );
      tabViews.add(StoreReviewWidget(
        store: widget.store,
        orderID: widget.orderID.toString(),
      ));
    }

    if (_hasDeliveryMan) {
      tabs.add(
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.delivery_dining_rounded, size: 18),
              const SizedBox(width: 6),
              Text('delivery_man'.tr),
            ],
          ),
        ),
      );
      tabViews.add(DeliveryManReviewWidget(
        deliveryMan: widget.deliveryMan,
        orderID: widget.orderID.toString(),
      ));
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        automaticallyImplyLeading: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        title: Text(
          'rate_review'.tr,
          style: const TextStyle(
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: _ink,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: _ink,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        bottom: showTabBar
            ? PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDEFF1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(11),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: _green,
                    unselectedLabelColor: _muted,
                    labelStyle: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    tabs: tabs,
                  ),
                ),
              )
            : null,
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: tabViews,
        ),
      ),
    );
  }
}