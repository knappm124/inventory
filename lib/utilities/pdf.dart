import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'collections.dart';
import 'image_utils.dart';
import 'dart:convert';
import 'dart:io';
import 'package:web/web.dart' as web;

class PdfGenerator {
  final pw.Document pdf = pw.Document();
  final Collections collections;

  PdfGenerator(this.collections);

  Future<Uint8List?> _loadImageBytes(String? source) async {
    final rawSource = source?.trim();
    if (rawSource == null || rawSource.isEmpty) {
      return null;
    }

    if (isDataImageUri(rawSource)) {
      return decodeImageFromDataUri(rawSource);
    }

    final uri = Uri.tryParse(rawSource);
    final isRemote =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
    if (isRemote) {
      try {
        final image = await NetworkAssetBundle(uri).load(rawSource);
        return image.buffer.asUint8List();
      } catch (_) {
        return null;
      }
    }

    if (!kIsWeb) {
      try {
        final file = File(rawSource);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          if (bytes.isNotEmpty) {
            return bytes;
          }
        }
      } catch (_) {
        // Fall back to bundled asset loading below.
      }
    }

    try {
      final image = await rootBundle.load(rawSource);
      return image.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  Future<void> generatePdf() async {
    final rows = <pw.TableRow>[
      pw.TableRow(
        children: [pw.Text("Image"), pw.Text("Name"), pw.Text("Price")],
      ),
    ];

    for (final item in collections.items) {
      final imageBytes = await _loadImageBytes(item.img);
      final imageCell = imageBytes == null || imageBytes.isEmpty
          ? pw.Text("No image")
          : pw.Image(
              pw.MemoryImage(imageBytes),
              width: 50,
              height: 50,
              fit: pw.BoxFit.cover,
            );

      rows.add(
        pw.TableRow(
          children: [
            imageCell,
            pw.Text(item.name),
            pw.Text(item.price.toStringAsFixed(2)),
          ],
        ),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text("Inventory"),
          pw.SizedBox(height: 20),
          pw.Table(children: rows),
        ],
      ),
    );

    var savedFile = await pdf.save();
    List<int> fileInts = List.from(savedFile);
    web.HTMLAnchorElement()
      ..href =
          "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(fileInts)}"
      ..setAttribute("download", "${DateTime.now().millisecondsSinceEpoch}.pdf")
      ..click();
  }
}
