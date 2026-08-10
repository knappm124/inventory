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
  final TextEditingController _quantityController = TextEditingController();
  late String? _location;
  late String? _status;
  List<String> _imagePaths = <String>[];
  final Map<String, Set<String>> _selectedTagValues = {};

  EdgeInsets _contentPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return EdgeInsets.fromLTRB(
      16,
      16,
      16,
      16 + mediaQuery.padding.bottom + mediaQuery.viewInsets.bottom,
    );
  }

  @override
  void initState() {
    super.initState();
    final locationOptions = widget.collections.getAllLocations().toList();
    final statusOptions = widget.collections.getAllStatuses().toList();

    _location = locationOptions.isNotEmpty ? locationOptions.first : null;
    _status = statusOptions.isNotEmpty ? statusOptions.first : null;
  }

  List<String> _locationOptions() {
    final options = widget.collections.getAllLocations().toList()..sort();
    final currentLocation = _location;
    if (currentLocation != null && !options.contains(currentLocation)) {
      options.insert(0, currentLocation);
    }
    return options;
  }

  List<String> _statusOptions() {
    final options = widget.collections.getAllStatuses().toList()..sort();
    final currentStatus = _status;
    if (currentStatus != null && !options.contains(currentStatus)) {
      options.insert(0, currentStatus);
    }
    return options;
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
    final quantity = int.tryParse(_quantityController.text.trim()) ?? 1;
    final selectedLocation = (_location?.trim().isNotEmpty ?? false)
        ? _location
        : null;
    final selectedStatus = (_status?.trim().isNotEmpty ?? false)
        ? _status
        : null;
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
      quantity,
      selectedLocation,
      selectedStatus,
      _imagePaths.isEmpty ? null : _imagePaths.first,
      _imagePaths,
      selectedTags,
    );

    widget.collections.addItem(newItem);
    Navigator.of(context).pop(newItem);
  }

  @override
  Widget build(BuildContext context) {
    final locationOptions = _locationOptions();
    final statusOptions = _statusOptions();
    final theme = Theme.of(context);
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
      appBar: AppBar(
        title: const Text('Add Item'),
        actions: [
          IconButton(
            onPressed: _saveItem,
            tooltip: 'Save item',
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            icon: const Icon(Icons.check),
          ),
          const SizedBox(width: 4),
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: _contentPadding(context),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Form(
                key: _formKey,
                child: FocusTraversalGroup(
                  policy: OrderedTraversalPolicy(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EditorHeroCard(
                        title: 'Create a new inventory item',
                        subtitle:
                            'Capture the essentials, attach photos, and organize the item so it is easy to find later.',
                        trailing: EditorSummaryPill(
                          icon: Icons.add_box_outlined,
                          label: _imagePaths.isEmpty
                              ? 'Ready for details'
                              : '${_imagePaths.length} photos selected',
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 18),
                          child: ImageUploaderScreen(
                            initialImagePaths: _imagePaths,
                            onImagesChanged: (imagePaths) {
                              setState(() {
                                _imagePaths = List<String>.from(imagePaths);
                              });
                            },
                            useStandaloneChrome: false,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      EditorFormSurface(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            EditorSectionBlock(
                              title: 'Basic Info',
                              subtitle:
                                  'Name it clearly and set the current price and quantity.',
                              child: Column(
                                children: [
                                  FocusTraversalOrder(
                                    order: const NumericFocusOrder(1),
                                    child: NewName(
                                      controller: _nameController,
                                      validator: (value) {
                                        final trimmed = value?.trim() ?? '';
                                        if (trimmed.isEmpty) {
                                          return 'Name is required.';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  FocusTraversalOrder(
                                    order: const NumericFocusOrder(2),
                                    child: NewPrice(
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
                                  ),
                                  FocusTraversalOrder(
                                    order: const NumericFocusOrder(3),
                                    child: NewQuantity(
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
                                  ),
                                ],
                              ),
                            ),
                            if (locationOptions.isNotEmpty) ...[
                              const Divider(height: 28),
                              EditorSectionBlock(
                                title: 'Location',
                                subtitle:
                                    'Place the item where you expect to find it.',
                                child: FocusTraversalOrder(
                                  order: const NumericFocusOrder(4),
                                  child: LocationChoice(
                                    options: locationOptions,
                                    value: _location ?? locationOptions.first,
                                    onChanged: (value) =>
                                        setState(() => _location = value),
                                  ),
                                ),
                              ),
                            ],
                            if (statusOptions.isNotEmpty) ...[
                              const Divider(height: 28),
                              EditorSectionBlock(
                                title: 'Status',
                                subtitle:
                                    'Mark whether the item is active, stored, or needs attention.',
                                child: FocusTraversalOrder(
                                  order: const NumericFocusOrder(5),
                                  child: StatusChoice(
                                    options: statusOptions,
                                    value: _status ?? statusOptions.first,
                                    onChanged: (value) =>
                                        setState(() => _status = value),
                                  ),
                                ),
                              ),
                            ],
                            if (tagRows.isNotEmpty) ...[
                              const Divider(height: 28),
                              EditorSectionBlock(
                                title: 'Tags',
                                subtitle:
                                    'Use tags to make filtering and grouping easier later.',
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: tagRows,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _saveItem,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Save Item'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          textStyle: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: TextFormField(
        controller: controller,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: const InputDecoration(
          labelText: 'Name',
          hintText: 'Desk lamp, camera, drill set...',
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          prefixText: '\$',
          hintText: '0.00',
        ),
      ),
    );
  }
}

class NewQuantity extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const NewQuantity({super.key, required this.controller, this.validator});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: TextFormField(
        controller: controller,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: false,
        ),
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'^[1-9]\d*$')),
        ],
        decoration: const InputDecoration(labelText: 'Quantity', hintText: '1'),
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: Semantics(
        container: true,
        label: 'Item location',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Location', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((option) {
                return ChoiceChip(
                  label: Text(option),
                  selected: option == safeValue,
                  onSelected: (_) => onChanged(option),
                );
              }).toList(),
            ),
          ],
        ),
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: Semantics(
        container: true,
        label: 'Item status',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((option) {
                return ChoiceChip(
                  label: Text(option),
                  selected: option == safeValue,
                  onSelected: (_) => onChanged(option),
                );
              }).toList(),
            ),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tagName, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
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
  final List<String> initialImagePaths;
  final ValueChanged<List<String>> onImagesChanged;
  final bool useStandaloneChrome;

  const ImageUploaderScreen({
    super.key,
    required this.initialImagePaths,
    required this.onImagesChanged,
    this.useStandaloneChrome = true,
  });

  @override
  State<ImageUploaderScreen> createState() => _ImageUploaderScreenState();
}

class _ImageUploaderScreenState extends State<ImageUploaderScreen> {
  final List<Uint8List?> _previewBytes = <Uint8List?>[];
  List<String> _imagePaths = <String>[];
  final ImagePicker _picker = ImagePicker();

  void _removeImageAt(int index) {
    if (index < 0 || index >= _imagePaths.length) {
      return;
    }

    setState(() {
      _imagePaths.removeAt(index);
      _previewBytes.removeAt(index);
    });

    widget.onImagesChanged(List<String>.from(_imagePaths));
  }

  void _setPrimaryImage(int index) {
    if (index <= 0 || index >= _imagePaths.length) {
      return;
    }

    setState(() {
      final path = _imagePaths.removeAt(index);
      final preview = _previewBytes.removeAt(index);
      _imagePaths.insert(0, path);
      _previewBytes.insert(0, preview);
    });

    widget.onImagesChanged(List<String>.from(_imagePaths));
  }

  @override
  void initState() {
    super.initState();
    unawaited(_syncImages(widget.initialImagePaths));
  }

  @override
  void didUpdateWidget(covariant ImageUploaderScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_sameImages(oldWidget.initialImagePaths, widget.initialImagePaths)) {
      unawaited(_syncImages(widget.initialImagePaths));
    }
  }

  bool _sameImages(List<String> left, List<String> right) {
    if (left.length != right.length) {
      return false;
    }

    for (var index = 0; index < left.length; index++) {
      if (left[index] != right[index]) {
        return false;
      }
    }

    return true;
  }

  Future<void> _syncImages(List<String> imagePaths) async {
    final normalized = imagePaths
        .map((path) => path.trim())
        .where((path) => path.isNotEmpty)
        .toList();
    final bytes = await Future.wait(normalized.map(_loadPreviewBytes));

    if (!mounted) {
      return;
    }

    setState(() {
      _imagePaths = normalized;
      _previewBytes
        ..clear()
        ..addAll(bytes);
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
      final pickedFiles = await _picker.pickMultiImage(imageQuality: 85);

      if (pickedFiles.isEmpty) {
        return;
      }

      final newPaths = <String>[];
      final newPreviewBytes = <Uint8List?>[];

      for (final pickedFile in pickedFiles) {
        final imageBytes = await pickedFile.readAsBytes();
        if (imageBytes.isEmpty) {
          continue;
        }

        final encodedImage = encodeImageToDataUri(
          imageBytes,
          mimeType: pickedFile.mimeType,
          path: pickedFile.path,
        );

        if (_imagePaths.contains(encodedImage) ||
            newPaths.contains(encodedImage)) {
          continue;
        }

        newPaths.add(encodedImage);
        newPreviewBytes.add(imageBytes);
      }

      if (newPaths.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No new images were added.')),
          );
        }
        return;
      }

      final updatedPaths = List<String>.from(_imagePaths)..addAll(newPaths);
      widget.onImagesChanged(updatedPaths);

      if (!mounted) {
        return;
      }

      setState(() {
        _imagePaths = updatedPaths;
        _previewBytes.addAll(newPreviewBytes);
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasImages = _imagePaths.isNotEmpty;
    final primaryPreview = _previewBytes.isNotEmpty
        ? _previewBytes.first
        : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final previewSize = (constraints.maxWidth - 48)
            .clamp(180, 320)
            .toDouble();

        return Padding(
          padding: EdgeInsets.all(widget.useStandaloneChrome ? 4 : 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: widget.useStandaloneChrome
                      ? LinearGradient(
                          colors: [
                            colorScheme.primaryContainer.withValues(alpha: 0.5),
                            colorScheme.surfaceContainerHigh,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                ),
                child: Column(
                  children: [
                    Container(
                      width: previewSize,
                      height: previewSize,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: primaryPreview != null && primaryPreview.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(21),
                              child: Image.memory(
                                primaryPreview,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              Icons.image_outlined,
                              size: 72,
                              color: colorScheme.outline,
                            ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _pickAndSaveImage,
                      icon: const Icon(Icons.upload_file),
                      label: Text(hasImages ? 'Add Images' : 'Upload Images'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  widget.useStandaloneChrome ? 4 : 0,
                  14,
                  widget.useStandaloneChrome ? 4 : 0,
                  0,
                ),
                child: Text(
                  hasImages
                      ? 'Choose the main image with the star, or remove photos you no longer need.'
                      : 'Add a few images to make the item easier to recognize later.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              if (hasImages) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: List.generate(_imagePaths.length, (index) {
                    final preview = _previewBytes[index];
                    return SizedBox(
                      width: 120,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: index == 0
                                        ? colorScheme.primary
                                        : colorScheme.outlineVariant,
                                    width: index == 0 ? 2 : 1,
                                  ),
                                ),
                                child: preview != null && preview.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(11),
                                        child: Image.memory(
                                          preview,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Icon(
                                        Icons.image_outlined,
                                        color: colorScheme.outline,
                                      ),
                              ),
                              Positioned(
                                top: 4,
                                left: 4,
                                child: IconButton.filledTonal(
                                  onPressed: index == 0
                                      ? null
                                      : () => _setPrimaryImage(index),
                                  icon: Icon(
                                    index == 0 ? Icons.star : Icons.star_border,
                                  ),
                                  tooltip: index == 0
                                      ? 'Primary image'
                                      : 'Set as primary image',
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: IconButton.filledTonal(
                                  onPressed: () => _removeImageAt(index),
                                  icon: const Icon(Icons.delete_outline),
                                  tooltip: 'Remove image',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            index == 0 ? 'Primary' : 'Image ${index + 1}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class EditorHeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;
  final Widget? child;

  const EditorHeroCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.95),
            colorScheme.surfaceContainerHigh,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.85),
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 16,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          ...[trailing, child].nonNulls,
        ],
      ),
    );
  }
}

class EditorFormSurface extends StatelessWidget {
  final Widget child;

  const EditorFormSurface({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class EditorSectionBlock extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const EditorSectionBlock({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ],
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class EditorSummaryPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const EditorSummaryPill({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(label, style: theme.textTheme.labelLarge),
        ],
      ),
    );
  }
}
