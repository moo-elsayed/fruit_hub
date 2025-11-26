import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../generated/assets.dart';

class CustomNetworkImage extends StatelessWidget {
  const CustomNetworkImage({
    super.key,
    this.image = '',
    this.height,
    this.width,
  });

  final String image;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return image == ''
        ? Image.asset(Assets.imagesWatermelonTest)
        : CachedNetworkImage(imageUrl: image, height: height, width: width);
  }
}
