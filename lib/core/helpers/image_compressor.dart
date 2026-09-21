import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageCompressor {
  const ImageCompressor();

  Future<Uint8List> compressImage(
    Uint8List data, {
    int quality = 75,
    int minWidth = 1024,
    int minHeight = 1024,
    CompressFormat format = CompressFormat.jpeg,
  }) => FlutterImageCompress.compressWithList(
    data,
    quality: quality,
    minWidth: minWidth,
    minHeight: minHeight,
    format: format,
  );

  Future<Uint8List?> compressWithFile(
    String path, {
    int quality = 75,
    int minWidth = 1024,
    int minHeight = 1024,
    CompressFormat format = CompressFormat.jpeg,
  }) => FlutterImageCompress.compressWithFile(
    path,
    quality: quality,
    minWidth: minWidth,
    minHeight: minHeight,
    format: format,
  );
}
