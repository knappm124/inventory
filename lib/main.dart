import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'utilities/newitem.dart';
import 'utilities/collections.dart';
import 'utilities/itemwidgets.dart';
import 'utilities/filter.dart';

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
  Set<Item>? _filteredItems;
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

  void _onFilterChanged(Set<Item> filteredItems) {
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

Set<Item> _defaultItems() {
  return {};
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

  const NavBar({
    super.key,
    required this.onAddPressed,
    required this._scaffoldKey,
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
        IconButton(onPressed: null, icon: Icon(Icons.menu)),
      ],
    );
  }
}

class Scroll extends StatelessWidget {
  final Collections collections;
  final Set<Item>? filteredItems;
  final VoidCallback onAddPressed;
  final VoidCallback onItemsChanged;
  final GlobalKey<ScaffoldState> _scaffoldKey;

  const Scroll({
    super.key,
    required this.collections,
    required this.filteredItems,
    required this.onAddPressed,
    required this.onItemsChanged,
    required this._scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    final itemsToDisplay = filteredItems ?? collections.items;
    return Column(
      children: [
        Text("My Inventory"),
        Padding(padding: EdgeInsets.all(8.0)),
        Expanded(
          child: ReorderableListView.builder(
            buildDefaultDragHandles: false,
            itemCount: itemsToDisplay.length,
            itemBuilder: (context, index) {
              return Container(
                key: ValueKey(itemsToDisplay.elementAt(index)),
                child: ItemRow(
                  i: itemsToDisplay.elementAt(index),
                  index: index,
                  collections: collections,
                  onChanged: onItemsChanged,
                ),
              );
            },
            onReorderItem: (oldIndex, newIndex) {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              final item = itemsToDisplay.elementAt(oldIndex);
              List<Item> tempList = collections.items.toList();
              tempList.removeAt(collections.items.toList().indexOf(item));
              tempList.insert(newIndex, item);
              collections.items = tempList.toSet();
              collections.persistChanges();
            },
          ),
        ),
        Padding(padding: EdgeInsets.all(8.0)),
        NavBar(onAddPressed: onAddPressed, scaffoldKey: _scaffoldKey),
      ],
    );
  }
}
