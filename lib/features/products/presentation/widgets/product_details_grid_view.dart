import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../domain/entities/product_details_entity.dart';

class ProductDetailsGridView extends StatelessWidget {
  const ProductDetailsGridView({super.key, required this.productDetails});

  final List<ProductDetailsEntity> productDetails;

  @override
  Widget build(BuildContext context) => GridView.builder(
    physics: const NeverScrollableScrollPhysics(),
    padding: .only(top: 16.h, bottom: 24.h),
    itemCount: productDetails.length,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 16.w,
      mainAxisSpacing: 16.h,
      childAspectRatio: 163 / 80,
    ),
    itemBuilder: (context, index) {
      final productDetail = productDetails[index];
      return Container(
        padding: const .symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: .all(.circular(16.r)),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          mainAxisAlignment: .center,
          spacing: 16.w,
          children: [
            Column(
              mainAxisAlignment: .spaceBetween,
              crossAxisAlignment: .start,
              children: [
                index == productDetails.length - 1
                    ? RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: productDetail.title.split(' ').first,
                              style: AppTextStyles.font16Bold.copyWith(
                                color: context.colors.primary,
                              ),
                            ),
                            const TextSpan(text: ' '),
                            TextSpan(
                              text: productDetail.title.split(' ').last,
                              style: AppTextStyles.font14Medium.copyWith(
                                color: context.colors.subText,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Text(
                        productDetail.title,
                        style: AppTextStyles.font16Bold.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                Text(
                  productDetail.subtitle,
                  style: AppTextStyles.font14Medium.copyWith(
                    color: context.colors.subText,
                  ),
                ),
              ],
            ),
            SvgPicture.asset(productDetail.trailingAsset),
          ],
        ),
      );
    },
  );
}
