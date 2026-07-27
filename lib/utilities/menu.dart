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
    final icon = switch (name) {
      'Locations' => Icons.place_outlined,
      'Status' => Icons.label_important_outline,
      'Tags' => Icons.sell_outlined,
      'Export' => Icons.picture_as_pdf_outlined,
      _ => Icons.chevron_right,
    };

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      minVerticalPadding: 14,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.primaryContainer.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(name),
      subtitle: Text(_menuSubtitle(name)),
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

  String _menuSubtitle(String name) {
    switch (name) {
      case 'Locations':
        return 'Manage where items are stored.';
      case 'Status':
        return 'Adjust item lifecycle states.';
      case 'Tags':
        return 'Edit filtering and organization tags.';
      case 'Export':
        return 'Generate a PDF from the current inventory view.';
      default:
        return '';
    }
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
          body: SafeArea(
            child: Padding(
              padding: _listContentPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PanelHero(
                    title: 'Export inventory',
                    subtitle:
                        'Create a PDF snapshot of the current inventory view for sharing, printing, or backup.',
                    trailingLabel:
                        '${(widget.filteredItems ?? widget.c.items).length} items',
                    trailingIcon: Icons.picture_as_pdf_outlined,
                  ),
                  const SizedBox(height: 12),
                  _PanelCard(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PDF Export',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'This uses the current inventory selection, including any active filters from the home screen.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () {
                              PdfGenerator(
                                widget.filteredItems ?? widget.c.items,
                              ).generatePdf();
                            },
                            icon: const Icon(Icons.download_outlined),
                            label: const Text('Export to PDF'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
                _PanelHero(
                  title: 'Manage tags',
                  subtitle:
                      'Keep item classification tidy so filtering and grouping stay useful.',
                  trailingLabel: '${tags.length} tags',
                  trailingIcon: Icons.sell_outlined,
                ),
                const SizedBox(height: 12),
                _PanelCard(
                  child: tags.isEmpty
                      ? const ListTile(
                          title: Text('No tags yet'),
                          subtitle: Text('Add your first tag below.'),
                        )
                      : Column(
                          children: [
                            for (final t in tags)
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 4,
                                ),
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                        .withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    Icons.sell_outlined,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                                title: Text(t.getName()),
                                trailing: Wrap(
                                  spacing: 6,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined),
                                      tooltip: 'Edit tag',
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
                                      icon: const Icon(Icons.delete_outline),
                                      tooltip: 'Delete tag',
                                      onPressed: () => _removeTag(t.getName()),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                ),
                const SizedBox(height: 12),
                _PanelCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Tag',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: controller,
                          validator: widget.validator,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submitTag(),
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            hintText: 'Office, Camera, Seasonal...',
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _submitTag,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Tag'),
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
              _PanelHero(
                title: 'Settings',
                subtitle:
                    'Adjust inventory structure, tag management, export tools, and stock thresholds from one place.',
                trailingLabel: 'Threshold $_lowStockThreshold',
                trailingIcon: Icons.tune,
              ),
              const SizedBox(height: 12),
              _PanelCard(
                child: Column(
                  children: [
                    FocusTraversalOrder(
                      order: const NumericFocusOrder(1),
                      child: MenuItem(
                        c: widget.c,
                        filteredItems: widget.filteredItems,
                        name: 'Locations',
                      ),
                    ),
                    const Divider(height: 1),
                    FocusTraversalOrder(
                      order: const NumericFocusOrder(2),
                      child: MenuItem(
                        c: widget.c,
                        filteredItems: widget.filteredItems,
                        name: 'Status',
                      ),
                    ),
                    const Divider(height: 1),
                    FocusTraversalOrder(
                      order: const NumericFocusOrder(3),
                      child: MenuItem(
                        c: widget.c,
                        filteredItems: widget.filteredItems,
                        name: 'Tags',
                      ),
                    ),
                    const Divider(height: 1),
                    FocusTraversalOrder(
                      order: const NumericFocusOrder(4),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        minVerticalPadding: 14,
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.tune,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        title: const Text('Low Stock Threshold'),
                        subtitle: Text(
                          'Current: $_lowStockThreshold items remaining',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _editLowStockThreshold,
                      ),
                    ),
                    const Divider(height: 1),
                    FocusTraversalOrder(
                      order: const NumericFocusOrder(5),
                      child: MenuItem(
                        c: widget.c,
                        filteredItems: widget.filteredItems,
                        name: 'Export',
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
          _PanelHero(
            title: widget.name,
            subtitle:
                'Review, rename, or remove entries, then add new ones below.',
            trailingLabel: '${sortedOptions.length} total',
            trailingIcon: Icons.list_alt_outlined,
          ),
          const SizedBox(height: 12),
          _PanelCard(
            child: sortedOptions.isEmpty
                ? const ListTile(
                    title: Text('No options yet'),
                    subtitle: Text('Add the first option below.'),
                  )
                : Column(
                    children: [
                      for (final option in sortedOptions)
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer
                                  .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.circle_outlined,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          title: Text(option),
                          trailing: Wrap(
                            spacing: 6,
                            children: [
                              if (widget.onRenameOption != null)
                                IconButton(
                                  icon: const Icon(
                                    Icons.drive_file_rename_outline,
                                  ),
                                  tooltip: 'Rename option',
                                  onPressed: () {
                                    widget.onRenameOption?.call(option);
                                  },
                                ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                tooltip: 'Delete option',
                                onPressed: () => widget.onRemoveOption(option),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: 12),
          _PanelCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add ${widget.name.substring(0, widget.name.length - 1)}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _controller,
                    decoration: const InputDecoration(labelText: 'Name'),
                    onSubmitted: (_) => _addOption(),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _addOption,
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelHero extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trailingLabel;
  final IconData trailingIcon;

  const _PanelHero({
    required this.title,
    required this.subtitle,
    required this.trailingLabel,
    required this.trailingIcon,
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
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(trailingIcon, size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(trailingLabel, style: theme.textTheme.labelLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelCard extends StatelessWidget {
  final Widget child;

  const _PanelCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      elevation: 0,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.04),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
