import 'package:flutter/material.dart';
import 'utilities/newitem.dart';
import 'utilities/collections.dart';
import 'utilities/itemwidgets.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  final Collections collections;

  MainApp({super.key})
    : collections = Collections(
        {
          Item("1", "Bird Egg", 20, "Etsy", "WIP", {
            "Color": {"red", "blue"},
            "Size": {"chicken"},
          }),
          Item("2", "Star Egg", 20, "Etsy", "Listed", {
            "Color": {"yellow", "red"},
            "Symbols": {"star"},
          }),
          Item("3", "Deer Egg", 20, "Etsy", "Sold", {
            "Season": {"fall"},
            "Size": {"quail"},
          }),
          Item("4", "Cross Egg", 20, "Etsy", "Returned", {
            "Color": {"green", "blue"},
            "Season": {"easter"},
            "Symbols": {"cross"},
          }),
        },
        {
          Tag("1", "Color", {
            "red",
            "orange",
            "yellow",
            "green",
            "blue",
            "purple",
          }),
          Tag("2", "Size", {"quail", "chicken", "duck", "goose", "ostrich"}),
          Tag("3", "Season", {"Easter", "Christmas", "Fall", "Spring"}),
          Tag("4", "Symbols", {"star", "deer", "chicken", "flower", "cross"}),
          Tag("5", "Division", {"star", "band", "triangles", "diagonal"}),
        },
        {"Etsy", "Home", "General Store"},
        {"WIP", "Sold", "Listed", "Returned"},
      );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: Scroll(collections: collections)),
      ),
    );
  }
}

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, 
      children: [
        IconButton(onPressed: null, icon: Icon(Icons.filter_alt_outlined)),
        IconButton(onPressed: ()=>{
          Navigator.push(context,
          MaterialPageRoute(builder: (context) => const NewItem()))
        }, icon: Icon(Icons.add)),
        IconButton(onPressed: null, icon: Icon(Icons.menu)),
      ],
    );
  }
}

class Scroll extends StatelessWidget {
  final Collections collections;

  const Scroll({super.key, required this.collections});

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
                 child: ItemRow(i: collections.items.elementAt(index), index: index)
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
            },
          ),
        ),
        Padding(padding: EdgeInsets.all(8.0)),
        NavBar(),
      ],
    );
  }
}
