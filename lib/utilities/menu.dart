import 'package:flutter/material.dart';
import './collections.dart';
import './edittag.dart';
import './pdf.dart';

class MenuItem extends StatelessWidget {
  final Collections c;
  final List<Item>? filteredItems;
  final String name;

  const MenuItem({
    super.key,
    required this.c,
    required this.filteredItems,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      minVerticalPadding: 12,
      title: Text(name),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              Editor(tagName: name, c: c, filteredItems: filteredItems),
        ),
      ),
    );
  }
}

class Editor extends StatefulWidget {
  final String tagName;
  final Collections c;
  final List<Item>? filteredItems;

  String? validator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a name';
    }
    return null;
  }

  const Editor({
    super.key,
    required this.tagName,
    required this.c,
    required this.filteredItems,
  });

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  final TextEditingController controller = TextEditingController();
  String name = "";

  EdgeInsets _listContentPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return EdgeInsets.fromLTRB(
      12,
      12,
      12,
      12 + mediaQuery.padding.bottom + mediaQuery.viewInsets.bottom,
    );
  }

  String _formatRemovalError(Object error) {
    final raw = error.toString();
    const exceptionPrefix = 'Exception: ';
    if (raw.startsWith(exceptionPrefix)) {
      return raw.substring(exceptionPrefix.length);
    }
    return raw;
  }

  void _showRemovalError(Object error) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(_formatRemovalError(error))));
  }

  Future<String?> _promptRename({
    required String title,
    required String label,
    required String initialValue,
  }) async {
    final textController = TextEditingController(text: initialValue);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: textController,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              Navigator.of(dialogContext).pop(textController.text.trim());
            },
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(textController.text.trim());
              },
              child: const Text('Rename'),
            ),
          ],
        );
      },
    );
    textController.dispose();
    return result;
  }

  void _removeLocation(String location) {
    try {
      setState(() {
        widget.c.removeLocation(location);
      });
    } catch (error) {
      _showRemovalError(error);
    }
  }

  void _removeStatus(String status) {
    try {
      setState(() {
        widget.c.removeStatus(status);
      });
    } catch (error) {
      _showRemovalError(error);
    }
  }

  void _removeTag(String tagName) {
    try {
      setState(() {
        widget.c.removeTag(tagName);
      });
    } catch (error) {
      _showRemovalError(error);
    }
  }

  void _submitLocation(String value) {
    final input = value.trim();
    if (input.isNotEmpty) {
      setState(() {
        widget.c.addLocation(input);
      });
    }
  }

  void _submitStatus(String value) {
    final input = value.trim();
    if (input.isNotEmpty) {
      setState(() {
        widget.c.addStatus(input);
      });
    }
  }

  Future<void> _renameLocation(String location) async {
    final renamed = await _promptRename(
      title: 'Rename Location',
      label: 'Location name',
      initialValue: location,
    );

    if (!mounted || renamed == null) {
      return;
    }

    final trimmed = renamed.trim();
    if (trimmed.isEmpty || trimmed == location) {
      return;
    }

    try {
      setState(() {
        widget.c.renameLocation(location, trimmed);
      });
    } catch (error) {
      _showRemovalError(error);
    }
  }

  Future<void> _renameStatus(String currentStatus) async {
    final renamed = await _promptRename(
      title: 'Rename Status',
      label: 'Status name',
      initialValue: currentStatus,
    );

    if (!mounted || renamed == null) {
      return;
    }

    final trimmed = renamed.trim();
    if (trimmed.isEmpty || trimmed == currentStatus) {
      return;
    }

    try {
      setState(() {
        widget.c.renameStatus(currentStatus, trimmed);
      });
    } catch (error) {
      _showRemovalError(error);
    }
  }

  void _submitTag() {
    name = controller.text.trim();
    if (name.isNotEmpty) {
      final createdTagName = name;
      setState(() {
        widget.c.addTag(Tag(createdTagName, null));
        controller.clear();
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              EditTag(tag: createdTagName, collections: widget.c),
        ),
      );
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.tagName) {
      case "Locations":
        return Scaffold(
          appBar: AppBar(title: const Text('Locations')),
          body: _OptionEditorBody(
            name: "Locations",
            options: widget.c.getAllLocations(),
            onAddOption: _submitLocation,
            onRemoveOption: _removeLocation,
            onRenameOption: _renameLocation,
          ),
        );
      case "Status":
        return Scaffold(
          appBar: AppBar(title: const Text('Status')),
          body: _OptionEditorBody(
            name: "Status",
            options: widget.c.getAllStatuses(),
            onAddOption: _submitStatus,
            onRemoveOption: _removeStatus,
            onRenameOption: _renameStatus,
          ),
        );
      case "Export":
        return Scaffold(
          appBar: AppBar(title: const Text('Export to PDF')),
          body: Center(
            child: ElevatedButton(
              onPressed: () {
                PdfGenerator(
                  widget.filteredItems ?? widget.c.items,
                ).generatePdf();
              },
              child: const Text('Export to PDF'),
            ),
          ),
        );
      case "Tags":
        final tags = widget.c.getAllTags().toList()
          ..sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );
        return Scaffold(
          appBar: AppBar(title: const Text('Tags')),
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: ListView(
              padding: _listContentPadding(context),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        for (Tag t in tags)
                          ListTile(
                            title: Text(t.getName()),
                            trailing: Wrap(
                              spacing: 4,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  tooltip: 'Edit tag',
                                  constraints: const BoxConstraints(
                                    minWidth: 48,
                                    minHeight: 48,
                                  ),
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditTag(
                                          tag: t.getName(),
                                          collections: widget.c,
                                        ),
                                      ),
                                    );
                                    if (!mounted) {
                                      return;
                                    }
                                    setState(() {});
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  tooltip: 'Delete tag',
                                  constraints: const BoxConstraints(
                                    minWidth: 48,
                                    minHeight: 48,
                                  ),
                                  onPressed: () => _removeTag(t.getName()),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: controller,
                          validator: widget.validator,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submitTag(),
                          decoration: const InputDecoration(labelText: 'Name'),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton(
                            onPressed: _submitTag,
                            child: const Text("Add Tag"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      default:
        return Scaffold(
          appBar: AppBar(title: const Text('Menu')),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Unknown tag name: ${widget.tagName}"),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Back"),
                ),
              ],
            ),
          ),
        );
    }
  }
}

class Menu extends StatefulWidget {
  final Collections c;
  final List<Item>? filteredItems;
  final int lowStockThreshold;
  final ValueChanged<int> onLowStockThresholdChanged;

  const Menu({
    super.key,
    required this.c,
    required this.filteredItems,
    required this.lowStockThreshold,
    required this.onLowStockThresholdChanged,
  });

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  late int _lowStockThreshold;

  @override
  void initState() {
    super.initState();
    _lowStockThreshold = widget.lowStockThreshold;
  }

  Future<void> _editLowStockThreshold() async {
    final controller = TextEditingController(
      text: _lowStockThreshold.toString(),
    );
    final result = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Low Stock Threshold'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Threshold',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final parsed = int.tryParse(controller.text.trim());
                if (parsed == null || parsed <= 0) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Enter a valid positive integer.'),
                    ),
                  );
                  return;
                }
                Navigator.of(dialogContext).pop(parsed);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (result == null || result == _lowStockThreshold) {
      return;
    }

    setState(() {
      _lowStockThreshold = result;
    });
    widget.onLowStockThresholdChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      resizeToAvoidBottomInset: true,
      body: FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              12,
              12,
              12,
              12 + mediaQuery.padding.bottom + mediaQuery.viewInsets.bottom,
            ),
            children: [
              Card(
                child: Column(
                  children: [
                    FocusTraversalOrder(
                      order: const NumericFocusOrder(1),
                      child: MenuItem(
                        c: widget.c,
                        filteredItems: widget.filteredItems,
                        name: "Locations",
                      ),
                    ),
                    const Divider(height: 1),
                    FocusTraversalOrder(
                      order: const NumericFocusOrder(2),
                      child: MenuItem(
                        c: widget.c,
                        filteredItems: widget.filteredItems,
                        name: "Status",
                      ),
                    ),
                    const Divider(height: 1),
                    FocusTraversalOrder(
                      order: const NumericFocusOrder(3),
                      child: MenuItem(
                        c: widget.c,
                        filteredItems: widget.filteredItems,
                        name: "Tags",
                      ),
                    ),
                    const Divider(height: 1),
                    FocusTraversalOrder(
                      order: const NumericFocusOrder(4),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        minVerticalPadding: 12,
                        title: const Text('Low Stock Threshold'),
                        subtitle: Text('Current: $_lowStockThreshold'),
                        trailing: const Icon(Icons.tune),
                        onTap: _editLowStockThreshold,
                      ),
                    ),
                    const Divider(height: 1),
                    FocusTraversalOrder(
                      order: const NumericFocusOrder(5),
                      child: MenuItem(
                        c: widget.c,
                        filteredItems: widget.filteredItems,
                        name: "Export",
                      ),
                    ),
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

class _OptionEditorBody extends StatefulWidget {
  final String name;
  final Set<String> options;
  final ValueChanged<String> onAddOption;
  final ValueChanged<String> onRemoveOption;
  final Future<void> Function(String)? onRenameOption;

  const _OptionEditorBody({
    required this.name,
    required this.options,
    required this.onAddOption,
    required this.onRemoveOption,
    this.onRenameOption,
  });

  @override
  State<_OptionEditorBody> createState() => _OptionEditorBodyState();
}

class _OptionEditorBodyState extends State<_OptionEditorBody> {
  final TextEditingController _controller = TextEditingController();

  EdgeInsets _listContentPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return EdgeInsets.fromLTRB(
      12,
      12,
      12,
      12 + mediaQuery.padding.bottom + mediaQuery.viewInsets.bottom,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addOption() {
    final newOption = _controller.text.trim();
    if (newOption.isNotEmpty) {
      widget.onAddOption(newOption);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedOptions = widget.options.toList()..sort();

    return SafeArea(
      child: ListView(
        padding: _listContentPadding(context),
        children: [
          Card(
            child: sortedOptions.isEmpty
                ? const ListTile(title: Text('No options yet'))
                : Column(
                    children: [
                      for (String option in sortedOptions)
                        ListTile(
                          title: Text(option),
                          trailing: Wrap(
                            spacing: 4,
                            children: [
                              if (widget.onRenameOption != null)
                                IconButton(
                                  icon: const Icon(
                                    Icons.drive_file_rename_outline,
                                  ),
                                  tooltip: 'Rename option',
                                  constraints: const BoxConstraints(
                                    minWidth: 48,
                                    minHeight: 48,
                                  ),
                                  onPressed: () {
                                    widget.onRenameOption?.call(option);
                                  },
                                ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                tooltip: 'Delete option',
                                constraints: const BoxConstraints(
                                  minWidth: 48,
                                  minHeight: 48,
                                ),
                                onPressed: () => widget.onRemoveOption(option),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(labelText: 'Name'),
                      onSubmitted: (_) => _addOption(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(onPressed: _addOption, child: const Text('Add')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
