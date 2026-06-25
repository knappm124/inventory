import 'dart:io';

import 'package:flutter/material.dart';
import 'package:inventory/utilities/editing.dart';
import 'collections.dart';

class ItemIcons extends StatelessWidget {
  final Item i;
  final Collections collections;
  final ValueChanged<Item> onItemUpdated;

  const ItemIcons({
    super.key,
    required this.i,
    required this.collections,
    required this.onItemUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () async {
            final updatedItem = await Navigator.of(context).push<Item?>(
              MaterialPageRoute(
                builder: (context) =>
                    EditingItem(i: i, collections: collections),
              ),
            );
            if (updatedItem != null) {
              onItemUpdated(updatedItem);
            }
          },
          icon: Icon(Icons.edit),
        ),
        IconButton(
          onPressed: () async {
            final navigator = Navigator.of(context);
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Delete item?'),
                  content: Text('Delete "${i.name}" from your inventory?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Delete'),
                    ),
                  ],
                );
              },
            );

            if (confirmed != true) {
              return;
            }

            collections.removeItem(i);
            await collections.saveToDisk();
            navigator.pop(true);
          },
          icon: Icon(Icons.delete),
        ),
      ],
    );
  }
}

class ItemRow extends StatelessWidget {
  final Item i;
  final int index;
  final Collections collections;
  final VoidCallback onChanged;

  const ItemRow({
    super.key,
    required this.i,
    required this.index,
    required this.collections,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1.0),
      ),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => EditableItem(
                i: i,
                collections: collections,
                onItemsChanged: onChanged,
              ),
            ),
          );
          if (result == true) {
            onChanged();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Image.file(
                File(i.img),
                width: 100,
                height: 100,
                fit: BoxFit.contain,
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("Name: ${i.name}"),
                    Text("Price: ${i.price.toStringAsFixed(2)}"),
                    Text("Location: ${i.location}"),
                    Text("Status: ${i.status}"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditableItem extends StatefulWidget {
  final Item i;
  final Collections collections;
  final VoidCallback onItemsChanged;

  const EditableItem({
    super.key,
    required this.i,
    required this.collections,
    required this.onItemsChanged,
  });

  @override
  State<EditableItem> createState() => _EditableItemState();
}

class _EditableItemState extends State<EditableItem> {
  late Item _item;

  @override
  void initState() {
    super.initState();
    _item = widget.i;
  }

  void _handleItemUpdated(Item updatedItem) {
    setState(() {
      _item = updatedItem;
    });
    widget.onItemsChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_item.name)),
      body: SingleChildScrollView(
        child: DefaultTextStyle(
          style: TextStyle(color: Colors.black, fontSize: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 400,
                  height: 250,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.file(
                        File(_item.img),
                        width: 250,
                        height: 250,
                        fit: BoxFit.contain,
                      ),
                      EditableItemHeader(
                        i: _item,
                        collections: widget.collections,
                        onItemUpdated: _handleItemUpdated,
                      ),
                    ],
                  ),
                ),
                Text("Price: ${_item.price.toStringAsFixed(2)}"),
                Text("Location: ${_item.location}"),
                Text("Status: ${_item.status}"),
                for (String s in _item.tags.keys)
                  Row(
                    children: [
                      Text("$s: "),
                      for (String o in _item.tags[s]!) Text("$o "),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EditableItemHeader extends StatelessWidget {
  final Item i;
  final Collections collections;
  final ValueChanged<Item> onItemUpdated;

  const EditableItemHeader({
    super.key,
    required this.i,
    required this.collections,
    required this.onItemUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 400,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ItemIcons(
            i: i,
            collections: collections,
            onItemUpdated: onItemUpdated,
          ),
        ],
      ),
    );
  }
}
