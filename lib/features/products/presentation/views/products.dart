import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/widgets/custom_app_bar.dart';
import 'package:gap/gap.dart';
import '../../../../core/widgets/search_text_field.dart';

class Products extends StatelessWidget {
  const Products({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Gap(5.h),
          CustomAppBar(title: "products".tr(), showNotification: true),
          Padding(
            padding: EdgeInsets.only(
              right: 16.w,
              left: 16.w,
              bottom: 12.h,
              top: 13.h,
            ),
            child: const SearchTextFiled(),
          ),
        ],
      ),
    );
  }
}
