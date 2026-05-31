import 'package:flutter_challenge/model/offer_model.dart';
import 'package:flutter_challenge/repository/offer_repo.dart';
import 'package:flutter_challenge/service/the_exceptions.dart';
import 'package:get/get.dart';
import 'package:flutter_challenge/util/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum OfferFilter { all, bakery, cafe, market }

class HomeScreenController extends GetxController {
  final OfferRepo _offerRepo = Get.find<OfferRepo>();

  final RxBool _isLoading = true.obs;
  final RxBool _hasError = false.obs;
  final RxList<OfferModel> _offers = <OfferModel>[].obs;
  final Rx<OfferFilter> _activeFilter = OfferFilter.all.obs;
  final RxString _searchQuery = ''.obs;
  final RxBool _favoritesOnly = false.obs;

  bool get favoritesOnly => _favoritesOnly.value;
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
      final matchesFavorites = !_favoritesOnly.value || o.isFavorite;
      return matchesFilter && matchesSearch && matchesFavorites;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    _loadFavoritesFilter();
    fetchOffers();
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

  Future<void> _loadFavoritesFilter() async {
    final prefs = Get.find<SharedPreferences>();
    _favoritesOnly.value =
        prefs.getBool(AppConstants.FAVORITES_FILTER_PREF_KEY) ?? false;
  }

  Future<void> toggleFavoritesFilter() async {
    _favoritesOnly.value = !_favoritesOnly.value;
    final prefs = Get.find<SharedPreferences>();
    await prefs.setBool(
        AppConstants.FAVORITES_FILTER_PREF_KEY, _favoritesOnly.value);
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
  }
}
