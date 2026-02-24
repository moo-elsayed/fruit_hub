import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../domain/entities/product_details_entity.dart';

class ProductDetailsGridView extends StatelessWidget {
  const ProductDetailsGridView({super.key, required this.productDetails});

  final List<ProductDetailsEntity> productDetails;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
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
        var productDetail = productDetails[index];
        return Container(
          padding: const .symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: .all(.circular(16.r)),
            border: Border.all(color: AppColors.colorF1F1F5),
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
                                text: productDetail.title.split(" ").first,
                                style: AppTextStyles.font16color23AA49Bold,
                              ),
                              const TextSpan(text: " "),
                              TextSpan(
                                text: productDetail.title.split(" ").last,
                                style: AppTextStyles.font14color979899Medium,
                              ),
                            ],
                          ),
                        )
                      : Text(
                          productDetail.title,
                          style: AppTextStyles.font16color23AA49Bold,
                        ),
                  Text(
                    productDetail.subtitle,
                    style: AppTextStyles.font14color979899Medium,
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
}
