import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../helpers/extensions.dart';
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
    this.labelText,
    this.labelStyle,
    this.style,
    this.suffixText,
    this.suffixStyle,
    this.readOnly = false,
    this.textAlign = TextAlign.start,
  });

  final TextAlign textAlign;

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
  final String? labelText;
  final TextStyle? labelStyle;
  final TextStyle? style;
  final String? suffixText;
  final TextStyle? suffixStyle;
  final bool readOnly;

  @override
  State<TextFormFieldHelper> createState() => _TextFormFieldHelperState();
}

class _TextFormFieldHelperState extends State<TextFormFieldHelper> {
  late bool _obscureText;
  late TextDirection _textDirection;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _textDirection = Directionality.of(context);
  }

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: Theme.of(context).copyWith(
      textSelectionTheme: TextSelectionThemeData(
        selectionHandleColor: context.colors.primary,
        cursorColor: context.colors.primary,
        selectionColor: context.colors.primary.withValues(alpha: 0.3),
      ),
    ),
    child: TextFormField(
      readOnly: widget.readOnly,
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
      textInputAction: widget.action ?? TextInputAction.next,
      focusNode: widget.focusNode,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textAlign: widget.textAlign,
      style:
          widget.style ??
          AppTextStyles.font14Regular.copyWith(color: context.colors.mainText),
      textDirection: _textDirection,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        isDense: true,
        suffixText: widget.suffixText,
        suffixStyle: widget.suffixStyle,
        fillColor: widget.fillColor ?? context.colors.surface,
        filled: true,
        hintText: widget.hint,
        hintStyle:
            widget.hintStyle ??
            AppTextStyles.font14Regular.copyWith(color: context.colors.subText),
        errorMaxLines: 4,
        errorStyle: AppTextStyles.font12Regular.copyWith(
          color: context.colors.error,
        ),
        labelText: widget.labelText,
        labelStyle: widget.labelStyle,
        prefixIcon: widget.prefixIcon,
        prefixIconConstraints: BoxConstraints(minWidth: 36.w, minHeight: 36.h),
        prefix: widget.prefix,
        suffixIconConstraints: BoxConstraints(minWidth: 40.w, minHeight: 36.h),
        suffixIcon: widget.isPassword
            ? GestureDetector(
                onTap: _toggleObscureText,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) =>
                            ScaleTransition(scale: animation, child: child),
                    child: Icon(
                      key: ValueKey<bool>(_obscureText),
                      _obscureText
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: context.colors.subText,
                      size: 20.sp,
                    ),
                  ),
                ),
              )
            : widget.suffixWidget,
        contentPadding:
            widget.contentPadding ??
            EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),

        border: outlineInputBorder(
          color: widget.borderColor ?? context.colors.border,
          width: 1,
        ),
        enabledBorder: outlineInputBorder(
          color: widget.borderColor ?? context.colors.border,
          width: 1,
        ),
        focusedBorder: outlineInputBorder(
          color: widget.borderColor ?? context.colors.primary,
          width: 1.3,
        ),
        errorBorder: outlineInputBorder(color: context.colors.error, width: 1),
        focusedErrorBorder: outlineInputBorder(
          color: context.colors.error,
          width: 1,
        ),
      ),
    ),
  );

  OutlineInputBorder outlineInputBorder({
    required Color color,
    required double width,
  }) => OutlineInputBorder(
    borderRadius: widget.borderRadius ?? BorderRadius.circular(8.r),
    borderSide: BorderSide(color: color, width: width),
  );
}
