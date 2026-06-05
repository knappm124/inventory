import 'package:flutter/material.dart';
import 'collections.dart';

class ItemIcons extends StatelessWidget {
  const ItemIcons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(onPressed: null, icon: Icon(Icons.edit)),
        IconButton(onPressed: null, icon: Icon(Icons.clear)),
      ],
    );
  }
}

class ItemHeader extends StatelessWidget {
  final String name;
  final int index;

  const ItemHeader({super.key, required this.name, required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(name),
        ReorderableDragStartListener(
          index: index,
          child: Icon(Icons.reorder)),
      ],
    );
  }
}

class ItemRow extends StatelessWidget {
  final Item i;
  final int index;

  const ItemRow({super.key, required this.i, required this.index});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1.0),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EditableItem(i: i)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ItemHeader(name: i.name, index: index),
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
      ),
    );
  }
}

class EditableItem extends StatelessWidget {
  final Item i;

  const EditableItem({super.key, required this.i});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DefaultTextStyle(
          style: TextStyle(color: Colors.black, fontSize: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EditableItemHeader(),
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
      ),
    );
  }
}

class EditableItemHeader extends StatelessWidget {
  const EditableItemHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back),
        ),
        ItemIcons(),
      ],
    );
  }
}
