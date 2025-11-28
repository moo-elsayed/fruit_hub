import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fruit_hub/features/cart/domain/entities/cart_item_entity.dart';
import 'package:fruit_hub/features/cart/presentation/managers/cart_cubit/cart_cubit.dart';
import 'package:fruit_hub/features/cart/presentation/widgets/cart_item_action_buttons.dart';
import 'package:fruit_hub/generated/assets.dart';
import 'package:gap/gap.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/widgets/custom_network_image.dart';
import '../../../products/presentation/views/product_details_view.dart';

class CartItem extends StatelessWidget {
  const CartItem({super.key, required this.size, required this.cartItemEntity});

  final Size size;
  final CartItemEntity cartItemEntity;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
          context,
          settings: const RouteSettings(name: Routes.productDetailsView),
          screen: ProductDetailsView(fruitEntity: cartItemEntity.fruitEntity),
          withNavBar: false,
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      },
      child: Container(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 16.w),
        height: size.height * 0.11699,
        child: Row(
          children: [
            Container(
              width: size.width * 0.19466,
              height: size.height * 0.1133,
              padding: EdgeInsetsGeometry.symmetric(horizontal: 10.w),
              color: AppColors.colorF3F5F7,
              child: CustomNetworkImage(
                image: cartItemEntity.fruitEntity.imagePath,
              ),
            ),
            Gap(17.w),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 5.h),
                child: Column(
                  crossAxisAlignment: .start,
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: .spaceBetween,
                      crossAxisAlignment: .start,
                      children: [
                        Column(
                          spacing: 3.h,
                          crossAxisAlignment: .start,
                          children: [
                            Text(
                              cartItemEntity.fruitEntity.name,
                              style: AppTextStyles.font13color06161CBold,
                            ),
                            Text(
                              "${cartItemEntity.quantity} ${"per_kilo".tr()}",
                              style: AppTextStyles.font13colorF4A91FRegular,
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            context.read<CartCubit>().removeItemFromCart(
                              cartItemEntity.fruitEntity.code,
                            );
                          },
                          child: SvgPicture.asset(Assets.iconsTrash),
                        ),
                      ],
                    ),
                    CartItemActionButtons(cartItemEntity: cartItemEntity),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
