// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:fruit_hub/core/theming/app_colors.dart';
//
// abstract class AppDialogs {
//   static void showLoadingDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) {
//         return Dialog(
//           backgroundColor: AppColors.white,
//           shape: RoundedRectangleBorder(borderRadius: .circular(12.r)),
//           insetPadding: .symmetric(horizontal: 48.w),
//           child: Padding(
//             padding: .symmetric(vertical: 24.h, horizontal: 32.w),
//             child: Column(
//               mainAxisSize: .min,
//               children: [
//                 const CircularProgressIndicator(color: Colors.black),
//                 SizedBox(height: 16.h),
//                 const Text(
//                   'Loading...',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:gap/gap.dart';

abstract class AppDialogs {
  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: .symmetric(horizontal: 48.w),
            child: Container(
              padding: .symmetric(vertical: 24.h, horizontal: 24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: .circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: .min,
                children: [
                  SizedBox(
                    height: 30.h,
                    width: 30.w,
                    child: CupertinoActivityIndicator(radius: 14.r),
                  ),
                  Gap(16.h),
                  Text(
                    'loading'.tr(),
                    style: AppTextStyles.font13color0C0D0DSemiBold,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
