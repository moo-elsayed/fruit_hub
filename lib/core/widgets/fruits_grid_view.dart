import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/widgets/custom_fruit_item.dart';

class FruitsGridView extends StatelessWidget {
  const FruitsGridView({
    super.key,
    this.scrollController,
    this.fruits,
    this.itemCount,
  });

  final ScrollController? scrollController;
  final List<FruitEntity>? fruits;
  final int? itemCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: scrollController,
      padding: EdgeInsetsGeometry.symmetric(horizontal: 16.w),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: itemCount ?? fruits?.length ?? 0,
      gridDelegate: buildSliverGridDelegateWithFixedCrossAxisCount(),
      itemBuilder: (context, index) {
        return CustomFruitItem(
          fruitEntity: itemCount != null ? FruitEntity() : fruits![index],
        );
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
