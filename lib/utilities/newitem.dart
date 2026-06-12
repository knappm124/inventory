import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NewItem extends StatelessWidget {
  const NewItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NewItemHeader(),
        NewName(),
        NewPrice(),
        LocationChoice(),
        StatusChoice(),
      ],
    );
  }
}

class NewName extends StatelessWidget {
  const NewName({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(10),
      child: Material(
        child: TextField(
          decoration: InputDecoration(
            labelText: 'Name', // Standard text label
            border: OutlineInputBorder(), // Optional: adds an outlined border
          ),
        ),
      ),
    );
  }
}

class NewPrice extends StatelessWidget {
  const NewPrice({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(10),
      child: Material(
        child: TextField(
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true, // Enables decimal point key on iOS/Android keyboards
            signed:
                false, // Set to true if you need to allow negative numbers (-)
          ),
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(
              RegExp(
                r'^\d*\.?\d*',
              ), // Allows numbers and only one optional decimal point
            ),
          ],
          decoration: const InputDecoration(
            labelText: "Price",
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}

class LocationChoice extends StatefulWidget {
  const LocationChoice({super.key});

  @override
  State<LocationChoice> createState() => _LocationChoiceState();
}

class _LocationChoiceState extends State<LocationChoice> {
  String location = "Home";

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: SegmentedButton<String>(
        segments: const <ButtonSegment<String>>[
          ButtonSegment<String>(value: "Home", label: Text('Home')),
          ButtonSegment<String>(value: "Etsy", label: Text('Etsy')),
          ButtonSegment<String>(
            value: "General Store",
            label: Text('General Store'),
          ),
        ],
        selected: <String>{location},
        onSelectionChanged: (Set<String> newSelection) {
          setState(() {
            // By default there is only a single segment that can be
            // selected at one time, so its value is always the first
            // item in the selected set.
            location = newSelection.first;
          });
        },
      ),
    );
  }
}

class StatusChoice extends StatefulWidget {
  const StatusChoice({super.key});

  @override
  State<StatusChoice> createState() => _StatusChoice();
}

class _StatusChoice extends State<StatusChoice> {
  String status = "WIP";

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: SegmentedButton<String>(
        segments: const <ButtonSegment<String>>[
          ButtonSegment<String>(value: "WIP", label: Text('WIP')),
          ButtonSegment<String>(value: "Listed", label: Text('Listed')),
          ButtonSegment<String>(value: "Sold", label: Text('Sold')),
          ButtonSegment<String>(value: "Returned", label: Text('Returned')),
        ],
        selected: <String>{status},
        onSelectionChanged: (Set<String> newSelection) {
          setState(() {
            // By default there is only a single segment that can be
            // selected at one time, so its value is always the first
            // item in the selected set.
            status = newSelection.first;
          });
        },
      ),
    );
  }
}

class NewItemHeader extends StatelessWidget{
  const NewItemHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children:[
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back)
        ),
        IconButton(
          onPressed: null,
          icon: Icon(Icons.save)
        )
      ]
    );
  }
}