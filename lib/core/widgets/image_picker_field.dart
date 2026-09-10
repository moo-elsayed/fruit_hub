import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/helpers/app_logger.dart';
import 'package:fruit_hub/core/helpers/app_strings.dart';
import 'package:fruit_hub/core/helpers/extensions.dart';
import 'package:fruit_hub/core/routing/routes.dart';
import 'package:fruit_hub/core/theming/app_palette.dart';
import 'package:fruit_hub/core/theming/app_text_styles.dart';
import 'package:fruit_hub/core/utils/custom_bottom_sheet_selection_item.dart';
import 'package:fruit_hub/core/utils/full_screen_image_gallery_input_item.dart';
import 'package:fruit_hub/core/widgets/app_toasts.dart';
import 'package:fruit_hub/core/widgets/custom_bottom_sheet.dart';
import 'package:fruit_hub/core/widgets/edit_delete_actions_button.dart';
import 'package:fruit_hub/core/widgets/image_picker_thumbnail.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toastification/toastification.dart';

class ImagePickerField extends StatelessWidget {
  const ImagePickerField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;

  static Future<void> pickImage({
    required BuildContext context,
    required TextEditingController controller,
    required ImageSource source,
    FormFieldState<String>? state,
  }) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (image != null) {
        controller.text = image.path;
        state?.didChange(image.path);
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to pick image: $e',
        error: e,
        stackTrace: stackTrace,
      );
      if (context.mounted) {
        AppToast.show(
          context: context,
          title: AppStrings.unexpectedError,
          type: ToastificationType.error,
        );
      }
    }
  }

  static void showPicker({
    required BuildContext context,
    required TextEditingController controller,
    FormFieldState<String>? state,
  }) => CustomBottomSheet.show(
    context: context,
    title: AppStrings.chooseImageSource,
    items: [
      CustomBottomSheetSelectionItem(
        title: AppStrings.camera,
        icon: Icons.camera_alt_rounded,
        onTap: () => pickImage(
          context: context,
          controller: controller,
          source: ImageSource.camera,
          state: state,
        ),
      ),
      CustomBottomSheetSelectionItem(
        title: AppStrings.gallery,
        icon: Icons.photo_library_rounded,
        onTap: () => pickImage(
          context: context,
          controller: controller,
          source: ImageSource.gallery,
          state: state,
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => FormField<String>(
    validator: validator,
    initialValue: controller.text,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    builder: (FormFieldState<String> state) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ValueListenableBuilder(
          valueListenable: controller,
          builder: (_, value, _) {
            final hasImage = controller.text.isNotEmpty;
            final borderColor = state.hasError
                ? context.colors.error
                : hasImage
                ? context.colors.primary.withValues(alpha: 0.3)
                : context.colors.border;

            return Material(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(12.r),
              child: GestureDetector(
                onTap: () => showPicker(
                  context: context,
                  controller: controller,
                  state: state,
                ),
                child: Container(
                  padding: hasImage
                      ? EdgeInsets.all(8.w)
                      : EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: borderColor,
                      width: hasImage || state.hasError ? 1.5 : 1,
                    ),
                  ),
                  child: hasImage
                      ? _FilledContent(
                          controller: controller,
                          label: label,
                          state: state,
                        )
                      : _EmptyContent(icon: icon, label: label),
                ),
              ),
            );
          },
        ),
        if (state.hasError)
          Padding(
            padding: EdgeInsets.only(top: 6.h, left: 12.w, right: 12.w),
            child: Text(
              state.errorText!,
              style: AppTextStyles.font12Regular.copyWith(
                color: context.colors.error,
              ),
            ),
          ),
      ],
    ),
  );
}

class _FilledContent extends StatelessWidget {
  const _FilledContent({
    required this.controller,
    required this.label,
    required this.state,
  });

  final TextEditingController controller;
  final String label;
  final FormFieldState<String> state;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      GestureDetector(
        onTap: () => context.pushNamed(
          Routes.fullScreenImageGalleryView,
          arguments: FullScreenImageGalleryInputItem(
            initialIndex: 0,
            imagesPaths: [controller.text],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Hero(
              tag: controller.text,
              child: ImagePickerThumbnail(path: controller.text),
            ),
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: AppPalette.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.visibility_rounded,
                color: AppPalette.white,
                size: 22.sp,
              ),
            ),
          ],
        ),
      ),
      Gap(14.w),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              controller.text.split(RegExp(r'[/\\]')).last,
              style: AppTextStyles.font13SemiBold.copyWith(
                color: context.colors.mainText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Gap(4.h),
            Text(
              label,
              style: AppTextStyles.font11Regular.copyWith(
                color: context.colors.subText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      EditDeleteActionButtons(
        onEdit: () => ImagePickerField.showPicker(
          context: context,
          controller: controller,
          state: state,
        ),
        onDelete: () {
          controller.clear();
          state.didChange('');
        },
      ),
    ],
  );
}

class _EmptyContent extends StatelessWidget {
  const _EmptyContent({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: context.colors.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: context.colors.primary, size: 22.sp),
      ),
      Gap(12.w),
      Expanded(
        child: Text(
          label,
          style: AppTextStyles.font14Medium.copyWith(
            color: context.colors.mainText,
          ),
        ),
      ),
      Icon(
        Icons.add_photo_alternate_outlined,
        color: context.colors.primary,
        size: 22.sp,
      ),
    ],
  );
}
