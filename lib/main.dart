import 'package:flutter/material.dart';
import 'utilities/collections.dart';

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

class ItemRow extends StatelessWidget {
  final Item i;

  const ItemRow({super.key, required this.i});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${i.name}"),
            Text("Price: ${i.price.toString()}"),
            Text("Location: ${i.location}"),
            Text("Status: ${i.status}"),
            for (String s in i.tags.keys)
              Row(
                children: [
                  Text("$s: "),
                  for (String o in i.tags[s]!) Text(o + " "),
                ],
              ),
          ],
        ),
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
        IconButton(onPressed: null, icon: Icon(Icons.add)),
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
          child: ListView.separated(
            itemCount: collections.items.length,
            itemBuilder: (context, index) {
              return ItemRow(i: collections.items.elementAt(index));
            },
            separatorBuilder: (context, index) {
              return Padding(padding: EdgeInsets.all(8.0));
            },
          ),
        ),
        Padding(padding: EdgeInsets.all(8.0)),
        NavBar(),
      ],
    );
  }
}
