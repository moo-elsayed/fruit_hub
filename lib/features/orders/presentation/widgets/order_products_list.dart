import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/entities/order_item_entity.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:gap/gap.dart';

import 'order_product_card.dart';

class OrderProductsList extends StatefulWidget {
  const OrderProductsList({
    super.key,
    required this.products,
    this.initiallyExpanded = true,
  });

  final List<OrderItemEntity> products;
  final bool initiallyExpanded;

  @override
  State<OrderProductsList> createState() => _OrderProductsListState();
}

class _OrderProductsListState extends State<OrderProductsList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  late final Animation<double> _arrowAnimation;
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: _isExpanded ? 1.0 : 0.0,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    _arrowAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(_expandAnimation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    if (_isExpanded) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    _isExpanded = !_isExpanded;
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _toggleExpand,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 6.w,
                children: [
                  Text(
                    AppStrings.orderedItems,
                    style: AppTextStyles.font14Bold.copyWith(
                      color: context.colors.mainText,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 7.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      '${widget.products.length}',
                      style: AppTextStyles.font12Bold.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              RotationTransition(
                turns: _arrowAnimation,
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 22.sp,
                  color: context.colors.subText,
                ),
              ),
            ],
          ),
        ),
      ),
      SizeTransition(
        sizeFactor: _expandAnimation,
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(top: 8.h),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.products.length,
            separatorBuilder: (context, index) => Gap(8.h),
            itemBuilder: (context, index) =>
                OrderProductCard(product: widget.products[index]),
          ),
        ),
      ),
    ],
  );
}
