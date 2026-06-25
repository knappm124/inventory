import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utilities/newitem.dart';
import 'utilities/collections.dart';
import 'utilities/itemwidgets.dart';
import 'utilities/filter.dart';
import 'utilities/menu.dart';

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
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Collections? _collections;
  List<Item>? _filteredItems;
  FilterCriteria? _filterCriteria;

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    final savedItems = await FileMethods().readItems();
    final savedTags = await FileMethods().readTags();

    final loadedCollections = Collections(
      savedItems.isEmpty ? _defaultItems() : savedItems,
      savedTags.isEmpty ? _defaultTags() : savedTags,
      {"Etsy", "Home", "General Store"},
      {"WIP", "Sold", "Listed", "Returned"},
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _collections = loadedCollections;
      _applyCurrentFilters();
    });
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
      _filterCriteria = criteria;
      _applyCurrentFilters();
    });
  }

  void _applyCurrentFilters() {
    final activeCriteria = _filterCriteria ?? const FilterCriteria();

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
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      navigatorKey: _navigatorKey,
      home: Scaffold(
        key: _scaffoldKey,
        body: SafeArea(
          child: Center(
            child: Scroll(
              collections: _collections!,
              filteredItems: _filteredItems,
              onAddPressed: _openNewItem,
              onItemsChanged: _refreshItems,
              scaffoldKey: _scaffoldKey,
            ),
          ),
        ),
        drawer: Filter(
          c: _collections!,
          criteria: _filterCriteria ?? const FilterCriteria(),
          onCriteriaChanged: _onCriteriaChanged,
          onFilterChanged: _onFilterChanged,
        ),
      ),
    );
  }
}

List<Item> _defaultItems() {
  return [];
}

Set<Tag> _defaultTags() {
  return {
    Tag("1", "Color", {
      "Red",
      "Orange",
      "Yellow",
      "Green",
      "Blue",
      "Purple",
      "Pink",
      "Brown",
      "Black",
    }),
    Tag("2", "Size", {
      "Quail",
      "Pullet",
      "Chicken",
      "Duck",
      "Goose",
      "Rhea",
      "Ostrich",
    }),
    Tag("3", "Occasion", {
      "Baby",
      "Christmas",
      "Easter",
      "Fall",
      "Spring",
      "Wedding",
    }),
    Tag("4", "Symbols", {"Animal", "Person", "Plants", "Religious", "Star"}),
    Tag("5", "Division", {
      "Band",
      "Circles",
      "Diagonal Band",
      "Four Panels",
      "Star",
      "Triangles",
    }),
  };
}

class NavBar extends StatelessWidget {
  final VoidCallback onAddPressed;
  final GlobalKey<ScaffoldState> _scaffoldKey;
  final Collections c;

  const NavBar({
    super.key,
    required this.onAddPressed,
    required this._scaffoldKey,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
          icon: Icon(Icons.filter_alt_outlined),
        ),
        IconButton(onPressed: onAddPressed, icon: Icon(Icons.add)),
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Menu(c: c)),
          ),
          icon: Icon(Icons.menu),
        ),
      ],
    );
  }
}

class Scroll extends StatefulWidget {
  final Collections collections;
  final List<Item>? filteredItems;
  final VoidCallback onAddPressed;
  final VoidCallback onItemsChanged;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const Scroll({
    super.key,
    required this.collections,
    required this.filteredItems,
    required this.onAddPressed,
    required this.onItemsChanged,
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

    if (!mounted) {
      return;
    }

    setState(() {
      _searchQuery = savedSearch;
      _searchController.text = savedSearch;
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
                item.location.toLowerCase().contains(query) ||
                item.status.toLowerCase().contains(query);
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
        filteredBySearch.sort((a, b) => a.status.compareTo(b.status));
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

    return Column(
      children: [
        const Text('My Inventory'),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
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
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: SortOption.values.map(_buildSortChip).toList(),
            ),
          ),
        ),
        const SizedBox(height: 8),
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
        const SizedBox(height: 8),
        NavBar(
          onAddPressed: widget.onAddPressed,
          scaffoldKey: widget.scaffoldKey,
          c: widget.collections,
        ),
      ],
    );
  }
}
