import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/widgets/custom_fruit_item.dart';
import 'package:skeletonizer/skeletonizer.dart';

class FruitsGridView extends StatelessWidget {
  const FruitsGridView({
    super.key,
    this.fruits,
    this.itemCount,
    this.fromFavorite = false,
    this.physics = const AlwaysScrollableScrollPhysics(),
    this.shrinkWrap = false,
    this.bottomPadding,
  });

  final List<FruitEntity>? fruits;
  final int? itemCount;
  final bool fromFavorite;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final double? bottomPadding;

  @override
  Widget build(BuildContext context) => Skeletonizer(
    enabled: itemCount != null,
    child: GridView.builder(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 8.h,
        bottom: bottomPadding ?? 85.h,
      ),
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemCount: itemCount ?? fruits?.length ?? 0,
      gridDelegate: buildSliverGridDelegateWithFixedCrossAxisCount(),
      itemBuilder: (context, index) {
        final fruitEntity = itemCount != null
            ? const FruitEntity()
            : fruits![index];
        return CustomFruitItem(
          key: fromFavorite ? ValueKey(fruitEntity.code) : null,
          fruitEntity: fruitEntity,
        );
      },
    ),
  );

  static SliverGridDelegateWithFixedCrossAxisCount
  buildSliverGridDelegateWithFixedCrossAxisCount() =>
      SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 163 / 214,
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.w,
      );
}
