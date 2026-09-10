import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';

class ImagePickerThumbnail extends StatelessWidget {
  const ImagePickerThumbnail({
    super.key,
    required this.path,
    this.size = 64,
    this.borderRadius = 8,
  });

  final String path;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(borderRadius.r),
    child: path.startsWith('http')
        ? CachedNetworkImage(
            imageUrl: path,
            width: size.w,
            height: size.w,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: size.w,
              height: size.w,
              color: context.colors.border,
            ),
            errorWidget: (context, url, error) => _buildError(context),
          )
        : Image.file(
            File(path),
            width: size.w,
            height: size.w,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildError(context),
          ),
  );

  Widget _buildError(BuildContext context) => Container(
    width: size.w,
    height: size.w,
    color: context.colors.border.withValues(alpha: 0.2),
    child: Icon(
      Icons.broken_image_rounded,
      size: 24.sp,
      color: context.colors.subText,
    ),
  );
}
