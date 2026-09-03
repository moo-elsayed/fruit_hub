import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/features/checkout/domain/entities/address_entity.dart';
import 'package:gap/gap.dart';

class AddressReviewContent extends StatelessWidget {
  const AddressReviewContent({super.key, required this.address});

  final AddressEntity address;

  @override
  Widget build(BuildContext context) {
    final hasRecipient =
        address.name.trim().isNotEmpty || address.phone.trim().isNotEmpty;
    final location = address.formattedLocation;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasRecipient) ...[
          Row(
            children: [
              if (address.name.trim().isNotEmpty)
                Text(
                  address.name,
                  style: AppTextStyles.font13Bold.copyWith(
                    color: context.colors.mainText,
                  ),
                ),
              if (address.name.trim().isNotEmpty &&
                  address.phone.trim().isNotEmpty)
                Text(
                  ' • ',
                  style: AppTextStyles.font13SemiBold.copyWith(
                    color: context.colors.subText,
                  ),
                ),
              if (address.phone.trim().isNotEmpty)
                Text(
                  address.phone,
                  style: AppTextStyles.font13SemiBold.copyWith(
                    color: context.colors.subText,
                  ),
                ),
            ],
          ),
          Gap(4.h),
        ],
        Text(
          location,
          style: AppTextStyles.font13SemiBold.copyWith(
            color: context.colors.mainText,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
