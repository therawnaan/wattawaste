import 'package:flutter/material.dart';
import 'package:flutter_challenge/feature/offer_details/offer_details_controller.dart';
import 'package:flutter_challenge/feature/shared_widget/the_button.dart';
import 'package:flutter_challenge/feature/shared_widget/the_network_image.dart';
import 'package:flutter_challenge/util/constants/app_colors.dart';
import 'package:flutter_challenge/util/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// INTENTIONAL GAP (Task A2): Screen is a stub — candidate implements full UI + controller.
class OfferDetailsScreen extends GetView<OfferDetailsController> {
  const OfferDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text('offer_details'.tr, style: Styles.boldText18())),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final offer = controller.offer.value;
        if (offer == null) {
          return Center(child: Text('error_generic'.tr));
        }
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        TheNetworkImage(
                            imageUrl: offer.imageUrl, height: 220.h),
                        Positioned(
                          top: 12.h,
                          left: 12.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: AppColors.badgeDiscount,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              '-${offer.discountPercent}%',
                              style: Styles.sBoldText12(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(offer.title, style: Styles.boldText18()),
                          SizedBox(height: 4.h),
                          Text(offer.storeName, style: Styles.regularText14()),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              Text(
                                '฿${offer.discountedPrice}',
                                style:
                                    Styles.boldText18(color: AppColors.primary),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                '฿${offer.originalPrice}',
                                style: Styles.regularText14().copyWith(
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          _infoRow(Icons.access_time, offer.pickupWindow),
                          SizedBox(height: 8.h),
                          _infoRow(Icons.inventory_2_outlined,
                              '${offer.quantityLeft} left'),
                          SizedBox(height: 8.h),
                          _co2Badge(offer.co2Kg),
                          SizedBox(height: 24.h),
                          Row(
                            children: [
                              Text('quantity'.tr, style: Styles.mediumText16()),
                              const Spacer(),
                              IconButton(
                                onPressed: controller.decrement,
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                              Obx(() => Text(
                                    '${controller.quantity.value}',
                                    style: Styles.mediumText16(),
                                  )),
                              IconButton(
                                onPressed: controller.increment,
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: TheButton(
                label: 'add_to_bag'.tr,
                onPressed: controller.addToBag,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18.r, color: AppColors.primary),
        SizedBox(width: 8.w),
        Text(text, style: Styles.regularText14()),
      ],
    );
  }

  Widget _co2Badge(double kg) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.eco, color: Colors.green, size: 18),
          SizedBox(width: 6.w),
          Text(
            '${'co2_saved'.tr}: ${kg.toStringAsFixed(1)} kg',
            style: Styles.sBoldText12(color: Colors.green),
          ),
        ],
      ),
    );
  }
}
