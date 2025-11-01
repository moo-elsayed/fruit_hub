import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fruit_hub/core/theming/app_colors.dart';
import '../theming/app_text_styles.dart';

class TextFormFieldHelper extends StatefulWidget {
  const TextFormFieldHelper({
    super.key,
    this.controller,
    this.isPassword = false,
    this.hint,
    this.enabled = true,
    this.obscuringCharacter,
    this.onValidate,
    this.onChanged,
    this.onFieldSubmitted,
    this.onEditingComplete,
    this.onSaved,
    this.onTap,
    this.maxLines = 1,
    this.minLines = 1,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
    this.suffixWidget,
    this.icon,
    this.prefixIcon,
    this.prefix,
    this.action,
    this.focusNode,
    this.borderRadius,
    this.contentPadding,
    this.borderColor,
    this.fillColor,
    this.hintStyle,
  });

  final TextEditingController? controller;
  final bool isPassword;
  final String? hint, obscuringCharacter;
  final bool enabled;
  final int? maxLines, minLines, maxLength;
  final String? Function(String? value)? onValidate;
  final void Function(String?)? onChanged, onFieldSubmitted, onSaved;
  final void Function()? onEditingComplete, onTap;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffixWidget, prefixIcon, prefix;
  final IconData? icon;
  final TextInputAction? action;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? contentPadding;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final Color? fillColor;
  final TextStyle? hintStyle;

  @override
  State<TextFormFieldHelper> createState() => _TextFormFieldHelperState();
}

class _TextFormFieldHelperState extends State<TextFormFieldHelper> {
  late bool _obscureText;
  late TextDirection _textDirection = Directionality.of(context);

  void _toggleObscureText() => setState(() => _obscureText = !_obscureText);

  void _updateTextDirection(String text) {
    if (text.isEmpty) {
      setState(() {
        _textDirection = Directionality.of(context);
      });
      return;
    }
    final isTextArabic = RegExp(r'^[\u0600-\u06FF]').hasMatch(text);
    setState(() {
      _textDirection = isTextArabic ? TextDirection.rtl : TextDirection.ltr;
    });
  }

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.onValidate,
      onChanged: (text) {
        widget.onChanged?.call(text);
        _updateTextDirection(text);
      },
      onEditingComplete: widget.onEditingComplete,
      onFieldSubmitted: widget.onFieldSubmitted,
      onSaved: widget.onSaved,
      onTap: widget.onTap,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      obscureText: _obscureText,
      obscuringCharacter: widget.obscuringCharacter ?? '*',
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      enabled: widget.enabled,
      cursorColor: AppColors.color1B5E37,
      textInputAction: widget.action ?? TextInputAction.next,
      focusNode: widget.focusNode,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: AppTextStyles.font16color0C0D0DSemiBold,
      textDirection: _textDirection,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        fillColor: widget.fillColor ?? AppColors.colorF9FAFA,
        filled: true,
        hintText: widget.hint,
        hintStyle: widget.hintStyle ?? AppTextStyles.font13color949D9EBold,
        errorMaxLines: 4,
        errorStyle: AppTextStyles.font16color0C0D0DSemiBold.copyWith(
          color: Colors.red,
        ),
        prefixIcon: widget.prefixIcon,
        prefix: widget.prefix,
        suffixIcon: widget.isPassword
            ? GestureDetector(
                onTap: _toggleObscureText,
                child: Icon(
                  _obscureText
                      ? Icons.remove_red_eye
                      : Icons.remove_red_eye_outlined,
                  color: AppColors.colorC9CECF,
                  size: 24.r,
                ),
              )
            : widget.suffixWidget,
        contentPadding:
            widget.contentPadding ??
            EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
        border: outlineInputBorder(color: AppColors.colorE6E9EA, width: 1),
        enabledBorder: outlineInputBorder(
          color: widget.borderColor ?? AppColors.colorE6E9EA,
          width: 1,
        ),
        disabledBorder: outlineInputBorder(
          color: widget.borderColor ?? AppColors.colorE6E9EA,
          width: 1,
        ),
        focusedBorder: outlineInputBorder(
          color: widget.borderColor ?? AppColors.colorE6E9EA,
          width: 1,
        ),
        errorBorder: outlineInputBorder(color: Colors.red, width: 1),
        focusedErrorBorder: outlineInputBorder(color: Colors.red, width: 1),
      ),
    );
  }

  OutlineInputBorder outlineInputBorder({
    required Color color,
    required double width,
  }) {
    return OutlineInputBorder(
      borderRadius: widget.borderRadius ?? BorderRadius.circular(8.r),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
