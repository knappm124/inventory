import 'collections.dart';
import 'package:flutter/material.dart';

class EditTag extends StatefulWidget {
  final String tag;
  final Collections collections;

  const EditTag({super.key, required this.tag, required this.collections});

  @override
  State<EditTag> createState() => _EditTagState();
}

class _EditTagState extends State<EditTag> {
  late TextEditingController _controller;
  late String _currentTag;

  EdgeInsets _contentPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return EdgeInsets.fromLTRB(
      12,
      12,
      12,
      12 + mediaQuery.padding.bottom + mediaQuery.viewInsets.bottom,
    );
  }

  void _addOption() {
    final newOption = _controller.text.trim();
    if (newOption.isNotEmpty) {
      setState(() {
        widget.collections.addTagOption(_currentTag, newOption);
      });
      _controller.clear();
    }
  }

  String _formatError(Object error) {
    final raw = error.toString();
    const prefix = 'Exception: ';
    if (raw.startsWith(prefix)) {
      return raw.substring(prefix.length);
    }
    return raw;
  }

  void _showError(Object error) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(_formatError(error))));
  }

  Future<String?> _askForName({
    required String title,
    required String label,
    required String initialValue,
    required String saveLabel,
  }) async {
    final textController = TextEditingController(text: initialValue);
    final value = await showDialog<String>(
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
              child: Text(saveLabel),
            ),
          ],
        );
      },
    );
    textController.dispose();
    return value;
  }

  Future<void> _renameTag() async {
    final newName = await _askForName(
      title: 'Rename Tag',
      label: 'Tag name',
      initialValue: _currentTag,
      saveLabel: 'Rename',
    );

    if (!mounted || newName == null) {
      return;
    }

    final trimmed = newName.trim();
    if (trimmed.isEmpty || trimmed == _currentTag) {
      return;
    }

    try {
      setState(() {
        widget.collections.renameTag(_currentTag, trimmed);
        _currentTag = trimmed;
      });
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _renameOption(String option) async {
    final newOption = await _askForName(
      title: 'Rename Option',
      label: 'Option name',
      initialValue: option,
      saveLabel: 'Rename',
    );

    if (!mounted || newOption == null) {
      return;
    }

    final trimmed = newOption.trim();
    if (trimmed.isEmpty || trimmed == option) {
      return;
    }

    try {
      setState(() {
        widget.collections.renameTagOption(_currentTag, option, trimmed);
      });
    } catch (error) {
      _showError(error);
    }
  }

  @override
  void initState() {
    super.initState();
    _currentTag = widget.tag;
    _controller = TextEditingController(text: "");
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sortedOptions =
        (widget.collections.getTagOptions(_currentTag)?.toList() ?? <String>[])
          ..sort();

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentTag),
        actions: [
          IconButton(
            icon: const Icon(Icons.drive_file_rename_outline),
            tooltip: 'Rename tag',
            onPressed: _renameTag,
          ),
          const SizedBox(width: 4),
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: ListView(
          padding: _contentPadding(context),
          children: [
            Card(
              child: sortedOptions.isEmpty
                  ? const ListTile(title: Text('No options yet'))
                  : Column(
                      children: [
                        for (final option in sortedOptions)
                          ListTile(
                            title: Text(option),
                            trailing: Wrap(
                              spacing: 4,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.drive_file_rename_outline,
                                  ),
                                  tooltip: 'Rename option',
                                  onPressed: () => _renameOption(option),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  tooltip: 'Delete option',
                                  onPressed: () {
                                    setState(() {
                                      widget.collections.removeTagOption(
                                        _currentTag,
                                        option,
                                      );
                                    });
                                  },
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
                      child: TextFormField(
                        controller: _controller,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _addOption(),
                        decoration: const InputDecoration(
                          labelText: 'New Option',
                          hintText: 'Enter a new option for the tag',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: _addOption,
                      child: const Text('Add Option'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
