import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

const String _defaultImageMimeType = 'image/jpeg';

bool isDataImageUri(String source) {
  return source.startsWith('data:image/');
}

String inferImageMimeType({String? mimeType, String? path}) {
  if (mimeType != null && mimeType.startsWith('image/')) {
    return mimeType;
  }

  final filePath = path ?? '';
  final dotIndex = filePath.lastIndexOf('.');
  if (dotIndex == -1 || dotIndex == filePath.length - 1) {
    return _defaultImageMimeType;
  }

  final extension = filePath.substring(dotIndex + 1).toLowerCase();
  switch (extension) {
    case 'png':
      return 'image/png';
    case 'gif':
      return 'image/gif';
    case 'webp':
      return 'image/webp';
    case 'bmp':
      return 'image/bmp';
    case 'heic':
      return 'image/heic';
    case 'heif':
      return 'image/heif';
    case 'jpg':
    case 'jpeg':
    default:
      return _defaultImageMimeType;
  }
}

String encodeImageToDataUri(Uint8List bytes, {String? mimeType, String? path}) {
  final resolvedMimeType = inferImageMimeType(mimeType: mimeType, path: path);
  return 'data:$resolvedMimeType;base64,${base64Encode(bytes)}';
}

Uint8List? decodeImageFromDataUri(String source) {
  if (!isDataImageUri(source)) {
    return null;
  }

  final commaIndex = source.indexOf(',');
  if (commaIndex == -1 || commaIndex == source.length - 1) {
    return null;
  }

  final payload = source.substring(commaIndex + 1);
  try {
    return base64Decode(payload);
  } catch (_) {
    return null;
  }
}

Widget buildInventoryImage({
  required String source,
  required double width,
  required double height,
  BoxFit fit = BoxFit.contain,
  Widget? placeholder,
}) {
  final fallback =
      placeholder ??
      const Icon(Icons.image_not_supported, size: 48, color: Colors.grey);

  if (source.trim().isEmpty) {
    return fallback;
  }

  if (isDataImageUri(source)) {
    final bytes = decodeImageFromDataUri(source);
    if (bytes == null || bytes.isEmpty) {
      return fallback;
    }

    return Image.memory(
      bytes,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }

  final uri = Uri.tryParse(source);
  final isRemote =
      uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  if (isRemote) {
    return Image.network(
      source,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }

  if (kIsWeb) {
    return fallback;
  }

  return FutureBuilder<Uint8List>(
    future: XFile(source).readAsBytes(),
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return SizedBox(width: width, height: height, child: fallback);
      }

      final bytes = snapshot.data;
      if (bytes == null || bytes.isEmpty) {
        return SizedBox(width: width, height: height, child: fallback);
      }

      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => fallback,
      );
    },
  );
}
