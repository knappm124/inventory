import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'collections.dart';
import 'image_utils.dart';

class NewItem extends StatefulWidget {
  final Collections collections;

  const NewItem({super.key, required this.collections});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  late String _location;
  late String _status;
  String _imagePath = '';
  final Map<String, Set<String>> _selectedTagValues = {};

  @override
  void initState() {
    super.initState();
    final locationOptions = widget.collections.getAllLocations().toList();
    final statusOptions = widget.collections.getAllStatuses().toList();

    _location = locationOptions.contains('Home')
        ? 'Home'
        : (locationOptions.isNotEmpty ? locationOptions.first : 'Home');
    _status = statusOptions.contains('WIP')
        ? 'WIP'
        : (statusOptions.isNotEmpty ? statusOptions.first : 'WIP');
  }

  List<String> _locationOptions() {
    final options = widget.collections.getAllLocations().toList()..sort();
    if (!options.contains(_location)) {
      options.insert(0, _location);
    }
    return options;
  }

  List<String> _statusOptions() {
    final options = widget.collections.getAllStatuses().toList()..sort();
    if (!options.contains(_status)) {
      options.insert(0, _status);
    }
    return options;
  }

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
      _formKey.currentState?.validate();
      final message = name.isEmpty && priceText.isEmpty
          ? 'Name and price are required.'
          : name.isEmpty
          ? 'Name is required.'
          : 'Price is required.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the highlighted fields.')),
      );
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
      _imagePath,
      selectedTags,
    );

    widget.collections.addItem(newItem);
    Navigator.of(context).pop(newItem);
  }

  @override
  Widget build(BuildContext context) {
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
                    LocationChoice(
                      options: _locationOptions(),
                      value: _location,
                      onChanged: (value) => setState(() => _location = value),
                    ),
                    StatusChoice(
                      options: _statusOptions(),
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

class NewName extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const NewName({super.key, required this.controller, this.validator});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(10),
      child: Material(
        child: TextFormField(
          controller: controller,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
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
  final String? Function(String?)? validator;

  const NewPrice({super.key, required this.controller, this.validator});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(10),
      child: Material(
        child: TextFormField(
          controller: controller,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: false,
          ),
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
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
  final List<String> options;
  final String value;
  final ValueChanged<String> onChanged;

  const LocationChoice({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final safeValue = options.contains(value)
        ? value
        : (options.isNotEmpty ? options.first : value);

    return Container(
      padding: const EdgeInsets.all(10),
      child: SegmentedButton<String>(
        showSelectedIcon: false,
        segments: options
            .map(
              (option) =>
                  ButtonSegment<String>(value: option, label: Text(option)),
            )
            .toList(),
        selected: <String>{safeValue},
        onSelectionChanged: (Set<String> newSelection) {
          onChanged(newSelection.first);
        },
      ),
    );
  }
}

class StatusChoice extends StatelessWidget {
  final List<String> options;
  final String value;
  final ValueChanged<String> onChanged;

  const StatusChoice({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final safeValue = options.contains(value)
        ? value
        : (options.isNotEmpty ? options.first : value);

    return Container(
      padding: const EdgeInsets.all(10),
      child: SegmentedButton<String>(
        showSelectedIcon: false,
        segments: options
            .map(
              (option) =>
                  ButtonSegment<String>(value: option, label: Text(option)),
            )
            .toList(),
        selected: <String>{safeValue},
        onSelectionChanged: (Set<String> newSelection) {
          onChanged(newSelection.first);
        },
      ),
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final isSelected = selectedValues.contains(option);
              return ChoiceChip(
                label: Text(option),
                selected: isSelected,
                onSelected: (selected) {
                  final updatedSelection = Set<String>.from(selectedValues);
                  if (selected) {
                    updatedSelection.add(option);
                  } else {
                    updatedSelection.remove(option);
                  }
                  onSelectionChanged(updatedSelection);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class ImageUploaderScreen extends StatefulWidget {
  final String initialImagePath;
  final ValueChanged<String> onImageSelected;

  const ImageUploaderScreen({
    super.key,
    required this.initialImagePath,
    required this.onImageSelected,
  });

  @override
  State<ImageUploaderScreen> createState() => _ImageUploaderScreenState();
}

class _ImageUploaderScreenState extends State<ImageUploaderScreen> {
  Uint8List? _savedImageBytes;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    unawaited(_syncImage(widget.initialImagePath));
  }

  @override
  void didUpdateWidget(covariant ImageUploaderScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialImagePath != widget.initialImagePath) {
      unawaited(_syncImage(widget.initialImagePath));
    }
  }

  Future<void> _syncImage(String imagePath) async {
    final bytes = await _loadPreviewBytes(imagePath);
    if (!mounted) {
      return;
    }

    setState(() {
      _savedImageBytes = bytes;
    });
  }

  Future<Uint8List?> _loadPreviewBytes(String imagePath) async {
    if (imagePath.isEmpty) {
      return null;
    }

    final dataUriBytes = decodeImageFromDataUri(imagePath);
    if (dataUriBytes != null && dataUriBytes.isNotEmpty) {
      return dataUriBytes;
    }

    try {
      final bytes = await XFile(imagePath).readAsBytes();
      if (bytes.isEmpty) {
        return null;
      }
      return bytes;
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickAndSaveImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        return;
      }

      final imageBytes = await pickedFile.readAsBytes();
      if (imageBytes.isEmpty) {
        throw Exception('Selected image is empty.');
      }

      final encodedImage = encodeImageToDataUri(
        imageBytes,
        mimeType: pickedFile.mimeType,
        path: pickedFile.path,
      );

      widget.onImageSelected(encodedImage);

      if (!mounted) {
        return;
      }

      setState(() {
        _savedImageBytes = imageBytes;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving image: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[400]!),
            ),
            child: _savedImageBytes != null && _savedImageBytes!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.memory(_savedImageBytes!, fit: BoxFit.cover),
                  )
                : const Icon(
                    Icons.image_not_supported,
                    size: 80,
                    color: Colors.grey,
                  ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _pickAndSaveImage,
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload Image'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
