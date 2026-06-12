import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'collections.dart';

class NewItem extends StatefulWidget {
  final Collections collections;

  const NewItem({super.key, required this.collections});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String _location = 'Home';
  String _status = 'WIP';
  final Map<String, Set<String>> _selectedTagValues = {};

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _saveItem() {
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

    final newItem = Item(
      DateTime.now().millisecondsSinceEpoch.toString(),
      name,
      price,
      _location,
      _status,
      selectedTags,
    );

    widget.collections.addItem(newItem);
    Navigator.of(context).pop(newItem);
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

class NewName extends StatelessWidget {
  final TextEditingController controller;

  const NewName({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(10),
      child: Material(
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}

class NewPrice extends StatelessWidget {
  final TextEditingController controller;

  const NewPrice({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(10),
      child: Material(
        child: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: false,
          ),
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          decoration: const InputDecoration(
            labelText: 'Price',
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}

class LocationChoice extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const LocationChoice({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: SegmentedButton<String>(
        segments: const <ButtonSegment<String>>[
          ButtonSegment<String>(value: 'Home', label: Text('Home')),
          ButtonSegment<String>(value: 'Etsy', label: Text('Etsy')),
          ButtonSegment<String>(
            value: 'General Store',
            label: Text('General Store'),
          ),
        ],
        selected: <String>{value},
        onSelectionChanged: (Set<String> newSelection) {
          onChanged(newSelection.first);
        },
      ),
    );
  }
}

class StatusChoice extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const StatusChoice({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: SegmentedButton<String>(
        segments: const <ButtonSegment<String>>[
          ButtonSegment<String>(value: 'WIP', label: Text('WIP')),
          ButtonSegment<String>(value: 'Listed', label: Text('Listed')),
          ButtonSegment<String>(value: 'Sold', label: Text('Sold')),
          ButtonSegment<String>(value: 'Returned', label: Text('Returned')),
        ],
        selected: <String>{value},
        onSelectionChanged: (Set<String> newSelection) {
          onChanged(newSelection.first);
        },
      ),
    );
  }
}

class NewItemHeader extends StatelessWidget {
  final VoidCallback onSave;

  const NewItemHeader({super.key, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        IconButton(onPressed: onSave, icon: const Icon(Icons.save)),
      ],
    );
  }
}

class TagSelectorRow extends StatelessWidget {
  final String tagName;
  final List<String> options;
  final Set<String> selectedValues;
  final ValueChanged<Set<String>> onSelectionChanged;

  const TagSelectorRow({
    super.key,
    required this.tagName,
    required this.options,
    required this.selectedValues,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tagName, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          SegmentedButton<String>(
            multiSelectionEnabled: true,
            emptySelectionAllowed: true,
            showSelectedIcon: true,
            selected: selectedValues,
            segments: options
                .map(
                  (option) =>
                      ButtonSegment<String>(value: option, label: Text(option)),
                )
                .toList(),
            onSelectionChanged: onSelectionChanged,
          ),
        ],
      ),
    );
  }
}
