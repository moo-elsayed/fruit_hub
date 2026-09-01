import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_palette.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/custom_bottom_sheet_handle.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:gap/gap.dart';

class LocationPickerBottomSheet extends StatelessWidget {
  const LocationPickerBottomSheet({
    super.key,
    required this.cityName,
    required this.isLoading,
    required this.onConfirm,
  });

  final String cityName;
  final bool isLoading;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) => Positioned(
    bottom: 0,
    left: 0,
    right: 0,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: context.colors.border.withValues(alpha: 0.4),
            blurRadius: 16.r,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BottomSheetHandle(),
            Gap(12.h),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_city_rounded,
                    color: context.colors.primary,
                    size: 24.sp,
                  ),
                ),
                Gap(12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.selectedLocation,
                        style: AppTextStyles.font12Regular.copyWith(
                          color: context.colors.subText,
                        ),
                      ),
                      Gap(2.h),
                      if (isLoading)
                        Row(
                          children: [
                            SizedBox(
                              width: 14.r,
                              height: 14.r,
                              child: CupertinoActivityIndicator(
                                color: context.colors.primary,
                                radius: 7.r,
                              ),
                            ),
                            Gap(8.w),
                            Text(
                              AppStrings.locating,
                              style: AppTextStyles.font14Bold.copyWith(
                                color: context.colors.mainText,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          cityName.isNotEmpty
                              ? cityName
                              : AppStrings.dragMapToSelectLocation,
                          style: AppTextStyles.font15Bold.copyWith(
                            color: context.colors.mainText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            Gap(18.h),
            CustomMaterialButton(
              onPressed: onConfirm,
              isLoading: isLoading,
              maxWidth: true,
              text: AppStrings.confirmLocation,
              textStyle: AppTextStyles.font16Bold.copyWith(
                color: AppPalette.white,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
