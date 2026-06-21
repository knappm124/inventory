import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

@JsonSerializable()
class FileMethods {
  Future<String> get _localPath async {
    if (kIsWeb) {
      return '';
    }

    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localItemFile async {
    final path = await _localPath;
    return File('$path/items.json');
  }

  Future<File> get _localTagFile async {
    final path = await _localPath;
    return File('$path/tags.json');
  }

  Future<File> writeItems(Set<Item> itemsToSave) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('items_json', itemsToJsonString(itemsToSave));
      return File('');
    }

    final file = await _localItemFile;
    return file.writeAsString(itemsToJsonString(itemsToSave));
  }

  Future<File> writeTags(Set<Tag> tagsToSave) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('tags_json', tagsToJsonString(tagsToSave));
      return File('');
    }

    final file = await _localTagFile;
    return file.writeAsString(tagsToJsonString(tagsToSave));
  }

  Future<Set<Item>> readItems() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final content = prefs.getString('items_json') ?? '';
      if (content.trim().isEmpty) {
        return <Item>{};
      }
      return itemsFromJsonString(content);
    }

    final file = await _localItemFile;
    if (!await file.exists()) {
      return <Item>{};
    }

    final content = await file.readAsString();
    if (content.trim().isEmpty) {
      return <Item>{};
    }

    return itemsFromJsonString(content);
  }

  Future<Set<Tag>> readTags() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final content = prefs.getString('tags_json') ?? '';
      if (content.trim().isEmpty) {
        return <Tag>{};
      }
      return tagsFromJsonString(content);
    }

    final file = await _localTagFile;
    if (!await file.exists()) {
      return <Tag>{};
    }

    final content = await file.readAsString();
    if (content.trim().isEmpty) {
      return <Tag>{};
    }

    return tagsFromJsonString(content);
  }

  static String itemsToJsonString(Set<Item> itemsToEncode) {
    return jsonEncode(itemsToEncode.map((item) => item.toJson()).toList());
  }

  static Set<Item> itemsFromJsonString(String jsonString) {
    final decoded = jsonDecode(jsonString);
    if (decoded is! List) {
      return <Item>{};
    }

    return decoded
        .map((entry) => Item.fromJson(Map<String, dynamic>.from(entry as Map)))
        .toSet();
  }

  static String tagsToJsonString(Set<Tag> tagsToEncode) {
    return jsonEncode(tagsToEncode.map((tag) => tag.toJson()).toList());
  }

  static Set<Tag> tagsFromJsonString(String jsonString) {
    final decoded = jsonDecode(jsonString);
    if (decoded is! List) {
      return <Tag>{};
    }

    return decoded
        .map((entry) => Tag.fromJson(Map<String, dynamic>.from(entry as Map)))
        .toSet();
  }
}

@JsonSerializable()
class Collections {
  Set<Item> items;
  Set<Tag> tags;
  Set<String> locations = {"Home", "Etsy", "General Store"};
  Set<String> status = {"WIP", "Listed", "Sold", "Returned"};
  double maxPrice = 0;

  Collections(this.items, this.tags, this.locations, this.status) {
    _recalculateMaxPrice();
  }

  void _recalculateMaxPrice() {
    maxPrice = 0;
    for (final item in items) {
      if (item.price > maxPrice) {
        maxPrice = item.price;
      }
    }
  }

  Future<void> saveToDisk() async {
    final fileMethods = FileMethods();
    await fileMethods.writeItems(items);
    await fileMethods.writeTags(tags);
  }

  void persistChanges() {
    unawaited(saveToDisk());
  }

  void _upsertItem(Item i) {
    items.removeWhere((existingItem) => existingItem.id == i.id);
    items.add(i);
    _recalculateMaxPrice();
    persistChanges();
  }

  Collections addItem(Item i) {
    _upsertItem(i);
    return this;
  }

  Collections addTag(Tag t) {
    tags.add(t);
    persistChanges();
    return this;
  }

  Collections addLocation(String l) {
    locations.add(l);
    persistChanges();
    return this;
  }

  Collections addStatus(String s) {
    status.add(s);
    persistChanges();
    return this;
  }

  Collections removeItem(Item i) {
    items.remove(i);
    _recalculateMaxPrice();
    persistChanges();
    return this;
  }

  Collections removeTag(Tag t) {
    tags.remove(t);
    persistChanges();
    return this;
  }

  Collections removeLocation(String l) {
    locations.remove(l);
    persistChanges();
    return this;
  }

  Collections removeStatus(String s) {
    status.remove(s);
    persistChanges();
    return this;
  }

  Collections editTag(Tag t) {
    tags.removeWhere((Tag tag) => tag.id == t.id);
    tags.add(t);
    persistChanges();
    return this;
  }

  Collections editItem(Item i) {
    _upsertItem(i);
    return this;
  }

  static Set<Item> getAllByStatus(Set<Item> items, String status) {
    Set<Item> filteredItems = {};
    for (Item i in items) {
      if (i.hasStatus(status)) {
        filteredItems.add(i);
      }
    }
    return filteredItems;
  }

  static Set<Item> getAllByLocation(Set<Item> items, String location) {
    Set<Item> filteredItems = {};
    for (Item i in items) {
      if (i.hasLocation(location)) {
        filteredItems.add(i);
      }
    }
    return filteredItems;
  }

  static Set<Item> getAllByTag(Set<Item> items, String name, String option) {
    Set<Item> filteredItems = {};
    for (Item i in items) {
      if (i.containsTag(name, option)) {
        filteredItems.add(i);
      }
    }
    return filteredItems;
  }

  static Set<Item> getAllBetween(Set<Item> items, double min, double max) {
    Set<Item> filteredItems = {};
    for (Item i in items) {
      if (i.priceBetween(min, max)) {
        filteredItems.add(i);
      }
    }
    return filteredItems;
  }
}

@JsonSerializable()
class Item {
  String id;
  String name;
  double price;
  String location;
  String status;
  String img;
  Map<String, Set<String>> tags;

  Item(
    this.id,
    this.name,
    this.price,
    this.location,
    this.status,
    this.img,
    this.tags,
  );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'location': location,
      'status': status,
      'img': img,
      'tags': tags.map((key, value) => MapEntry(key, value.toList())),
    };
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      json['id'] as String,
      json['name'] as String,
      (json['price'] as num).toDouble(),
      json['location'] as String,
      json['status'] as String,
      json['img'] as String,
      (json['tags'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          Set<String>.from((value as List).map((entry) => entry.toString())),
        ),
      ),
    );
  }

  bool priceBetween(double min, double max) {
    return price >= min && price <= max;
  }

  bool containsTag(String name, String option) {
    bool exists = false;
    tags.forEach((key, values) {
      if (key == name) {
        exists = true;
      }
    });
    return exists;
  }

  bool hasStatus(String status) {
    return (status == this.status);
  }

  bool hasLocation(String location) {
    return (this.location == location);
  }
}

@JsonSerializable()
class Tag {
  String id;
  String name;
  Set<String> options;

  Tag(this.id, this.name, this.options);

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'options': options.toList()};
  }

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      json['id'] as String,
      json['name'] as String,
      Set<String>.from(
        (json['options'] as List).map((entry) => entry.toString()),
      ),
    );
  }

  @override
  String toString() {
    return "$name: $options";
  }

  Tag addOption(String o) {
    if (!options.contains(o)) {
      options.add(o);
    }
    return this;
  }

  Tag removeOption(String o) {
    options.remove(o);
    return this;
  }
}
