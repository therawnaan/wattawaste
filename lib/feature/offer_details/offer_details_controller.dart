import 'package:flutter_challenge/model/offer_model.dart';
import 'package:flutter_challenge/repository/offer_repo.dart';
import 'package:flutter_challenge/service/cart_service.dart';
import 'package:get/get.dart';

class OfferDetailsController extends GetxController {
  final OfferRepo _offerRepo = Get.find<OfferRepo>();
  final CartService _cartService = Get.find<CartService>();

  final RxBool isLoading = true.obs;
  final Rx<OfferModel?> offer = Rx<OfferModel?>(null);
  final RxInt quantity = 1.obs;

  @override
  void onInit() {
    super.onInit();
    _loadOffer(Get.parameters['id'] ?? '');
  }

  Future<void> _loadOffer(String id) async {
    isLoading.value = true;
    offer.value = await _offerRepo.fetchOfferById(id);
    isLoading.value = false;
  }

  void increment() {
    final max = offer.value?.quantityLeft ?? 1;
    if (quantity.value < max) quantity.value++;
  }

  void decrement() {
    if (quantity.value > 1) quantity.value--;
  }

  Future<void> addToBag() async {
    final o = offer.value;
    if (o == null) return;
    await _cartService.addOffer(o, quantity: quantity.value);
    Get.snackbar(
      'add_to_bag'.tr,
      '${quantity.value}× ${o.title}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}