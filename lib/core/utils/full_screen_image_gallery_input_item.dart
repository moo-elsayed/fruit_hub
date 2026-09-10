class FullScreenImageGalleryInputItem {
  const FullScreenImageGalleryInputItem({
    required this.imagesPaths,
    this.initialIndex = 0,
  });

  final List<String> imagesPaths;
  final int initialIndex;
}
