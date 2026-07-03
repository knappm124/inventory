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

  void _addOption() {
    final newOption = _controller.text.trim();
    if (newOption.isNotEmpty) {
      setState(() {
        widget.collections.addTagOption(widget.tag, newOption);
      });
      _controller.clear();
    }
  }

  @override
  void initState() {
    super.initState();
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
        (widget.collections.getTagOptions(widget.tag)?.toList() ?? <String>[])
          ..sort();

    return Scaffold(
      appBar: AppBar(title: Text(widget.tag)),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: sortedOptions.isEmpty
                ? const ListTile(title: Text('No options yet'))
                : Column(
                    children: [
                      for (final option in sortedOptions)
                        ListTile(
                          title: Text(option),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                widget.collections.removeTagOption(
                                  widget.tag,
                                  option,
                                );
                              });
                            },
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
    );
  }
}
