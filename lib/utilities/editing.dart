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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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
    _priceController.text = widget.i.price.toStringAsFixed(2);
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

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the highlighted fields.')),
      );
      return;
    }

    final name = _nameController.text.trim();
    final priceText = _priceController.text.trim();

    final price = double.tryParse(priceText) ?? 0.00;
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
        options: tag.options!.toList(),
        selectedValues: _selectedTagValues[tag.name] ?? <String>{},
        onSelectionChanged: (newSelection) {
          setState(() {
            _selectedTagValues[tag.name] = newSelection;
          });
        },
      );
    }).toList();

    return Scaffold(
      body: Column(
        children: [
          Padding(padding: EdgeInsets.all(10)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
              ),
              IconButton(onPressed: _saveItem, icon: const Icon(Icons.save)),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NewName(
                      controller: _nameController,
                      validator: (value) {
                        final trimmed = value?.trim() ?? '';
                        if (trimmed.isEmpty) {
                          return 'Name is required.';
                        }
                        return null;
                      },
                    ),
                    ImageUploaderScreen(
                      initialImagePath: _imagePath,
                      onImageSelected: (imagePath) {
                        setState(() {
                          _imagePath = imagePath;
                        });
                      },
                    ),
                    NewPrice(
                      controller: _priceController,
                      validator: (value) {
                        final trimmed = value?.trim() ?? '';
                        if (trimmed.isEmpty) {
                          return 'Price is required.';
                        }
                        final parsed = double.tryParse(trimmed);
                        if (parsed == null) {
                          return 'Enter a valid number.';
                        }
                        if (parsed < 0) {
                          return 'Price cannot be negative.';
                        }
                        return null;
                      },
                    ),
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
            ),
          ),
        ],
      ),
    );
  }
}
