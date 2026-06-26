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

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.tag);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      for(String option in widget.collections.getTagOptions(widget.tag) ?? {}) Text(option),
        ElevatedButton(
          onPressed: () {
            String newTag = _controller.text.trim();
            if (newTag.isNotEmpty) {
              widget.collections.removeTag(Tag(widget.tag, null));
              widget.collections.addTag(Tag(newTag, null));
            }
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}