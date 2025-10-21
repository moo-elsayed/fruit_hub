import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../generated/assets.dart';

class CustomNetworkImage extends StatelessWidget {
  const CustomNetworkImage({super.key,required this.image});

  final String image;

  @override
  Widget build(BuildContext context) {
    return image == ''
        ? Image.asset(Assets.imagesWatermelonTest)
        : Flexible(
      child: CachedNetworkImage(imageUrl: image, fit: BoxFit.scaleDown),
    );
  }
}