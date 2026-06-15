import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'utilities/newitem.dart';
import 'utilities/collections.dart';
import 'utilities/itemwidgets.dart';

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
  Collections? _collections;

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

    setState(() {});
  }

  void _refreshItems() {
    if (!mounted) {
      return;
    }

    setState(() {});
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
        body: Center(
          child: Scroll(
            collections: _collections!,
            onAddPressed: _openNewItem,
            onItemsChanged: _refreshItems,
          ),
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
    Tag("3", "Occassion", {
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

  const NavBar({super.key, required this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(onPressed: null, icon: Icon(Icons.filter_alt_outlined)),
        IconButton(onPressed: onAddPressed, icon: Icon(Icons.add)),
        IconButton(onPressed: null, icon: Icon(Icons.menu)),
      ],
    );
  }
}

class Scroll extends StatelessWidget {
  final Collections collections;
  final VoidCallback onAddPressed;
  final VoidCallback onItemsChanged;

  const Scroll({
    super.key,
    required this.collections,
    required this.onAddPressed,
    required this.onItemsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("My Inventory"),
        Padding(padding: EdgeInsets.all(8.0)),
        Expanded(
          child: ReorderableListView.builder(
            buildDefaultDragHandles: false,
            itemCount: collections.items.length,
            itemBuilder: (context, index) {
              return Container(
                key: ValueKey(collections.items.elementAt(index)),
                child: ItemRow(
                  i: collections.items.elementAt(index),
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
              final item = collections.items.elementAt(oldIndex);
              List<Item> tempList = collections.items.toList();
              tempList.removeAt(oldIndex);
              tempList.insert(newIndex, item);
              collections.items = tempList.toSet();
              collections.persistChanges();
            },
          ),
        ),
        Padding(padding: EdgeInsets.all(8.0)),
        NavBar(onAddPressed: onAddPressed),
        Padding(padding: EdgeInsets.all(8)),
      ],
    );
  }
}
