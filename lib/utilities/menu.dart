import 'package:flutter/material.dart';
import './collections.dart';
import './edittag.dart';

class MenuItem extends StatelessWidget {
  final Collections c;
  final String name;

  const MenuItem({super.key, required this.c, required this.name});

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
          builder: (context) => Editor(tagName: name, c: c),
        ),
      ),
    );
  }
}

class Editor extends StatefulWidget {
  final String tagName;
  final Collections c;

  String? validator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a name';
    }
    return null;
  }

  const Editor({super.key, required this.tagName, required this.c});

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  final TextEditingController controller = TextEditingController();
  String name = "";

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

  void _submitTag() {
    name = controller.text.trim();
    if (name.isNotEmpty) {
      setState(() {
        widget.c.addTag(Tag(name, null));
        controller.clear();
      });
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
          body: DefaultTextStyle(
            style: TextStyle(color: Colors.black, fontSize: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(padding: EdgeInsets.all(10)),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Back',
                  icon: Icon(Icons.arrow_back_sharp),
                ),
                _OptionEditorBody(
                  name: "Locations",
                  options: widget.c.getAllLocations(),
                  onAddOption: _submitLocation,
                  onRemoveOption: _removeLocation,
                ),
              ],
            ),
          ),
        );
      case "Status":
        return Scaffold(
          body: DefaultTextStyle(
            style: TextStyle(color: Colors.black, fontSize: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(padding: EdgeInsets.all(10)),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Back',
                  icon: Icon(Icons.arrow_back_sharp),
                ),
                _OptionEditorBody(
                  name: "Status",
                  options: widget.c.getAllStatuses(),
                  onAddOption: _submitStatus,
                  onRemoveOption: _removeStatus,
                ),
              ],
            ),
          ),
        );
      case "Tags":
        final tags = widget.c.getAllTags().toList()
          ..sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );
        return Scaffold(
          body: DefaultTextStyle(
            style: TextStyle(color: Colors.black, fontSize: 16.0),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Back',
                    icon: Icon(Icons.arrow_back_sharp),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Tags", style: TextStyle(fontSize: 32.0)),
                      for (Tag t in tags)
                        SizedBox(
                          width: 400,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Text(t.getName()),
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  tooltip: 'Edit tag',
                                  constraints: const BoxConstraints(
                                    minWidth: 48,
                                    minHeight: 48,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditTag(
                                          tag: t.getName(),
                                          collections: widget.c,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
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
                        ),
                      Container(
                        width: 300,
                        padding: const EdgeInsets.all(10),
                        child: Material(
                          child: TextFormField(
                            controller: controller,
                            validator: widget.validator,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submitTag(),
                            decoration: InputDecoration(
                              labelText: 'Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _submitTag,
                        child: Text("Add Tag"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      default:
        return Scaffold(
          body: Column(
            children: [
              Text("Unknown tag name: ${widget.tagName}"),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Back"),
              ),
            ],
          ),
        );
    }
  }
}

class Menu extends StatefulWidget {
  final Collections c;
  final int lowStockThreshold;
  final ValueChanged<int> onLowStockThresholdChanged;

  const Menu({
    super.key,
    required this.c,
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
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: EdgeInsets.all(10)),
          IconButton(
            onPressed: () => Navigator.pop(context),
            tooltip: 'Back',
            icon: Icon(Icons.arrow_back_sharp),
          ),
          DefaultTextStyle(
            style: TextStyle(color: Colors.black, fontSize: 32.0),
            child: FocusTraversalGroup(
              policy: OrderedTraversalPolicy(),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FocusTraversalOrder(
                    order: const NumericFocusOrder(1),
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: MenuItem(c: widget.c, name: "Locations"),
                    ),
                  ),
                  FocusTraversalOrder(
                    order: const NumericFocusOrder(2),
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: MenuItem(c: widget.c, name: "Status"),
                    ),
                  ),
                  FocusTraversalOrder(
                    order: const NumericFocusOrder(3),
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: MenuItem(c: widget.c, name: "Tags"),
                    ),
                  ),
                  FocusTraversalOrder(
                    order: const NumericFocusOrder(4),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      minVerticalPadding: 12,
                      title: const Text('Low Stock Threshold'),
                      subtitle: Text('Current: $_lowStockThreshold'),
                      trailing: const Icon(Icons.tune),
                      onTap: _editLowStockThreshold,
                    ),
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

class _OptionEditorBody extends StatefulWidget {
  final String name;
  final Set<String> options;
  final ValueChanged<String> onAddOption;
  final ValueChanged<String> onRemoveOption;

  const _OptionEditorBody({
    required this.name,
    required this.options,
    required this.onAddOption,
    required this.onRemoveOption,
  });

  @override
  State<_OptionEditorBody> createState() => _OptionEditorBodyState();
}

class _OptionEditorBodyState extends State<_OptionEditorBody> {
  final TextEditingController _controller = TextEditingController();

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

    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.name, style: TextStyle(fontSize: 32.0)),
          for (String option in sortedOptions)
            Row(
              children: [
                Text(option),
                IconButton(
                  icon: Icon(Icons.delete),
                  tooltip: 'Delete option',
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  onPressed: () => widget.onRemoveOption(option),
                ),
              ],
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _addOption(),
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton(onPressed: _addOption, child: Text('Add')),
            ],
          ),
        ],
      ),
    );
  }
}
