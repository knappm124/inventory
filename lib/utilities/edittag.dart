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
      body: DefaultTextStyle(
        style: TextStyle(color: Colors.black, fontSize: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: EdgeInsets.all(10)),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back_sharp),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(widget.tag, style: TextStyle(fontSize: 32.0)),
                for (String option in sortedOptions)
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text(
                          option,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
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
                      ],
                    ),
                  ),
                Container(
                  width: 300,
                  padding: const EdgeInsets.all(10),
                  child: Material(
                    child: TextFormField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: 'New Option',
                        hintText: 'Enter a new option for the tag',
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    String newOption = _controller.text.trim();
                    if (newOption.isNotEmpty) {
                      setState(() {
                        widget.collections.addTagOption(widget.tag, newOption);
                      });
                      _controller.clear();
                    }
                  },
                  child: const Text('Add Option'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
