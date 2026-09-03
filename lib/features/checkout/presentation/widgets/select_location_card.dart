import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/features/checkout/domain/entities/selected_location_entity.dart';
import 'package:fruit_hub/features/checkout/presentation/args/address_args.dart';
import 'package:fruit_hub/features/checkout/presentation/args/location_picker_args.dart';
import 'package:gap/gap.dart';

class SelectLocationCard extends StatefulWidget {
  const SelectLocationCard({super.key, required this.addressArgs});

  final AddressArgs addressArgs;

  @override
  State<SelectLocationCard> createState() => _SelectLocationCardState();
}

class _SelectLocationCardState extends State<SelectLocationCard> {
  bool get _hasLocation =>
      widget.addressArgs.latitude != null &&
      widget.addressArgs.longitude != null;

  Future<void> _handleTap() async {
    final result = await context.pushNamed(
      Routes.locationPickerView,
      arguments: LocationPickerArgs(
        latitude: widget.addressArgs.latitude,
        longitude: widget.addressArgs.longitude,
      ),
    ) as SelectedLocationEntity?;

    if (result != null && mounted) {
      widget.addressArgs.setCoordinates(
        lat: result.latitude,
        lng: result.longitude,
      );
      if (result.city.isNotEmpty) {
        widget.addressArgs.cityController.text = result.city;
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: _handleTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: context.colors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: _hasLocation
                ? context.colors.primary
                : context.colors.primary.withValues(alpha: 0.25),
            width: 1.5.w,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _hasLocation ? Icons.location_on_rounded : Icons.map_outlined,
                color: context.colors.primary,
                size: 22.sp,
              ),
            ),
            Gap(12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _hasLocation
                        ? AppStrings.selectedLocation
                        : AppStrings.selectLocationOnMap,
                    style: AppTextStyles.font14Bold.copyWith(
                      color: context.colors.mainText,
                    ),
                  ),
                  Gap(2.h),
                  Text(
                    _hasLocation
                        ? widget.addressArgs.cityController.text
                        : AppStrings.mapInstructions,
                    style: AppTextStyles.font12Regular.copyWith(
                      color: context.colors.subText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              _hasLocation
                  ? Icons.check_circle_rounded
                  : Icons.arrow_forward_ios_rounded,
              color: context.colors.primary,
              size: _hasLocation ? 20.sp : 14.sp,
            ),
          ],
        ),
      ),
    ),
  );
}
