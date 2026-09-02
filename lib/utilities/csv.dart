import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:file_saver/file_saver.dart';

import 'collections.dart';

/// Converts the current inventory selection into a downloadable CSV file.
class CsvGenerator {
  final List<Item> items;
  final Collections c;

  CsvGenerator(this.items, this.c);

  Future<void> generateCsv() async {
    final headerRow = ['Id', 'Name', 'Price', 'Quantity', 'Location', 'Status'];
    for (var tag in c.tags) {
      headerRow.add(tag.name);
    }

    final csvContents = const ListToCsvConverter().convert([
      headerRow,
      ...collectionToString(),
    ]);
    final fileName = 'inventory_${DateTime.now().millisecondsSinceEpoch}';

    await FileSaver.instance.saveAs(
      name: fileName,
      bytes: Uint8List.fromList(utf8.encode(csvContents)),
      fileExtension: 'csv',
      mimeType: MimeType.csv,
    );
  }

  /// Produces rectangular rows, including blank values for tags an item lacks.
  List<List<String>> collectionToString() {
    List<List<String>> listOfLists = [];
    for (var item in items) {
      List<String> listOfStrings = [];
      listOfStrings.add(item.id.toString());
      listOfStrings.add(item.name);
      listOfStrings.add(item.price.toString());
      listOfStrings.add(item.quantity.toString());
      listOfStrings.add(item.location ?? "No Location");
      listOfStrings.add(item.status ?? "No Status");
      for (var tag in c.tags) {
        final tagValues = item.containsTag(tag.name)
            ? item.getAllOptions(tag.name).join(', ')
            : '';
        listOfStrings.add(tagValues);
      }
      listOfLists.add(listOfStrings);
    }

    return listOfLists;
  }
}
