import 'package:flutter/material.dart';
import 'package:fruit_hub/core/theming/app_palette.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/utils/full_screen_image_gallery_input_item.dart';
import 'package:fruit_hub/core/widgets/full_screen_gallery_image_item.dart';

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
              ? Hero(
                  tag: path,
                  child: FullScreenGalleryImageItem(path: path),
                )
              : FullScreenGalleryImageItem(path: path),
        );
      },
    ),
  );
}
