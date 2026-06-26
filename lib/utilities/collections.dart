import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FileMethods {
  static const String _itemsWebKey = 'items_json';
  static const String _tagsWebKey = 'tags_json';
  static const String _locationsWebKey = 'locations_json';
  static const String _statusesWebKey = 'statuses_json';
  static const String _itemsWebBackupKey = 'items_json_backup';
  static const String _tagsWebBackupKey = 'tags_json_backup';
  static const String _locationsWebBackupKey = 'locations_json_backup';
  static const String _statusesWebBackupKey = 'statuses_json_backup';

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

  Future<File> get _localLocationFile async {
    final path = await _localPath;
    return File('$path/locations.json');
  }

  Future<File> get _localStatusFile async {
    final path = await _localPath;
    return File('$path/statuses.json');
  }

  Future<File> get _localItemBackupFile async {
    final path = await _localPath;
    return File('$path/items.json.bak');
  }

  Future<File> get _localTagBackupFile async {
    final path = await _localPath;
    return File('$path/tags.json.bak');
  }

  Future<File> get _localLocationBackupFile async {
    final path = await _localPath;
    return File('$path/locations.json.bak');
  }

  Future<File> get _localStatusBackupFile async {
    final path = await _localPath;
    return File('$path/statuses.json.bak');
  }

  Future<File> writeItems(List<Item> itemsToSave) async {
    final encoded = itemsToJsonString(itemsToSave);

    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getString(_itemsWebKey);
      if (existing != null && existing.trim().isNotEmpty) {
        await prefs.setString(_itemsWebBackupKey, existing);
      }
      await prefs.setString(_itemsWebKey, encoded);
      return File('');
    }

    final file = await _localItemFile;
    final backup = await _localItemBackupFile;
    await _writeWithBackup(file, backup, encoded);
    return file;
  }

  Future<File> writeTags(Set<Tag> tagsToSave) async {
    final encoded = tagsToJsonString(tagsToSave);

    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getString(_tagsWebKey);
      if (existing != null && existing.trim().isNotEmpty) {
        await prefs.setString(_tagsWebBackupKey, existing);
      }
      await prefs.setString(_tagsWebKey, encoded);
      return File('');
    }

    final file = await _localTagFile;
    final backup = await _localTagBackupFile;
    await _writeWithBackup(file, backup, encoded);
    return file;
  }

  Future<File> writeLocations(Set<String> locationsToSave) async {
    final encoded = stringSetToJsonString(locationsToSave);

    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getString(_locationsWebKey);
      if (existing != null && existing.trim().isNotEmpty) {
        await prefs.setString(_locationsWebBackupKey, existing);
      }
      await prefs.setString(_locationsWebKey, encoded);
      return File('');
    }

    final file = await _localLocationFile;
    final backup = await _localLocationBackupFile;
    await _writeWithBackup(file, backup, encoded);
    return file;
  }

  Future<File> writeStatuses(Set<String> statusesToSave) async {
    final encoded = stringSetToJsonString(statusesToSave);

    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getString(_statusesWebKey);
      if (existing != null && existing.trim().isNotEmpty) {
        await prefs.setString(_statusesWebBackupKey, existing);
      }
      await prefs.setString(_statusesWebKey, encoded);
      return File('');
    }

    final file = await _localStatusFile;
    final backup = await _localStatusBackupFile;
    await _writeWithBackup(file, backup, encoded);
    return file;
  }

  Future<List<Item>> readItems() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final content = prefs.getString(_itemsWebKey) ?? '';
      if (content.trim().isNotEmpty) {
        final decoded = tryItemsFromJsonString(content);
        if (decoded != null) {
          return decoded;
        }
      }

      final backupContent = prefs.getString(_itemsWebBackupKey) ?? '';
      if (backupContent.trim().isNotEmpty) {
        final decodedBackup = tryItemsFromJsonString(backupContent);
        if (decodedBackup != null) {
          await prefs.setString(_itemsWebKey, backupContent);
          return decodedBackup;
        }
      }

      return <Item>[];
    }

    final file = await _localItemFile;
    final backup = await _localItemBackupFile;
    final recoveredContent = await _readRecoverableJson(file, backup);
    if (recoveredContent == null) {
      return <Item>[];
    }

    final decoded = tryItemsFromJsonString(recoveredContent);
    if (decoded == null) {
      final recoveredFromBackup = await _recoverFromBackup(file, backup);
      if (recoveredFromBackup == null) {
        return <Item>[];
      }
      return tryItemsFromJsonString(recoveredFromBackup) ?? <Item>[];
    }

    return decoded;
  }

  Future<Set<Tag>> readTags() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final content = prefs.getString(_tagsWebKey) ?? '';
      if (content.trim().isNotEmpty) {
        final decoded = tryTagsFromJsonString(content);
        if (decoded != null) {
          return decoded;
        }
      }

      final backupContent = prefs.getString(_tagsWebBackupKey) ?? '';
      if (backupContent.trim().isNotEmpty) {
        final decodedBackup = tryTagsFromJsonString(backupContent);
        if (decodedBackup != null) {
          await prefs.setString(_tagsWebKey, backupContent);
          return decodedBackup;
        }
      }

      return <Tag>{};
    }

    final file = await _localTagFile;
    final backup = await _localTagBackupFile;
    final recoveredContent = await _readRecoverableJson(file, backup);
    if (recoveredContent == null) {
      return <Tag>{};
    }

    final decoded = tryTagsFromJsonString(recoveredContent);
    if (decoded == null) {
      final recoveredFromBackup = await _recoverFromBackup(file, backup);
      if (recoveredFromBackup == null) {
        return <Tag>{};
      }
      return tryTagsFromJsonString(recoveredFromBackup) ?? <Tag>{};
    }

    return decoded;
  }

  Future<Set<String>> readLocations() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final content = prefs.getString(_locationsWebKey) ?? '';
      if (content.trim().isNotEmpty) {
        final decoded = tryStringSetFromJsonString(content);
        if (decoded != null) {
          return decoded;
        }
      }

      final backupContent = prefs.getString(_locationsWebBackupKey) ?? '';
      if (backupContent.trim().isNotEmpty) {
        final decodedBackup = tryStringSetFromJsonString(backupContent);
        if (decodedBackup != null) {
          await prefs.setString(_locationsWebKey, backupContent);
          return decodedBackup;
        }
      }

      return <String>{};
    }

    final file = await _localLocationFile;
    final backup = await _localLocationBackupFile;
    final recoveredContent = await _readRecoverableJson(file, backup);
    if (recoveredContent == null) {
      return <String>{};
    }

    final decoded = tryStringSetFromJsonString(recoveredContent);
    if (decoded == null) {
      final recoveredFromBackup = await _recoverFromBackup(file, backup);
      if (recoveredFromBackup == null) {
        return <String>{};
      }
      return tryStringSetFromJsonString(recoveredFromBackup) ?? <String>{};
    }

    return decoded;
  }

  Future<Set<String>> readStatuses() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final content = prefs.getString(_statusesWebKey) ?? '';
      if (content.trim().isNotEmpty) {
        final decoded = tryStringSetFromJsonString(content);
        if (decoded != null) {
          return decoded;
        }
      }

      final backupContent = prefs.getString(_statusesWebBackupKey) ?? '';
      if (backupContent.trim().isNotEmpty) {
        final decodedBackup = tryStringSetFromJsonString(backupContent);
        if (decodedBackup != null) {
          await prefs.setString(_statusesWebKey, backupContent);
          return decodedBackup;
        }
      }

      return <String>{};
    }

    final file = await _localStatusFile;
    final backup = await _localStatusBackupFile;
    final recoveredContent = await _readRecoverableJson(file, backup);
    if (recoveredContent == null) {
      return <String>{};
    }

    final decoded = tryStringSetFromJsonString(recoveredContent);
    if (decoded == null) {
      final recoveredFromBackup = await _recoverFromBackup(file, backup);
      if (recoveredFromBackup == null) {
        return <String>{};
      }
      return tryStringSetFromJsonString(recoveredFromBackup) ?? <String>{};
    }

    return decoded;
  }

  Future<void> _writeWithBackup(File file, File backup, String content) async {
    await file.parent.create(recursive: true);

    if (await file.exists()) {
      final existing = await file.readAsString();
      if (existing.trim().isNotEmpty) {
        await backup.writeAsString(existing, flush: true);
      }
    }

    await file.writeAsString(content, flush: true);
  }

  Future<String?> _readRecoverableJson(File file, File backup) async {
    if (await file.exists()) {
      final content = await file.readAsString();
      if (content.trim().isNotEmpty) {
        return content;
      }
    }

    return _recoverFromBackup(file, backup);
  }

  Future<String?> _recoverFromBackup(File file, File backup) async {
    if (!await backup.exists()) {
      return null;
    }

    final backupContent = await backup.readAsString();
    if (backupContent.trim().isEmpty) {
      return null;
    }

    await file.writeAsString(backupContent, flush: true);
    return backupContent;
  }

  static String itemsToJsonString(List<Item> itemsToEncode) {
    final sortedItems = List<Item>.from(itemsToEncode)
      ..sort((a, b) => a.id.compareTo(b.id));
    return jsonEncode(sortedItems.map((item) => item.toJson()).toList());
  }

  static List<Item> itemsFromJsonString(String jsonString) {
    final decoded = jsonDecode(jsonString);
    if (decoded is! List) {
      return <Item>[];
    }

    final items = decoded
        .map((entry) => Item.fromJson(Map<String, dynamic>.from(entry as Map)))
        .toList();

    return _dedupeItemsById(items);
  }

  static List<Item>? tryItemsFromJsonString(String jsonString) {
    try {
      return itemsFromJsonString(jsonString);
    } catch (_) {
      return null;
    }
  }

  static List<Item> _dedupeItemsById(List<Item> items) {
    final seenIds = <String>{};
    final result = <Item>[];

    for (final item in items) {
      if (seenIds.add(item.id)) {
        result.add(item);
      }
    }

    return result;
  }

  static String tagsToJsonString(Set<Tag> tagsToEncode) {
    final sortedTags = tagsToEncode.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return jsonEncode(sortedTags.map((tag) => tag.toJson()).toList());
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

  static Set<Tag>? tryTagsFromJsonString(String jsonString) {
    try {
      return tagsFromJsonString(jsonString);
    } catch (_) {
      return null;
    }
  }

  static String stringSetToJsonString(Set<String> valuesToEncode) {
    final sortedValues = valuesToEncode.toList()..sort();
    return jsonEncode(sortedValues);
  }

  static Set<String> stringSetFromJsonString(String jsonString) {
    final decoded = jsonDecode(jsonString);
    if (decoded is! List) {
      return <String>{};
    }
    return Set<String>.from(decoded.map((entry) => entry.toString()));
  }

  static Set<String>? tryStringSetFromJsonString(String jsonString) {
    try {
      return stringSetFromJsonString(jsonString);
    } catch (_) {
      return null;
    }
  }
}

class Collections {
  List<Item> items;
  Set<Tag> tags;
  Set<String> locations;
  Set<String> status;
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
    await fileMethods.writeLocations(locations);
    await fileMethods.writeStatuses(status);
  }

  void persistChanges() {
    unawaited(
      saveToDisk().catchError((error, stackTrace) {
        debugPrint('Failed to persist collections: $error');
        debugPrintStack(stackTrace: stackTrace);
      }),
    );
  }

  void _upsertItem(Item i) {
    final index = items.indexWhere((existingItem) => existingItem.id == i.id);
    if (index >= 0) {
      items[index] = i;
    } else {
      items.add(i);
    }
    _recalculateMaxPrice();
    persistChanges();
  }

  Set<String> getAllLocations() {
    return UnmodifiableSetView(locations);
  }

  Set<String> getAllStatuses() {
    return UnmodifiableSetView(status);
  }

  Set<Tag> getAllTags() {
    return UnmodifiableSetView(tags);
  }

  Set<String>? getTagOptions(String tagName) {
    for (Tag t in tags) {
      if (t.name == tagName) {
        final options = t.options;
        if (options == null) {
          return null;
        }
        return UnmodifiableSetView(options);
      }
    }
    return null;
  }

  Collections addItem(Item i) {
    _upsertItem(i);
    return this;
  }

  Collections addTag(Tag t) {
    for (Tag existingTag in tags) {
      if (existingTag.name == t.name) {
        existingTag.options?.addAll(t.options ?? {});
        persistChanges();
        return this;
      }
    }
    tags.add(t);
    persistChanges();
    return this;
  }

  Collections addTagOption(String tagName, String option) {
    for (Tag existingTag in tags) {
      if (existingTag.name == tagName) {
        existingTag.addOption(option);
        persistChanges();
        return this;
      }
    }
    final newTag = Tag(tagName, {option});
    tags.add(newTag);
    persistChanges();
    return this;
  }

  Collections addLocation(String l) {
    final added = locations.add(l);
    if (added) {
      persistChanges();
    }
    return this;
  }

  Collections addStatus(String s) {
    final added = status.add(s);
    if (added) {
      persistChanges();
    }
    return this;
  }

  Collections removeItem(Item i) {
    items.removeWhere((existingItem) => existingItem.id == i.id);
    _recalculateMaxPrice();
    persistChanges();
    return this;
  }

  Collections removeTag(String name) {
    for (Item i in items) {
      if (i.containsTag(name)) {
        throw Exception(
          "Cannot remove tag $name because it is in use by item ${i.name}.",
        );
      }
    }
    tags.removeWhere((t) => t.name == name);
    persistChanges();
    return this;
  }

  Collections removeTagOption(String tagName, String option) {
    for (Tag existingTag in tags) {
      if (existingTag.name == tagName) {
        for (Item i in items) {
          if (i.containsOption(tagName, option)) {
            throw Exception(
              "Cannot remove option $option from tag $tagName because it is in use by item ${i.name}.",
            );
          }
        }
        existingTag.removeOption(option);
        persistChanges();
        return this;
      }
    }
    return this;
  }

  Collections removeLocation(String l) {
    for (Item i in items) {
      if (i.location == l) {
        throw Exception(
          "Cannot remove location $l because it is in use by item ${i.name}.",
        );
      }
    }
    final removed = locations.remove(l);
    if (removed) {
      persistChanges();
    }
    return this;
  }

  Collections removeStatus(String s) {
    for (Item i in items) {
      if (i.status == s) {
        throw Exception(
          "Cannot remove status $s because it is in use by item ${i.name}.",
        );
      }
    }
    final removed = status.remove(s);
    if (removed) {
      persistChanges();
    }
    return this;
  }

  Collections editItem(Item i) {
    _upsertItem(i);
    return this;
  }

  static List<Item> getAllByStatus(List<Item> items, String status) {
    List<Item> filteredItems = [];
    for (Item i in items) {
      if (i.hasStatus(status)) {
        filteredItems.add(i);
      }
    }
    return filteredItems;
  }

  static List<Item> getAllByLocation(List<Item> items, String location) {
    List<Item> filteredItems = [];
    for (Item i in items) {
      if (i.hasLocation(location)) {
        filteredItems.add(i);
      }
    }
    return filteredItems;
  }

  static List<Item> getAllByTag(List<Item> items, String name, String option) {
    List<Item> filteredItems = [];
    for (Item i in items) {
      if (i.containsOption(name, option)) {
        filteredItems.add(i);
      }
    }
    return filteredItems;
  }

  static List<Item> getAllBetween(List<Item> items, double min, double max) {
    List<Item> filteredItems = [];
    for (Item i in items) {
      if (i.priceBetween(min, max)) {
        filteredItems.add(i);
      }
    }
    return filteredItems;
  }
}

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
    final sortedTagKeys = tags.keys.toList()..sort();
    final normalizedTags = <String, List<String>>{};
    for (final key in sortedTagKeys) {
      final sortedValues = (tags[key]?.toList() ?? <String>[])..sort();
      normalizedTags[key] = sortedValues;
    }

    return {
      'id': id,
      'name': name,
      'price': price,
      'location': location,
      'status': status,
      'img': img,
      'tags': normalizedTags,
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

  bool containsOption(String name, String option) {
    final values = tags[name];
    if (values == null) {
      return false;
    }
    return values.contains(option);
  }

  bool containsTag(String name) {
    return tags.containsKey(name);
  }

  bool hasStatus(String status) {
    return (status == this.status);
  }

  bool hasLocation(String location) {
    return (this.location == location);
  }
}

class Tag {
  String name;
  Set<String>? options;

  Tag(this.name, this.options);

  Map<String, dynamic> toJson() {
    final sortedOptions = options == null ? null : (options!.toList()..sort());
    return {'name': name, 'options': sortedOptions};
  }

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      json['name'] as String,
      json['options'] != null
          ? Set<String>.from(
              (json['options'] as List).map((entry) => entry.toString()),
            )
          : null,
    );
  }

  String getName() {
    return name;
  }

  Set<String>? getOptions() {
    return options;
  }

  @override
  String toString() {
    return "$name: $options";
  }

  Tag addOption(String o) {
    options ??= <String>{};
    if (!options!.contains(o)) {
      options!.add(o);
    }
    return this;
  }

  Tag removeOption(String o) {
    options?.remove(o);
    return this;
  }
}
