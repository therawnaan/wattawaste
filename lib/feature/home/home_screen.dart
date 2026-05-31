import 'package:flutter/material.dart';
import 'package:flutter_challenge/feature/home/home_screen_controller.dart';
import 'package:flutter_challenge/feature/shared_widget/main_shell.dart';
import 'package:flutter_challenge/feature/shared_widget/offer_card.dart';
import 'package:flutter_challenge/util/constants/app_colors.dart';
import 'package:flutter_challenge/util/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends GetView<HomeScreenController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainShell(
      currentIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: Text('home_title'.tr, style: Styles.boldText18()),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              _buildSearchBar(),
              SizedBox(height: 12.h),
              _buildFilterChips(),
              SizedBox(height: 12.h),
              Expanded(child: _buildOfferList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'search_hint'.tr,
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        filled: true,
        fillColor: Colors.white,
      ),
      // INTENTIONAL GAP (Task A1): onChanged not connected to controller.setSearchQuery.
      onChanged: controller.setSearchQuery,
    );
  }

  Widget _buildFilterChips() {
    return Obx(() {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filterChip('filter_all'.tr, OfferFilter.all),
            _filterChip('filter_bakery'.tr, OfferFilter.bakery),
            _filterChip('filter_cafe'.tr, OfferFilter.cafe),
            _filterChip('filter_market'.tr, OfferFilter.market),
            _favoritesChip(),
          ],
        ),
      );
    });
  }

  Widget _filterChip(String label, OfferFilter filter) {
    final isSelected = controller.activeFilter == filter;
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => controller.setFilter(filter),
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        checkmarkColor: AppColors.primary,
      ),
    );
  }

  Widget _favoritesChip() {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: FilterChip(
        label: Text('filter_favorites'.tr),
        selected: controller.favoritesOnly,
        onSelected: (_) => controller.toggleFavoritesFilter(),
        selectedColor: Colors.red.withValues(alpha: 0.2),
        checkmarkColor: Colors.red,
        showCheckmark: false,
        elevation: 0,
        pressElevation: 0,
        avatar: Icon(
          controller.favoritesOnly ? Icons.favorite : Icons.favorite_border,
          color: controller.favoritesOnly ? Colors.red : null,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildOfferList() {
    return Obx(() {
      if (controller.isLoading) {
        return _buildShimmer();
      }
      if (controller.hasError) {
        return Center(
          child: Text('error_generic'.tr, style: Styles.regularText14()),
        );
      }

      final offers = controller.visibleOffers;
      // INTENTIONAL GAP (Task A4): no empty state widget when offers.isEmpty.
      if (offers.isEmpty) {
        return RefreshIndicator(
          onRefresh: controller.onRefresh,
          child: ListView(
            children: [
              SizedBox(height: 80.h),
              Center(
                child: Column(
                  children: [
                    Icon(Icons.search_off, size: 48.r, color: Colors.grey),
                    SizedBox(height: 12.h),
                    Text(
                      'empty_offers'.tr,
                      style: Styles.regularText14(),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.onRefresh,
        child: ListView.builder(
          itemCount: offers.length,
          itemBuilder: (context, index) {
            final offer = offers[index];
            return OfferCard(
              offer: offer,
              onFavoriteTap: () => controller.toggleFavorite(offer.id),
            );
          },
        ),
      );
    });
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.only(bottom: 12.h),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 140.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          height: 16.h, width: 160.w, color: Colors.white),
                      SizedBox(height: 8.h),
                      Container(
                          height: 12.h, width: 100.w, color: Colors.white),
                      SizedBox(height: 8.h),
                      Container(height: 12.h, width: 80.w, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
