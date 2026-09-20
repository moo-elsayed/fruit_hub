import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fruit_hub/core/theming/app_palette.dart';

class FullScreenGalleryImageItem extends StatelessWidget {
  const FullScreenGalleryImageItem({super.key, required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    if (path.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.contain,
        placeholder: (context, url) => const Center(
          child: CupertinoActivityIndicator(color: AppPalette.white),
        ),
        errorWidget: (context, url, error) => const Center(
          child: Icon(
            Icons.error_outline_rounded,
            color: AppPalette.white,
            size: 48,
          ),
        ),
      );
    } else if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(
            Icons.error_outline_rounded,
            color: AppPalette.white,
            size: 48,
          ),
        ),
      );
    } else {
      return Image.file(
        File(path),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(
            Icons.broken_image_rounded,
            color: AppPalette.white,
            size: 48,
          ),
        ),
      );
    }
  }
}
