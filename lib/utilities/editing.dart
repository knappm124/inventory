import 'package:flutter/material.dart';
import 'package:inventory/utilities/newitem.dart';

import 'collections.dart';

class EditingItem extends StatefulWidget {
  final Item i;
  final Collections collections;

  const EditingItem({super.key, required this.i, required this.collections});

  @override
  State<StatefulWidget> createState() => _EditingItemState();
}

class _EditingItemState extends State<EditingItem> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  late String _location;
  late String _status;
  late String _imagePath;
  final Map<String, Set<String>> _selectedTagValues = {};

  @override
  void initState() {
    super.initState();
    // Initialize controllers and fields from the passed-in item
    _nameController.text = widget.i.name;
    _priceController.text = widget.i.price.toString();
    _location = widget.i.location;
    _status = widget.i.status;
    _imagePath = widget.i.img;

    // Copy existing tag selections from the item
    widget.i.tags.forEach((tagName, values) {
      _selectedTagValues[tagName] = Set<String>.from(values);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    if (!mounted) {
      return;
    }

    final name = _nameController.text.trim();
    final priceText = _priceController.text.trim();
    if (name.isEmpty || priceText.isEmpty) {
      return;
    }

    final price = double.tryParse(priceText) ?? 0.0;
    final selectedTags = <String, Set<String>>{};
    _selectedTagValues.forEach((tagName, values) {
      if (values.isNotEmpty) {
        selectedTags[tagName] = values;
      }
    });

    final updatedItem = Item(
      widget.i.id,
      name,
      price,
      _location,
      _status,
      _imagePath,
      selectedTags,
    );

    widget.collections.editItem(updatedItem);

    // Ensure collections are saved to disk before closing
    await widget.collections.saveToDisk();

    if (!mounted) return;
    Navigator.of(context).pop(updatedItem);
  }

  @override
  Widget build(BuildContext context) {
    final tagRows = widget.collections.tags.map((tag) {
      return TagSelectorRow(
        tagName: tag.name,
        options: tag.options.toList(),
        selectedValues: _selectedTagValues[tag.name] ?? <String>{},
        onSelectionChanged: (newSelection) {
          setState(() {
            _selectedTagValues[tag.name] = newSelection;
          });
        },
      );
    }).toList();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NewItemHeader(onSave: _saveItem),
            NewName(controller: _nameController),
            ImageUploaderScreen(
              initialImagePath: _imagePath,
              onImageSelected: (imagePath) {
                setState(() {
                  _imagePath = imagePath;
                });
              },
            ),
            NewPrice(controller: _priceController),
            LocationChoice(
              value: _location,
              onChanged: (value) => setState(() => _location = value),
            ),
            StatusChoice(
              value: _status,
              onChanged: (value) => setState(() => _status = value),
            ),
            ...tagRows,
          ],
        ),
      ),
    );
  }
}
