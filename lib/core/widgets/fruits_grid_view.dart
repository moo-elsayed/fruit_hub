import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/widgets/custom_fruit_item.dart';

class FruitsGridView extends StatelessWidget {
  const FruitsGridView({
    super.key,
    this.scrollController,
    this.showFewFruit = false,
  });

  final ScrollController? scrollController;
  final bool showFewFruit;

  @override
  Widget build(BuildContext context) {
    return showFewFruit
        ? SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) => const CustomFruitItem(),
                childCount: 4,
              ),
              gridDelegate: buildSliverGridDelegateWithFixedCrossAxisCount(),
            ),
          )
        : GridView.builder(
            controller: scrollController,
            padding: EdgeInsetsGeometry.symmetric(horizontal: 16.w),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: 12,
            gridDelegate: buildSliverGridDelegateWithFixedCrossAxisCount(),
            itemBuilder: (context, index) {
              return const CustomFruitItem();
            },
          );
  }

  SliverGridDelegateWithFixedCrossAxisCount
  buildSliverGridDelegateWithFixedCrossAxisCount() {
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 163 / 214,
      mainAxisSpacing: 12.h,
      crossAxisSpacing: 12.w,
    );
  }
}
