import 'package:flutter_challenge/model/offer_model.dart';
import 'package:flutter_challenge/repository/offer_repo.dart';
import 'package:flutter_challenge/service/the_exceptions.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

enum OfferFilter { all, bakery, cafe, market }

class HomeScreenController extends GetxController {
  final OfferRepo _offerRepo = Get.find<OfferRepo>();

  final RxBool _isLoading = true.obs;
  final RxBool _hasError = false.obs;
  final RxList<OfferModel> _offers = <OfferModel>[].obs;
  final Rx<OfferFilter> _activeFilter = OfferFilter.all.obs;
  final RxString _searchQuery = ''.obs;

  final RefreshController refreshController =
      RefreshController(initialRefresh: false);

  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;
  List<OfferModel> get offers => _offers;
  OfferFilter get activeFilter => _activeFilter.value;
  String get searchQuery => _searchQuery.value;

  /// INTENTIONAL GAP (Task A1): filter + search not applied — returns all offers.
  List<OfferModel> get visibleOffers {
    return _offers.where((o) {
      final matchesFilter = _activeFilter.value == OfferFilter.all ||
          o.category == _activeFilter.value.name;
      final q = _searchQuery.value.toLowerCase();
      final matchesSearch = q.isEmpty ||
          o.title.toLowerCase().contains(q) ||
          o.storeName.toLowerCase().contains(q);
      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchOffers();
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }

  Future<void> fetchOffers() async {
    _isLoading.value = true;
    _hasError.value = false;
    try {
      final data = await _offerRepo.fetchOffers();
      _offers.assignAll(data);
    } on TheException catch (e) {
      _hasError.value = true;
      Get.snackbar('error_generic'.tr, e.displayError());
    } finally {
      _isLoading.value = false;
    }
  }

  void setFilter(OfferFilter filter) {
    _activeFilter.value = filter;
    // INTENTIONAL GAP (Task A1): candidate should refresh visibleOffers.
    // Changes not necessary here
  }

  void setSearchQuery(String value) {
    _searchQuery.value = value;
    // INTENTIONAL GAP (Task A1): candidate should refresh visibleOffers.
    // Changes not necessary here.
  }

  Future<void> toggleFavorite(String offerId) async {
    await _offerRepo.toggleFavorite(offerId);
    // INTENTIONAL GAP (Task B2): list does not update after toggle.
    final index = _offers.indexWhere((o) => o.id == offerId);
    if (index != -1) {
      _offers[index] = _offers[index].copyWith(
        isFavorite: !_offers[index].isFavorite,
      );
    }
  }

  /// INTENTIONAL GAP (Task A3): pull-to-refresh not wired in UI — candidate connects this.
  Future<void> onRefresh() async {
    await fetchOffers();
    refreshController.refreshCompleted();
  }
}
