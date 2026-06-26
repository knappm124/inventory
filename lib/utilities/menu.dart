import 'package:flutter/material.dart';
import './collections.dart';
import './edittag.dart';

class MenuItem extends StatelessWidget {
  final Collections c;
  final String name;

  const MenuItem({super.key, required this.c, required this.name});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Editor(tagName: name, c: c),
        ),
      ),
      child: Text(name),
    );
  }
}

class Editor extends StatefulWidget {
  final String tagName;
  final Collections c;
  final TextEditingController controller = TextEditingController();
  String? validator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a name';
    }
    return null;
  }

  Editor({super.key, required this.tagName, required this.c});

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  VoidCallback? get onPressed => null;
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

  void _removeTag(Tag tag) {
    try {
      setState(() {
        widget.c.removeTag(tag);
      });
    } catch (error) {
      _showRemovalError(error);
    }
  }

  void _submitLocation() {
    name = widget.controller.text.trim();
    if (name.isNotEmpty) {
      setState(() {
        widget.c.addLocation(name);
        widget.controller.clear();
      });
    }
  }

  void _submitStatus() {
    name = widget.controller.text.trim();
    if (name.isNotEmpty) {
      setState(() {
        widget.c.addStatus(name);
        widget.controller.clear();
      });
    }
  }

  void _submitTag() {
    name = widget.controller.text.trim();
    if (name.isNotEmpty) {
      setState(() {
        widget.c.addTag(Tag(name, null));
        widget.controller.clear();
      });
    }
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
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back_sharp),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Locations", style: TextStyle(fontSize: 32.0)),
                    for (String s in widget.c.getAllLocations())
                      SizedBox(
                        width: 400,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Text(s),
                              IconButton(
                                onPressed: () => _removeLocation(s),
                                icon: Icon(Icons.delete),
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
                          controller: widget.controller,
                          validator: widget.validator,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submitLocation(),
                          decoration: InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _submitLocation,
                      child: Text("Add Location"),
                    ),
                  ],
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
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back_sharp),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Status", style: TextStyle(fontSize: 32.0)),
                    for (String s in widget.c.getAllStatuses())
                      SizedBox(
                        width: 400,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Text(s),
                              IconButton(
                                onPressed: () => _removeStatus(s),
                                icon: Icon(Icons.delete),
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
                          controller: widget.controller,
                          validator: widget.validator,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submitStatus(),
                          decoration: InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _submitStatus,
                      child: Text("Add Status"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      case "Tags":
        return Scaffold(
          body: DefaultTextStyle(
            style: TextStyle(color: Colors.black, fontSize: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back_sharp),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Tags", style: TextStyle(fontSize: 32.0)),
                    for (Tag t in widget.c.getAllTags())
                      SizedBox(
                        width: 400,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Text(t.getName()),
                              IconButton(
                                icon: Icon(Icons.edit),
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
                                onPressed: () => _removeTag(t),
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
                          controller: widget.controller,
                          validator: widget.validator,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
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

class Menu extends StatelessWidget {
  final Collections c;

  const Menu({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_sharp),
          ),
          DefaultTextStyle(
            style: TextStyle(color: Colors.black, fontSize: 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: MenuItem(c: c, name: "Locations"),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: MenuItem(c: c, name: "Status"),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: MenuItem(c: c, name: "Tags"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
