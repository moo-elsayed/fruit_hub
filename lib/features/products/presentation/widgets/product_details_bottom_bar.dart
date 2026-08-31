import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/entities/fruit_entity.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/theming/app_palette.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/widgets/custom_material_button.dart';
import 'package:fruit_hub/core/widgets/custom_price_text.dart';
import 'package:fruit_hub/core/widgets/custom_quantity_selector.dart';
import 'package:fruit_hub/features/cart/presentation/managers/cart_cubit/cart_cubit.dart';
import 'package:fruit_hub/features/main/presentation/managers/main_tab_notifier.dart';
import 'package:gap/gap.dart';

class ProductDetailsBottomBar extends StatelessWidget {
  const ProductDetailsBottomBar({
    super.key,
    required this.fruit,
    required this.quantityNotifier,
    required this.onAddToCart,
  });

  final FruitEntity fruit;
  final ValueNotifier<int> quantityNotifier;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) => BlocBuilder<CartCubit, CartState>(
    buildWhen: (previous, current) =>
        current is CartSuccess || current is CartInitial,
    builder: (context, state) {
      final cartCubit = context.read<CartCubit>();
      final cartItem = cartCubit.getCartItem(fruit.code);
      final bool isInCart = cartItem != null;

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          border: Border(
            top: BorderSide(color: context.colors.border, width: 1.w),
          ),
          boxShadow: [
            BoxShadow(
              color: context.colors.mainText.withValues(alpha: 0.04),
              blurRadius: 16.r,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isInCart)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomQuantitySelector(
                      isLarge: true,
                      quantity: cartItem.quantity,
                      onIncrement: () {
                        cartCubit.incrementItemQuantity(fruit.code);
                        quantityNotifier.value = cartItem.quantity + 1;
                      },
                      onDecrement: () {
                        cartCubit.decrementItemQuantity(fruit.code);
                        quantityNotifier.value = cartItem.quantity > 1
                            ? cartItem.quantity - 1
                            : 1;
                      },
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          AppStrings.total,
                          style: AppTextStyles.font12Medium.copyWith(
                            color: context.colors.subText,
                          ),
                        ),
                        Gap(2.h),
                        CustomPriceText(
                          price: fruit.price * cartItem.quantity,
                          isLarge: true,
                        ),
                      ],
                    ),
                  ],
                )
              else
                ValueListenableBuilder<int>(
                  valueListenable: quantityNotifier,
                  builder: (context, quantity, _) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomQuantitySelector(
                        isLarge: true,
                        quantity: quantity,
                        isDecrementEnabled: quantity > 1,
                        onIncrement: () =>
                            quantityNotifier.value = quantity + 1,
                        onDecrement: () {
                          if (quantity > 1) {
                            quantityNotifier.value = quantity - 1;
                          }
                        },
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            AppStrings.total,
                            style: AppTextStyles.font12Medium.copyWith(
                              color: context.colors.subText,
                            ),
                          ),
                          Gap(2.h),
                          CustomPriceText(
                            price: fruit.price * quantity,
                            isLarge: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              Gap(14.h),
              CustomMaterialButton(
                onPressed: isInCart
                    ? () {
                        MainTabNotifier.switchToTab(2);
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                        } else {
                          context.pushReplacementNamed(
                            Routes.mainView,
                            arguments: 2,
                          );
                        }
                      }
                    : onAddToCart,
                text: isInCart ? AppStrings.viewCart : AppStrings.addToCart,
                maxWidth: true,
                borderRadius: BorderRadius.circular(16.r),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                textStyle: AppTextStyles.font16Bold.copyWith(
                  color: AppPalette.white,
                ),
                icon: Icon(
                  isInCart
                      ? CupertinoIcons.cart_fill
                      : CupertinoIcons.cart_badge_plus,
                  color: AppPalette.white,
                  size: 20.sp,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
