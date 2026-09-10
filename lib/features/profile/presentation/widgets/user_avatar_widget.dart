import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';

class UserAvatarWidget extends StatelessWidget {
  const UserAvatarWidget({super.key, this.imagePath, this.size = 50});

  final String? imagePath;
  final double size;

  Widget _buildImage(BuildContext context, String path) {
    if (path.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: path,
        width: size.r,
        height: size.r,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: size.r,
          height: size.r,
          color: context.colors.primary.withValues(alpha: 0.12),
        ),
        errorWidget: (context, url, error) => _buildFallback(context),
      );
    }
    return Image.file(
      File(path),
      width: size.r,
      height: size.r,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildFallback(context),
    );
  }

  Widget _buildFallback(BuildContext context) => Icon(
    Icons.person_rounded,
    size: (size * 0.52).sp,
    color: context.colors.primary,
  );

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && imagePath!.trim().isNotEmpty;

    return Container(
      width: size.r,
      height: size.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colors.primary.withValues(alpha: 0.12),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.3),
          width: 1.w,
        ),
      ),
      child: ClipOval(
        child: hasImage
            ? _buildImage(context, imagePath!)
            : _buildFallback(context),
      ),
    );
  }
}
