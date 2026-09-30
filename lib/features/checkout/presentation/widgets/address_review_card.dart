import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fruit_hub/core/helpers/app_assets.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_palette.dart';
import 'package:fruit_hub/features/checkout/domain/entities/address_entity.dart';
import 'package:fruit_hub/features/checkout/presentation/widgets/address_review_content.dart';

class AddressReviewCard extends StatelessWidget {
  const AddressReviewCard({super.key, this.address});

  final AddressEntity? address;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    decoration: BoxDecoration(
      color: context.isDarkMode
          ? context.colors.surface
          : AppPalette.bgLightSecondary,
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: context.colors.border),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12.w,
      children: [
        SizedBox(
          height: 24.h,
          width: 24.w,
          child: SvgPicture.asset(
            AppAssets.iconsLocation,
            colorFilter: ColorFilter.mode(
              context.colors.primary,
              BlendMode.srcIn,
            ),
          ),
        ),
        Expanded(
          child: address != null
              ? AddressReviewContent(address: address!)
              : const SizedBox.shrink(),
        ),
      ],
    ),
  );
}
