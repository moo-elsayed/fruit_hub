import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fruit_hub/core/theming/app_palette.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/utils/full_screen_image_gallery_input_item.dart';

class FullScreenImageGallery extends StatefulWidget {
  const FullScreenImageGallery({super.key, required this.item});

  final FullScreenImageGalleryInputItem item;

  @override
  State<FullScreenImageGallery> createState() => _FullScreenImageGalleryState();
}

class _FullScreenImageGalleryState extends State<FullScreenImageGallery> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.item.initialIndex;
    _pageController = PageController(initialPage: widget.item.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildImage(String path) {
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

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppPalette.black,
    appBar: AppBar(
      backgroundColor: AppPalette.black,
      iconTheme: const IconThemeData(color: AppPalette.white),
      elevation: 0,
      centerTitle: true,
      title: widget.item.imagesPaths.length > 1
          ? Text(
              '${_currentIndex + 1} / ${widget.item.imagesPaths.length}',
              style: AppTextStyles.font16Regular.copyWith(
                color: AppPalette.white,
              ),
            )
          : null,
    ),
    body: PageView.builder(
      controller: _pageController,
      itemCount: widget.item.imagesPaths.length,
      onPageChanged: (index) => setState(() => _currentIndex = index),
      itemBuilder: (context, index) {
        final path = widget.item.imagesPaths[index];
        return InteractiveViewer(
          minScale: 1.0,
          maxScale: 4.0,
          child: path.isNotEmpty
              ? Hero(tag: path, child: _buildImage(path))
              : _buildImage(path),
        );
      },
    ),
  );
}
