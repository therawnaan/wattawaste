import 'package:flutter_challenge/model/cart_item_model.dart';
import 'package:flutter_challenge/model/offer_model.dart';
import 'package:flutter_test/flutter_test.dart';

OfferModel _makeOffer({
  String id = 't1',
  int originalPrice = 200,
  int discountedPrice = 50,
  int quantityLeft = 5,
}) {
  return OfferModel(
    id: id,
    title: 'Test',
    storeName: 'Store',
    category: 'bakery',
    originalPrice: originalPrice,
    discountedPrice: discountedPrice,
    quantityLeft: quantityLeft,
    imageUrl: 'https://example.com/x.jpg',
    pickupWindow: '18:00',
    co2Kg: 1,
    isFavorite: false,
  );
}

void main() {
  group('CartItemModel.lineTotal', () {
    test('uses discounted price not original price', () {
      final item = CartItemModel(offer: _makeOffer(), quantity: 2);
      expect(item.lineTotal, 100); // 50 * 2, not 200 * 2
    });

    test('quantity of 1 returns discounted price once', () {
      final item = CartItemModel(offer: _makeOffer(), quantity: 1);
      expect(item.lineTotal, 50);
    });

    test('quantity of 0 returns 0', () {
      final item = CartItemModel(offer: _makeOffer(), quantity: 0);
      expect(item.lineTotal, 0);
    });

    test('full price item with no discount', () {
      final item = CartItemModel(
        offer: _makeOffer(originalPrice: 100, discountedPrice: 100),
        quantity: 3,
      );
      expect(item.lineTotal, 300);
    });
  });

  group('Cart total across multiple items', () {
    test('sums lineTotal across all items', () {
      final items = [
        CartItemModel(
            offer: _makeOffer(id: 't1', discountedPrice: 50), quantity: 2),
        CartItemModel(
            offer: _makeOffer(id: 't2', discountedPrice: 80), quantity: 1),
        CartItemModel(
            offer: _makeOffer(id: 't3', discountedPrice: 30), quantity: 3),
      ];

      final total = items.fold(0, (sum, item) => sum + item.lineTotal);
      expect(total, 270); // (50*2) + (80*1) + (30*3)
    });

    test('empty cart returns 0', () {
      final items = <CartItemModel>[];
      final total = items.fold(0, (sum, item) => sum + item.lineTotal);
      expect(total, 0);
    });
  });
}
