import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/foundation.dart';
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import 'collections.dart';
import 'image_utils.dart';
import 'dart:io';

class PdfGenerator {
  final pw.Document pdf = pw.Document();
  final List<Item> items;

  PdfGenerator(this.items);

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
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(10),
            child: pw.Text(
              "Image",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(10),
            child: pw.Text(
              "Name",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(10),
            child: pw.Text(
              "Price",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    ];

    for (final item in items) {
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
            pw.Padding(padding: const pw.EdgeInsets.all(10), child: imageCell),
            pw.Padding(
              padding: const pw.EdgeInsets.all(10),
              child: pw.Text(item.name),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(10),
              child: pw.Text(item.price.toStringAsFixed(2)),
            ),
          ],
        ),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text(
            "Inventory",
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 32),
          ),
          pw.SizedBox(height: 20),
          pw.Table(
            columnWidths: {
              0: pw.FixedColumnWidth(100),
              1: pw.FixedColumnWidth(100),
              2: pw.FixedColumnWidth(100),
            },
            children: rows,
            border: pw.TableBorder.all(
              color: PdfColors.black,
              width: 1.0,
              style: pw.BorderStyle.solid,
            ),
          ),
        ],
      ),
    );

    final savedFile = await pdf.save();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.pdf';
    await Printing.sharePdf(bytes: savedFile, filename: fileName);
  }
}
