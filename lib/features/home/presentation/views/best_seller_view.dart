import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/extentions.dart';
import 'package:fruit_hub/core/widgets/custom_app_bar.dart';
import 'package:fruit_hub/core/widgets/fruits_grid_view.dart';

class BestSellerView extends StatelessWidget {
  const BestSellerView({
    super.key,
    required this.scrollController,
    required this.fruits,
  });

  final ScrollController scrollController;
  final List<FruitEntity> fruits;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "best_seller".tr(),
        showArrowBack: true,
        showNotification: true,
        onTap: () => context.pop(),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.only(top: 8.h),
        child: FruitsGridView(scrollController: scrollController, fruits: fruits),
      ),
    );
  }
}
