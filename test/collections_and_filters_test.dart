import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shelfwise/utilities/collections.dart';
import 'package:shelfwise/utilities/filter.dart';

Item makeItem(
  String id, {
  String name = 'Item',
  double price = 10,
  int quantity = 1,
  String? location,
  String? status,
  String? image,
  List<String>? images,
  Map<String, Set<String>>? tags,
}) {
  return Item(id, name, price, quantity, location, status, image, images, tags);
}

void main() {
  group('Item persistence', () {
    test('normalizes the primary image and image list', () {
      final item = makeItem(
        'item-1',
        image: ' primary.jpg ',
        images: ['primary.jpg', ' second.jpg ', '', 'second.jpg'],
      );

      expect(item.images, ['primary.jpg', 'second.jpg']);
      expect(item.img, ' primary.jpg ');

      item.setImages(['third.jpg', 'primary.jpg']);

      expect(item.images, ['primary.jpg', 'third.jpg']);
      expect(item.img, 'primary.jpg');
    });

    test('round-trips item data through JSON', () {
      final item = makeItem(
        'item-1',
        name: 'Desk lamp',
        price: 24.5,
        quantity: 3,
        location: 'Office',
        status: 'Available',
        image: 'lamp.jpg',
        images: ['lamp.jpg', 'box.jpg'],
        tags: {
          'Room': {'Office'},
          'Color': {'White', 'Blue'},
        },
      );

      final decoded = FileMethods.itemsFromJsonString(
        FileMethods.itemsToJsonString([item]),
      );

      expect(decoded, hasLength(1));
      expect(decoded.single.toJson(), item.toJson());
    });

    test('uses safe defaults for legacy item fields', () {
      final items = FileMethods.itemsFromJsonString('''[
        {
          "id": "legacy-1",
          "name": "Legacy item",
          "price": 4.5,
          "location": null,
          "status": "Available",
          "img": "legacy.jpg"
        }
      ]''');

      expect(items.single.quantity, 1);
      expect(items.single.tags, isEmpty);
      expect(items.single.images, ['legacy.jpg']);
    });

    test('keeps the first item when serialized IDs are duplicated', () {
      final items = FileMethods.itemsFromJsonString('''[
        {"id":"same","name":"First","price":1,"quantity":1},
        {"id":"same","name":"Second","price":2,"quantity":2}
      ]''');

      expect(items, hasLength(1));
      expect(items.single.name, 'First');
    });
  });

  group('FilterCriteria', () {
    final items = [
      makeItem(
        'available-office',
        name: 'Office chair',
        price: 80,
        quantity: 2,
        location: 'Office',
        status: 'Available',
        tags: {
          'Room': {'Office'},
        },
      ),
      makeItem(
        'available-garage',
        name: 'Toolbox',
        price: 35,
        quantity: 1,
        location: 'Garage',
        status: 'Available',
        tags: {
          'Room': {'Garage'},
        },
      ),
      makeItem(
        'sold-office',
        name: 'Old monitor',
        price: 80,
        quantity: 1,
        location: 'Office',
        status: 'Sold',
        tags: {
          'Room': {'Office'},
        },
      ),
    ];

    test(
      'applies status, location, stock, price, and tag filters together',
      () {
        const criteria = FilterCriteria(
          status: 'Available',
          location: 'Office',
          lowStockOnly: true,
          lowStockThreshold: 2,
          priceRange: RangeValues(50, 100),
          tagFilters: {
            'Room': {'Office'},
          },
        );

        final result = criteria.apply(items, 100);

        expect(result.map((item) => item.id), ['available-office']);
        expect(criteria.hasActiveFilters, isTrue);
      },
    );

    test('uses the effective minimum price range when max price is low', () {
      final lowPriceItems = [makeItem('cheap', price: 4)];

      expect(FilterCriteria().apply(lowPriceItems, 4), lowPriceItems);
    });
  });
}
