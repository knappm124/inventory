import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utilities/newitem.dart';
import 'utilities/collections.dart';
import 'utilities/itemwidgets.dart';
import 'utilities/filter.dart';
import 'utilities/menu.dart';

ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF0E7490),
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      side: BorderSide(color: colorScheme.outlineVariant),
      selectedColor: colorScheme.primaryContainer,
      checkmarkColor: colorScheme.onPrimaryContainer,
      labelStyle: TextStyle(color: colorScheme.onSurface),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    // Keep this only for non-web platforms where path_provider is available.
    // The app now uses a web-safe fallback for Chrome.
  }
  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  static const String _lowStockThresholdPrefKey = 'inventory.lowStockThreshold';

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Collections? _collections;
  List<Item>? _filteredItems;
  FilterCriteria? _filterCriteria;
  String? _loadErrorMessage;
  int _lowStockThreshold = FilterCriteria.defaultLowStockThreshold;

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    try {
      final fileMethods = FileMethods();
      final savedItems = await fileMethods.readItems();
      final savedTags = await fileMethods.readTags();
      final savedLocations = await fileMethods.readLocations();
      final savedStatuses = await fileMethods.readStatuses();
      final prefs = await SharedPreferences.getInstance();
      final savedLowStockThreshold =
          prefs.getInt(_lowStockThresholdPrefKey) ??
          FilterCriteria.defaultLowStockThreshold;

      final loadedLocations = savedLocations.isEmpty
          ? _defaultLocations()
          : {...savedLocations, ..._defaultLocations()};
      final loadedStatuses = savedStatuses.isEmpty
          ? _defaultStatuses()
          : {...savedStatuses, ..._defaultStatuses()};

      final loadedCollections = Collections(
        savedItems.isEmpty ? _defaultItems() : savedItems,
        savedTags.isEmpty ? _defaultTags() : savedTags,
        loadedLocations,
        loadedStatuses,
        onPersistenceError: _handlePersistenceError,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _loadErrorMessage = null;
        _lowStockThreshold = savedLowStockThreshold > 0
            ? savedLowStockThreshold
            : FilterCriteria.defaultLowStockThreshold;
        _collections = loadedCollections;
        _applyCurrentFilters();
      });

      await _showLegacyMigrationNoticeIfNeeded();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _collections = null;
        _loadErrorMessage = 'Failed to load inventory data.';
      });
    }
  }

  void _handlePersistenceError(Object error) {
    if (!mounted) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentContext =
          _scaffoldKey.currentContext ?? _navigatorKey.currentContext;
      if (currentContext == null) {
        return;
      }
      ScaffoldMessenger.of(currentContext).showSnackBar(
        const SnackBar(
          content: Text('Could not save changes. Please try again.'),
        ),
      );
    });
  }

  Future<void> _showLegacyMigrationNoticeIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final migrationDetected =
        prefs.getBool(FileMethods.legacyItemsMigrationDetectedKey) ?? false;
    final noticeShown =
        prefs.getBool(FileMethods.legacyItemsMigrationNoticeShownKey) ?? false;

    if (!migrationDetected || noticeShown || !mounted) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentContext = _scaffoldKey.currentContext;
      if (currentContext == null) {
        return;
      }
      ScaffoldMessenger.of(currentContext).showSnackBar(
        const SnackBar(
          content: Text(
            'Older inventory records were migrated to the latest format.',
          ),
        ),
      );
    });

    await prefs.setBool(FileMethods.legacyItemsMigrationNoticeShownKey, true);
    await prefs.setBool(FileMethods.legacyItemsMigrationDetectedKey, false);
  }

  Future<void> _openNewItem() async {
    if (_collections == null) {
      return;
    }

    final result = await _navigatorKey.currentState?.push<Item>(
      MaterialPageRoute(
        builder: (context) => NewItem(collections: _collections!),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _applyCurrentFilters();
    });
  }

  void _refreshItems() {
    if (!mounted) {
      return;
    }

    setState(() {
      _applyCurrentFilters();
    });
  }

  void _onFilterChanged(List<Item> filteredItems) {
    setState(() {
      _filteredItems = filteredItems;
    });
  }

  void _onCriteriaChanged(FilterCriteria criteria) {
    setState(() {
      _filterCriteria = FilterCriteria(
        status: criteria.status,
        location: criteria.location,
        lowStockOnly: criteria.lowStockOnly,
        lowStockThreshold: _lowStockThreshold,
        priceRange: criteria.priceRange,
        tagFilters: criteria.tagFilters,
      );
      _applyCurrentFilters();
    });
  }

  Future<void> _onLowStockThresholdChanged(int threshold) async {
    if (threshold <= 0) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lowStockThresholdPrefKey, threshold);

    if (!mounted) {
      return;
    }

    setState(() {
      _lowStockThreshold = threshold;
      if (_filterCriteria != null) {
        _filterCriteria = FilterCriteria(
          status: _filterCriteria!.status,
          location: _filterCriteria!.location,
          lowStockOnly: _filterCriteria!.lowStockOnly,
          lowStockThreshold: threshold,
          priceRange: _filterCriteria!.priceRange,
          tagFilters: _filterCriteria!.tagFilters,
        );
      }
      _applyCurrentFilters();
    });
  }

  void _applyCurrentFilters() {
    final activeCriteria =
        _filterCriteria ??
        FilterCriteria(lowStockThreshold: _lowStockThreshold);

    if (_collections == null) {
      _filteredItems = null;
      return;
    }

    if (!activeCriteria.hasActiveFilters) {
      _filteredItems = null;
      return;
    }

    _filteredItems = activeCriteria.apply(
      _collections!.items,
      _collections!.maxPrice,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_collections == null) {
      return MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          appBar: AppBar(title: const Text('My Inventory')),
          body: Center(
            child: _loadErrorMessage == null
                ? CircularProgressIndicator()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_loadErrorMessage!),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loadCollections,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
          ),
        ),
      );
    }

    return MaterialApp(
      theme: buildAppTheme(),
      navigatorKey: _navigatorKey,
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('My Inventory'),
          actions: [
            IconButton(
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              tooltip: 'Open filters',
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              icon: const Icon(Icons.filter_alt_outlined),
            ),
            IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Menu(
                    c: _collections!,
                    lowStockThreshold: _lowStockThreshold,
                    onLowStockThresholdChanged: _onLowStockThresholdChanged,
                  ),
                ),
              ),
              tooltip: 'Open menu',
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              icon: const Icon(Icons.tune),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: SafeArea(
          child: Scroll(
            collections: _collections!,
            filteredItems: _filteredItems,
            onAddPressed: _openNewItem,
            onItemsChanged: _refreshItems,
            lowStockThreshold: _lowStockThreshold,
            onLowStockThresholdChanged: _onLowStockThresholdChanged,
            scaffoldKey: _scaffoldKey,
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openNewItem,
          icon: const Icon(Icons.add),
          label: const Text('Add Item'),
        ),
        drawer: Filter(
          c: _collections!,
          criteria:
              _filterCriteria ??
              FilterCriteria(lowStockThreshold: _lowStockThreshold),
          onCriteriaChanged: _onCriteriaChanged,
          onFilterChanged: _onFilterChanged,
        ),
      ),
    );
  }
}

Set<String> _defaultLocations() {
  return {};
}

Set<String> _defaultStatuses() {
  return {};
}

List<Item> _defaultItems() {
  return [];
}

Set<Tag> _defaultTags() {
  return {};
}

class Scroll extends StatefulWidget {
  final Collections collections;
  final List<Item>? filteredItems;
  final VoidCallback onAddPressed;
  final VoidCallback onItemsChanged;
  final int lowStockThreshold;
  final ValueChanged<int> onLowStockThresholdChanged;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const Scroll({
    super.key,
    required this.collections,
    required this.filteredItems,
    required this.onAddPressed,
    required this.onItemsChanged,
    required this.lowStockThreshold,
    required this.onLowStockThresholdChanged,
    required this.scaffoldKey,
  });

  @override
  State<Scroll> createState() => _ScrollState();
}

enum SortOption { nameAsc, priceLowToHigh, priceHighToLow, statusAsc }

class _ScrollState extends State<Scroll> {
  static const String _searchPrefKey = 'inventory.searchQuery';
  static const String _sortPrefKey = 'inventory.sortOption';

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  SortOption _sortOption = SortOption.nameAsc;

  @override
  void initState() {
    super.initState();
    unawaited(_restoreListPreferences());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _restoreListPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSearch = prefs.getString(_searchPrefKey) ?? '';
    final savedSortIndex = prefs.getInt(_sortPrefKey);

    if (!mounted) {
      return;
    }

    final savedSort =
        savedSortIndex != null &&
            savedSortIndex >= 0 &&
            savedSortIndex < SortOption.values.length
        ? SortOption.values[savedSortIndex]
        : SortOption.nameAsc;

    setState(() {
      _searchQuery = savedSearch;
      _searchController.text = savedSearch;
      _sortOption = savedSort;
    });
  }

  Future<void> _persistListPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_searchPrefKey, _searchQuery);
    await prefs.setInt(_sortPrefKey, _sortOption.index);
  }

  List<Item> _buildVisibleItems() {
    final baseItems = List<Item>.from(
      widget.filteredItems ?? widget.collections.items,
    );
    final query = _searchQuery.trim().toLowerCase();

    final filteredBySearch = query.isEmpty
        ? baseItems
        : baseItems.where((item) {
            return item.name.toLowerCase().contains(query) ||
                (item.location?.toLowerCase().contains(query) ?? false) ||
                (item.status?.toLowerCase().contains(query) ?? false);
          }).toList();

    switch (_sortOption) {
      case SortOption.nameAsc:
        filteredBySearch.sort((a, b) => a.name.compareTo(b.name));
        return filteredBySearch;
      case SortOption.priceLowToHigh:
        filteredBySearch.sort((a, b) => a.price.compareTo(b.price));
        return filteredBySearch;
      case SortOption.priceHighToLow:
        filteredBySearch.sort((a, b) => b.price.compareTo(a.price));
        return filteredBySearch;
      case SortOption.statusAsc:
        filteredBySearch.sort(
          (a, b) => (a.status ?? '').compareTo(b.status ?? ''),
        );
        return filteredBySearch;
    }
  }

  String _sortLabel(SortOption option) {
    switch (option) {
      case SortOption.nameAsc:
        return 'Name (A-Z)';
      case SortOption.priceLowToHigh:
        return 'Price (Low-High)';
      case SortOption.priceHighToLow:
        return 'Price (High-Low)';
      case SortOption.statusAsc:
        return 'Status (A-Z)';
    }
  }

  Widget _buildSortChip(SortOption option) {
    final selected = _sortOption == option;
    return ChoiceChip(
      label: Text(_sortLabel(option)),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) {
        setState(() {
          _sortOption = option;
        });
        unawaited(_persistListPreferences());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemsToDisplay = _buildVisibleItems();
    final hasFilters = widget.filteredItems != null;
    final hasSearch = _searchQuery.trim().isNotEmpty;
    final hasNoItems = widget.collections.items.isEmpty;

    String emptyStateMessage = 'No items yet. Tap + to add your first item.';
    if (hasFilters) {
      emptyStateMessage = 'No items match your current filters.';
    }
    if (hasSearch) {
      emptyStateMessage = 'No items match your search.';
    }

    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: FocusTraversalOrder(
                    order: const NumericFocusOrder(1),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Search name, location, or status',
                        border: const OutlineInputBorder(),
                        suffixIcon: hasSearch
                            ? IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                  unawaited(_persistListPreferences());
                                },
                                icon: const Icon(Icons.clear),
                                tooltip: 'Clear search',
                                constraints: const BoxConstraints(
                                  minWidth: 48,
                                  minHeight: 48,
                                ),
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                        unawaited(_persistListPreferences());
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: FocusTraversalOrder(
              order: const NumericFocusOrder(2),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: SortOption.values.map(_buildSortChip).toList(),
                ),
              ),
            ),
          ),
          Expanded(
            child: itemsToDisplay.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 64),
                        const SizedBox(height: 8),
                        Text(emptyStateMessage),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: widget.onAddPressed,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Item'),
                        ),
                        if (hasSearch)
                          TextButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                              unawaited(_persistListPreferences());
                            },
                            child: const Text('Clear Search'),
                          ),
                        if (hasFilters && !hasNoItems)
                          TextButton(
                            onPressed: () {
                              widget.scaffoldKey.currentState?.openDrawer();
                            },
                            child: const Text('Adjust Filters'),
                          ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: itemsToDisplay.length,
                    itemBuilder: (context, index) {
                      return ItemRow(
                        key: ValueKey(itemsToDisplay[index].id),
                        i: itemsToDisplay[index],
                        index: index,
                        collections: widget.collections,
                        onChanged: widget.onItemsChanged,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
