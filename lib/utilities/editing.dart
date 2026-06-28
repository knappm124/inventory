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
  final TextEditingController _quantityController = TextEditingController();
  String? _location;
  String? _status;
  late String _imagePath;
  final Map<String, Set<String>> _selectedTagValues = {};

  @override
  void initState() {
    super.initState();
    // Initialize controllers and fields from the passed-in item
    _nameController.text = widget.i.name;
    _priceController.text = widget.i.price.toStringAsFixed(2);
    _quantityController.text = widget.i.quantity.toString();
    _location = widget.i.location;
    _status = widget.i.status;
    _imagePath = widget.i.img ?? '';

    // Copy existing tag selections from the item
    widget.i.tags?.forEach((tagName, values) {
      _selectedTagValues[tagName] = Set<String>.from(values);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _saveItem() {
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
    final quantityText = _quantityController.text.trim();

    final price = double.tryParse(priceText) ?? 0.00;
    final quantity = int.tryParse(quantityText) ?? 1;
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
      quantity,
      _location,
      _status,
      _imagePath,
      selectedTags,
    );

    widget.collections.editItem(updatedItem);

    if (!mounted) return;
    Navigator.of(context).pop(updatedItem);
  }

  @override
  Widget build(BuildContext context) {
    final locationOptions = widget.collections.getAllLocations().toList()
      ..sort();
    if (_location != null && !locationOptions.contains(_location)) {
      locationOptions.insert(0, _location!);
    }

    final statusOptions = widget.collections.getAllStatuses().toList()..sort();
    if (_status != null && !statusOptions.contains(_status)) {
      statusOptions.insert(0, _status!);
    }

    final sortedTags = widget.collections.tags.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    final tagRows = sortedTags.map((tag) {
      return TagSelectorRow(
        tagName: tag.name,
        options: (tag.options?.toList() ?? [])..sort(),
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
                    NewQuantity(
                      controller: _quantityController,
                      validator: (value) {
                        final trimmed = value?.trim() ?? '';
                        if (trimmed.isEmpty) {
                          return 'Quantity is required.';
                        }
                        final parsed = int.tryParse(trimmed);
                        if (parsed == null || parsed <= 0) {
                          return 'Enter a valid positive integer.';
                        }
                        return null;
                      },
                    ),
                    if (locationOptions.isNotEmpty)
                      LocationChoice(
                        options: locationOptions,
                        value: _location ?? locationOptions.first,
                        onChanged: (value) => setState(() => _location = value),
                      ),
                    if (statusOptions.isNotEmpty)
                      StatusChoice(
                        options: statusOptions,
                        value: _status ?? statusOptions.first,
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
