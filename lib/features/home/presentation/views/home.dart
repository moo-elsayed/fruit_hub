import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/widgets/fruits_grid_view.dart';
import 'package:fruit_hub/features/home/presentation/widgets/custom_home_app_bar.dart';
import 'package:fruit_hub/features/home/presentation/widgets/custom_slider_view.dart';
import 'package:gap/gap.dart';
import '../widgets/custom_section_header.dart';
import '../widgets/search_text_field.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus!.unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          const CustomHomeAppBar(),
          Padding(
            padding: EdgeInsets.only(right: 16.w, left: 16.w, bottom: 12.h),
            child: const SearchTextFiled(),
          ),
          const CustomSliderView(),
          Gap(12.h),
          CustomSectionHeader(sectionName: "best_seller".tr()),
          Gap(8.h),
          const Expanded(child: FruitsGridView()),
        ],
      ),
    );
  }
}
