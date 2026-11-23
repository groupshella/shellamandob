import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:flutter/material.dart';

/// Skeleton loading widgets for instant UI feedback
class SkeletonLoadingWidgets {
  /// Skeleton for brand item card
  static Widget brandItemSkeleton() {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image skeleton
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Title skeleton
          Container(
            height: 14,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 6),

          // Price skeleton
          Container(
            height: 12,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 6),

          // Button skeleton
          Container(
            height: 28,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  /// Skeleton for category item card
  static Widget categoryItemSkeleton() {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image skeleton
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 12),

          // Title skeleton
          Container(
            height: 16,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),

          // Price skeleton
          Container(
            height: 14,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  /// Skeleton for store item card
  static Widget storeItemSkeleton() {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image skeleton
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 12),

          // Title skeleton
          Container(
            height: 18,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),

          // Description skeleton
          Container(
            height: 14,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 14,
            width: 120,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),

          // Price and button row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 16,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                height: 32,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Shimmer effect for skeleton loading
  static Widget shimmerEffect({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[300]!,
            Colors.grey[100]!,
            Colors.grey[300]!,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: child,
    );
  }

  /// Grid of skeleton items
  static Widget skeletonGrid({
    required int itemCount,
    required Widget Function() itemBuilder,
    int crossAxisCount = 2,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.75,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => itemBuilder(),
    );
  }

  /// List of skeleton items
  static Widget skeletonList({
    required int itemCount,
    required Widget Function() itemBuilder,
  }) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
      itemCount: itemCount,
      itemBuilder: (context, index) => itemBuilder(),
    );
  }

  /// Base Shimmer Box for layout-matched loading skeletons (Theme-aware)
  static Widget shimmerBox({
    required double height,
    double? width,
    double borderRadius = 8,
    EdgeInsetsGeometry? margin,
    bool isDark = false,
  }) {
    final baseColor = isDark ? const Color(0xFF1E222B) : const Color(0xFFE5E7EB);
    final highlightColor = isDark ? const Color(0xFF2C3240) : const Color(0xFFF3F4F6);

    return Container(
      height: height,
      width: width,
      margin: margin,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Shimmer(
          color: highlightColor,
          colorOpacity: 0.6,
          duration: const Duration(milliseconds: 1400),
          child: Container(
            color: baseColor,
          ),
        ),
      ),
    );
  }

  /// Skeleton for Growth Specialist Earnings Dashboard
  static Widget earningsDashboardSkeleton({bool isDark = false}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          // 1. Top Hero Card
          shimmerBox(
            height: 140,
            width: double.infinity,
            borderRadius: 20,
            isDark: isDark,
          ),
          const SizedBox(height: 16),

          // 2. Grid of 4 layer cards
          Row(
            children: [
              Expanded(child: shimmerBox(height: 180, borderRadius: 16, isDark: isDark)),
              const SizedBox(width: 12),
              Expanded(child: shimmerBox(height: 180, borderRadius: 16, isDark: isDark)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: shimmerBox(height: 180, borderRadius: 16, isDark: isDark)),
              const SizedBox(width: 12),
              Expanded(child: shimmerBox(height: 180, borderRadius: 16, isDark: isDark)),
            ],
          ),
        ],
      ),
    );
  }

  /// Skeleton for Store Visit Cards in Daily Visits Screen
  static Widget storeVisitCardSkeleton({bool isDark = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2028) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2C3240) : const Color(0xFFF0F0F2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              shimmerBox(height: 44, width: 44, borderRadius: 12, isDark: isDark),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    shimmerBox(height: 16, width: 140, borderRadius: 4, isDark: isDark),
                    const SizedBox(height: 6),
                    shimmerBox(height: 12, width: 90, borderRadius: 4, isDark: isDark),
                  ],
                ),
              ),
              shimmerBox(height: 24, width: 64, borderRadius: 12, isDark: isDark),
            ],
          ),
          const SizedBox(height: 14),
          shimmerBox(height: 38, width: double.infinity, borderRadius: 10, isDark: isDark),
        ],
      ),
    );
  }

  /// Skeleton for Supervised Marketer Card in My Network Screen
  static Widget supervisedMarketerCardSkeleton({bool isDark = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2028) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2C3240) : const Color(0xFFF0F0F2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              shimmerBox(height: 48, width: 48, borderRadius: 24, isDark: isDark),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    shimmerBox(height: 16, width: 120, borderRadius: 4, isDark: isDark),
                    const SizedBox(height: 6),
                    shimmerBox(height: 12, width: 80, borderRadius: 4, isDark: isDark),
                  ],
                ),
              ),
              shimmerBox(height: 22, width: 60, borderRadius: 8, isDark: isDark),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: shimmerBox(height: 32, borderRadius: 8, isDark: isDark)),
              const SizedBox(width: 8),
              Expanded(child: shimmerBox(height: 32, borderRadius: 8, isDark: isDark)),
            ],
          ),
        ],
      ),
    );
  }

  /// Skeleton for Supervisor Recommendation Card
  static Widget supervisorRecommendationSkeleton({bool isDark = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2028) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2C3240) : const Color(0xFFF0F0F2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              shimmerBox(height: 22, width: 70, borderRadius: 8, isDark: isDark),
              shimmerBox(height: 14, width: 80, borderRadius: 4, isDark: isDark),
            ],
          ),
          const SizedBox(height: 12),
          shimmerBox(height: 16, width: double.infinity, borderRadius: 4, isDark: isDark),
          const SizedBox(height: 6),
          shimmerBox(height: 16, width: 200, borderRadius: 4, isDark: isDark),
        ],
      ),
    );
  }

  /// Skeleton for User Profile Screen
  static Widget profileScreenSkeleton({bool isDark = false}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          // Avatar + User Details
          shimmerBox(height: 80, width: 80, borderRadius: 40, isDark: isDark),
          const SizedBox(height: 12),
          shimmerBox(height: 20, width: 160, borderRadius: 4, isDark: isDark),
          const SizedBox(height: 8),
          shimmerBox(height: 14, width: 110, borderRadius: 4, isDark: isDark),
          const SizedBox(height: 24),

          // 3 Wallet / Stats Cards
          Row(
            children: [
              Expanded(child: shimmerBox(height: 70, borderRadius: 12, isDark: isDark)),
              const SizedBox(width: 8),
              Expanded(child: shimmerBox(height: 70, borderRadius: 12, isDark: isDark)),
              const SizedBox(width: 8),
              Expanded(child: shimmerBox(height: 70, borderRadius: 12, isDark: isDark)),
            ],
          ),
          const SizedBox(height: 24),

          // Menu Tiles
          shimmerBox(height: 52, width: double.infinity, borderRadius: 12, isDark: isDark),
          const SizedBox(height: 10),
          shimmerBox(height: 52, width: double.infinity, borderRadius: 12, isDark: isDark),
          const SizedBox(height: 10),
          shimmerBox(height: 52, width: double.infinity, borderRadius: 12, isDark: isDark),
        ],
      ),
    );
  }

  /// Skeleton for Employee / Marketer Home Dashboard
  static Widget employeeHomeSkeleton({bool isDark = false}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header (Greeting + Notification icon)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  shimmerBox(height: 14, width: 90, borderRadius: 4, isDark: isDark),
                  const SizedBox(height: 6),
                  shimmerBox(height: 20, width: 140, borderRadius: 4, isDark: isDark),
                ],
              ),
              shimmerBox(height: 40, width: 40, borderRadius: 20, isDark: isDark),
            ],
          ),
          const SizedBox(height: 20),

          // 2. Shift Status / Daily Target Card
          shimmerBox(height: 140, width: double.infinity, borderRadius: 16, isDark: isDark),
          const SizedBox(height: 16),

          // 3. 2x2 Metrics Grid
          Row(
            children: [
              Expanded(child: shimmerBox(height: 80, borderRadius: 12, isDark: isDark)),
              const SizedBox(width: 12),
              Expanded(child: shimmerBox(height: 80, borderRadius: 12, isDark: isDark)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: shimmerBox(height: 80, borderRadius: 12, isDark: isDark)),
              const SizedBox(width: 12),
              Expanded(child: shimmerBox(height: 80, borderRadius: 12, isDark: isDark)),
            ],
          ),
          const SizedBox(height: 20),

          // 4. Quick Actions 4 items
          Row(
            children: [
              Expanded(child: shimmerBox(height: 90, borderRadius: 12, isDark: isDark)),
              const SizedBox(width: 10),
              Expanded(child: shimmerBox(height: 90, borderRadius: 12, isDark: isDark)),
              const SizedBox(width: 10),
              Expanded(child: shimmerBox(height: 90, borderRadius: 12, isDark: isDark)),
              const SizedBox(width: 10),
              Expanded(child: shimmerBox(height: 90, borderRadius: 12, isDark: isDark)),
            ],
          ),
          const SizedBox(height: 20),

          // 5. Visits summary card
          shimmerBox(height: 100, width: double.infinity, borderRadius: 14, isDark: isDark),
        ],
      ),
    );
  }

  /// Helper card wrapper for consistent themed shimmer containers
  static Widget _themedCard({
    required Widget child,
    bool isDark = false,
    double borderRadius = 18,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2028) : Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isDark ? const Color(0xFF2B3240) : const Color(0xFFE5E7EB),
          width: 0.8,
        ),
      ),
      child: child,
    );
  }

  /// Skeleton for Daily Productivity View (Figma 8949:41979)
  static Widget productivityDailySkeleton({bool isDark = false}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 2x2 KPI Grid
          Row(
            children: [
              Expanded(child: shimmerBox(height: 68, borderRadius: 18, isDark: isDark)),
              const SizedBox(width: 8),
              Expanded(child: shimmerBox(height: 68, borderRadius: 18, isDark: isDark)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: shimmerBox(height: 68, borderRadius: 18, isDark: isDark)),
              const SizedBox(width: 8),
              Expanded(child: shimmerBox(height: 68, borderRadius: 18, isDark: isDark)),
            ],
          ),
          const SizedBox(height: 12),
          // 3 Targets Row
          Row(
            children: [
              Expanded(child: shimmerBox(height: 118, borderRadius: 16, isDark: isDark)),
              const SizedBox(width: 8),
              Expanded(child: shimmerBox(height: 118, borderRadius: 16, isDark: isDark)),
              const SizedBox(width: 8),
              Expanded(child: shimmerBox(height: 118, borderRadius: 16, isDark: isDark)),
            ],
          ),
          const SizedBox(height: 12),
          // Timeline Card
          _themedCard(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                shimmerBox(height: 16, width: 110, borderRadius: 6, isDark: isDark),
                const SizedBox(height: 14),
                for (int i = 0; i < 3; i++) ...[
                  Row(
                    children: [
                      shimmerBox(height: 10, width: 10, borderRadius: 5, isDark: isDark),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            shimmerBox(height: 10, width: 65, borderRadius: 4, isDark: isDark),
                            const SizedBox(height: 6),
                            shimmerBox(height: 14, width: double.infinity, borderRadius: 6, isDark: isDark),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (i < 2) const SizedBox(height: 14),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Signed Agreements Card
          _themedCard(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                shimmerBox(height: 16, width: 130, borderRadius: 6, isDark: isDark),
                const SizedBox(height: 12),
                shimmerBox(height: 44, width: double.infinity, borderRadius: 10, isDark: isDark),
                const SizedBox(height: 8),
                shimmerBox(height: 44, width: double.infinity, borderRadius: 10, isDark: isDark),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Upcoming Follow-ups Card
          _themedCard(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    shimmerBox(height: 16, width: 120, borderRadius: 6, isDark: isDark),
                    shimmerBox(height: 14, width: 60, borderRadius: 6, isDark: isDark),
                  ],
                ),
                const SizedBox(height: 12),
                shimmerBox(height: 68, width: double.infinity, borderRadius: 10, isDark: isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Skeleton for Period Productivity View (Figma 8956:3247)
  static Widget productivityPeriodSkeleton({bool isDark = false}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Target Progress + 3 Mini Badges
          _themedCard(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    shimmerBox(height: 16, width: 110, borderRadius: 6, isDark: isDark),
                    shimmerBox(height: 22, width: 56, borderRadius: 12, isDark: isDark),
                  ],
                ),
                const SizedBox(height: 12),
                shimmerBox(height: 8, width: double.infinity, borderRadius: 4, isDark: isDark),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: shimmerBox(height: 54, borderRadius: 12, isDark: isDark)),
                    const SizedBox(width: 8),
                    Expanded(child: shimmerBox(height: 54, borderRadius: 12, isDark: isDark)),
                    const SizedBox(width: 8),
                    Expanded(child: shimmerBox(height: 54, borderRadius: 12, isDark: isDark)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Day Accordion Cards
          for (int i = 0; i < 3; i++) ...[
            shimmerBox(height: 62, width: double.infinity, borderRadius: 18, isDark: isDark),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 4),
          // Signed Agreements & Previous Leaves Cards
          shimmerBox(height: 120, width: double.infinity, borderRadius: 18, isDark: isDark),
          const SizedBox(height: 12),
          shimmerBox(height: 110, width: double.infinity, borderRadius: 18, isDark: isDark),
          const SizedBox(height: 12),
          // Period Summary 2x3 Grid
          _themedCard(
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                shimmerBox(height: 16, width: 110, borderRadius: 6, isDark: isDark),
                const SizedBox(height: 12),
                for (int r = 0; r < 3; r++) ...[
                  Row(
                    children: [
                      Expanded(child: shimmerBox(height: 62, borderRadius: 12, isDark: isDark)),
                      const SizedBox(width: 10),
                      Expanded(child: shimmerBox(height: 62, borderRadius: 12, isDark: isDark)),
                    ],
                  ),
                  if (r < 2) const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Skeleton for Sub-Marketer Profile Screen
  static Widget subMarketerProfileSkeleton({bool isDark = false}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _themedCard(
            isDark: isDark,
            child: Row(
              children: [
                shimmerBox(height: 56, width: 56, borderRadius: 28, isDark: isDark),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      shimmerBox(height: 16, width: 140, borderRadius: 6, isDark: isDark),
                      const SizedBox(height: 8),
                      shimmerBox(height: 12, width: 100, borderRadius: 4, isDark: isDark),
                    ],
                  ),
                ),
                shimmerBox(height: 26, width: 64, borderRadius: 12, isDark: isDark),
              ],
            ),
          ),
          const SizedBox(height: 14),
          shimmerBox(height: 116, width: double.infinity, borderRadius: 18, isDark: isDark),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: shimmerBox(height: 78, borderRadius: 16, isDark: isDark)),
              const SizedBox(width: 10),
              Expanded(child: shimmerBox(height: 78, borderRadius: 16, isDark: isDark)),
            ],
          ),
          const SizedBox(height: 14),
          for (int i = 0; i < 3; i++) ...[
            shimmerBox(height: 72, width: double.infinity, borderRadius: 16, isDark: isDark),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  /// Skeleton for Shella Lessons List Screen
  static Widget lessonsListSkeleton({bool isDark = false}) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => _themedCard(
        isDark: isDark,
        borderRadius: 16,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            shimmerBox(height: 68, width: 104, borderRadius: 12, isDark: isDark),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  shimmerBox(height: 15, width: double.infinity, borderRadius: 6, isDark: isDark),
                  const SizedBox(height: 8),
                  shimmerBox(height: 12, width: 120, borderRadius: 4, isDark: isDark),
                  const SizedBox(height: 8),
                  shimmerBox(height: 11, width: 70, borderRadius: 4, isDark: isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Skeleton for Vacations / Leave Balance Screen
  static Widget vacationsSkeleton({bool isDark = false}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: shimmerBox(height: 92, borderRadius: 16, isDark: isDark)),
              const SizedBox(width: 10),
              Expanded(child: shimmerBox(height: 92, borderRadius: 16, isDark: isDark)),
            ],
          ),
          const SizedBox(height: 16),
          shimmerBox(height: 48, width: double.infinity, borderRadius: 14, isDark: isDark),
          const SizedBox(height: 16),
          for (int i = 0; i < 4; i++) ...[
            shimmerBox(height: 76, width: double.infinity, borderRadius: 16, isDark: isDark),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  /// Skeleton for Visit Detail / Report / Contract Activation Screen
  static Widget visitDetailSkeleton({bool isDark = false}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          shimmerBox(height: 110, width: double.infinity, borderRadius: 18, isDark: isDark),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: shimmerBox(height: 74, borderRadius: 16, isDark: isDark)),
              const SizedBox(width: 10),
              Expanded(child: shimmerBox(height: 74, borderRadius: 16, isDark: isDark)),
            ],
          ),
          const SizedBox(height: 12),
          shimmerBox(height: 140, width: double.infinity, borderRadius: 18, isDark: isDark),
          const SizedBox(height: 12),
          shimmerBox(height: 110, width: double.infinity, borderRadius: 18, isDark: isDark),
        ],
      ),
    );
  }

  /// Skeleton for Generic List Cards (Objections, Zones, Activations, Requests, Stores)
  static Widget listCardsSkeleton({
    bool isDark = false,
    int itemCount = 5,
    double cardHeight = 86,
    double borderRadius = 16,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    return ListView.separated(
      padding: padding,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => _themedCard(
        isDark: isDark,
        borderRadius: borderRadius,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                shimmerBox(height: 15, width: 150, borderRadius: 6, isDark: isDark),
                shimmerBox(height: 22, width: 64, borderRadius: 10, isDark: isDark),
              ],
            ),
            const SizedBox(height: 10),
            shimmerBox(height: 12, width: double.infinity, borderRadius: 4, isDark: isDark),
            if (cardHeight > 78) ...[
              const SizedBox(height: 6),
              shimmerBox(height: 12, width: 180, borderRadius: 4, isDark: isDark),
            ],
          ],
        ),
      ),
    );
  }

  /// Compact Inline Card Shimmer (e.g., AI Visit Analysis card)
  static Widget inlineCardSkeleton({bool isDark = false, double height = 110}) {
    return _themedCard(
      isDark: isDark,
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              shimmerBox(height: 16, width: 140, borderRadius: 6, isDark: isDark),
              shimmerBox(height: 22, width: 58, borderRadius: 10, isDark: isDark),
            ],
          ),
          const SizedBox(height: 12),
          shimmerBox(height: 12, width: double.infinity, borderRadius: 4, isDark: isDark),
          const SizedBox(height: 8),
          shimmerBox(height: 12, width: 200, borderRadius: 4, isDark: isDark),
        ],
      ),
    );
  }
}
