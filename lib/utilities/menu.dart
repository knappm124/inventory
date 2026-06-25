import 'package:flutter/material.dart';
import './collections.dart';

class MenuItem extends StatefulWidget {
  final Collections c;
  final String name;

  const MenuItem({super.key, required this.c, required this.name});

  @override
  State<MenuItem> createState() {
    return _MenuItemState();
  }
}

class _MenuItemState extends State<MenuItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TagEditor(tagName: widget.name, c: widget.c),
        ),
      ),
      child: Text(widget.name),
    );
  }
}

class TagEditor extends StatelessWidget {
  final String tagName;
  final Collections c;

  const TagEditor({super.key, required this.tagName, required this.c});

  VoidCallback? get onPressed => null;

  @override
  Widget build(BuildContext context) {
    switch (tagName) {
      case "Locations":
        return DefaultTextStyle(
          style: TextStyle(color: Colors.black, fontSize: 16.0),
          child: Column(
            children: [
              Text("Locations"),
              for (String s in c.getAllLocations())
                SizedBox(
                  width: 400,
                  child: Row(
                    children: [
                      Text(s),
                      IconButton(
                        onPressed: () => {c.removeLocation(s)},
                        icon: Icon(Icons.delete),
                      ),
                    ],
                  ),
                ),
              ElevatedButton(onPressed: onPressed, child: Text("Add Location")),
            ],
          ),
        );
      case "Status":
      case "Tags":
        return Column(
          children: [
            Text(tagName),
            for (Tag t in c.getAllTags())
              Column(
                children: [
                  Text(t.getName()),
                  for (String s in t.getOptions()) Column(children: [Text(s)]),
                ],
              ),
            TextField(),
            ElevatedButton(onPressed: () => {}, child: Text("Add")),
          ],
        );
    }
    return Column(
      children: [
        Text(tagName),
        for (Tag t in c.getAllTags())
          Column(
            children: [
              Text(t.getName()),
              for (String s in t.getOptions()) Column(children: [Text(s)]),
            ],
          ),
        TextField(),
        ElevatedButton(onPressed: () => {}, child: Text("Add")),
      ],
    );
  }
}

class Menu extends StatelessWidget {
  final Collections c;

  const Menu({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_sharp),
          ),
          MenuItem(c: c, name: "Locations"),
          MenuItem(c: c, name: "Status"),
          MenuItem(c: c, name: "Tags"),
        ],
      ),
    );
  }
}
