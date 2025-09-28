// import 'package:cartizy_app_nti/core/theming/colors_manager.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// import '../theming/styles.dart';
//
// class TextFormFieldHelper extends StatefulWidget {
//   final TextEditingController? controller;
//   final bool isPassword;
//   final String? hint, obscuringCharacter;
//   final bool enabled;
//   final int? maxLines, minLines, maxLength;
//   final String? Function(String? value)? onValidate;
//   final void Function(String?)? onChanged, onFieldSubmitted, onSaved;
//   final void Function()? onEditingComplete, onTap;
//   final TextInputType? keyboardType;
//   final List<TextInputFormatter>? inputFormatters;
//   final Widget? suffixWidget, prefixIcon, prefix;
//   final IconData? icon;
//   final TextInputAction? action;
//   final FocusNode? focusNode;
//   final EdgeInsetsGeometry? contentPadding;
//   final BorderRadius? borderRadius;
//   final bool? isMobile;
//   final Color? borderColor;
//
//   const TextFormFieldHelper({
//     super.key,
//     this.controller,
//     this.isPassword = false,
//     this.hint,
//     this.enabled = true,
//     this.obscuringCharacter,
//     this.onValidate,
//     this.onChanged,
//     this.onFieldSubmitted,
//     this.onEditingComplete,
//     this.onSaved,
//     this.onTap,
//     this.maxLines = 1,
//     this.minLines = 1,
//     this.maxLength,
//     this.keyboardType,
//     this.inputFormatters,
//     this.suffixWidget,
//     this.icon,
//     this.prefixIcon,
//     this.prefix,
//     this.action,
//     this.focusNode,
//     this.borderRadius,
//     this.isMobile = true,
//     this.contentPadding,
//     this.borderColor,
//   });
//
//   @override
//   State<TextFormFieldHelper> createState() => _TextFormFieldHelperState();
// }
//
// class _TextFormFieldHelperState extends State<TextFormFieldHelper> {
//   late bool obscureText;
//   TextDirection _textDirection = TextDirection.rtl;
//
//   @override
//   void initState() {
//     super.initState();
//     obscureText = widget.isPassword;
//   }
//
//   void _toggleObscureText() {
//     setState(() => obscureText = !obscureText);
//   }
//
//   void _updateTextDirection(String text) {
//     if (text.isEmpty) return;
//     final isArabic = RegExp(r'^[\u0600-\u06FF]').hasMatch(text);
//     setState(() {
//       _textDirection = isArabic ? TextDirection.rtl : TextDirection.ltr;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: widget.controller,
//       validator: widget.onValidate,
//       onChanged: (text) {
//         widget.onChanged?.call(text);
//         _updateTextDirection(text);
//       },
//       onEditingComplete: widget.onEditingComplete,
//       onFieldSubmitted: widget.onFieldSubmitted,
//       onSaved: widget.onSaved,
//       onTap: widget.onTap,
//       maxLines: widget.maxLines,
//       minLines: widget.minLines,
//       maxLength: widget.maxLength,
//       obscureText: obscureText,
//       obscuringCharacter: widget.obscuringCharacter ?? '*',
//
//       keyboardType: widget.keyboardType,
//       inputFormatters: widget.inputFormatters,
//       enabled: widget.enabled,
//       textInputAction: widget.action ?? TextInputAction.next,
//       focusNode: widget.focusNode,
//       autovalidateMode: AutovalidateMode.onUserInteraction,
//
//       style: TextStylesManager.font14color212121Regular,
//       textAlign: widget.isMobile != null ? TextAlign.left : TextAlign.start,
//
//       textDirection: widget.isMobile != null
//           ? TextDirection.ltr
//           : _textDirection,
//       textAlignVertical: TextAlignVertical.center,
//       decoration: InputDecoration(
//         fillColor: ColorsManager.colorEBEBEB,
//         filled: true,
//         hintText: widget.hint,
//         hintStyle: TextStylesManager.font14color212121Regular,
//         errorMaxLines: 4,
//         errorStyle: TextStylesManager.font14color212121Regular.copyWith(
//           color: Colors.red,
//         ),
//         prefixIcon: widget.prefixIcon,
//         prefix: widget.prefix,
//         suffixIcon: widget.isPassword
//             ? GestureDetector(
//                 onTap: _toggleObscureText,
//                 child: Icon(
//                   obscureText ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
//                   color: ColorsManager.color212121,
//                   size: 24.r,
//                 ),
//               )
//             : widget.suffixWidget,
//         contentPadding:
//             widget.contentPadding ??
//             EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
//         border: outlineInputBorder(color: ColorsManager.color636363, width: 1),
//         enabledBorder: outlineInputBorder(
//           color: widget.borderColor ?? ColorsManager.color636363,
//           width: 1,
//         ),
//         focusedBorder: outlineInputBorder(
//           color: widget.borderColor ?? ColorsManager.color636363,
//           width: 1,
//         ),
//         errorBorder: outlineInputBorder(color: Colors.red, width: 1),
//         focusedErrorBorder: outlineInputBorder(color: Colors.red, width: 1),
//       ),
//     );
//   }
//
//   OutlineInputBorder outlineInputBorder({
//     required Color color,
//     required double width,
//   }) {
//     return OutlineInputBorder(
//       borderRadius: widget.borderRadius ?? BorderRadius.circular(40.r),
//       borderSide: BorderSide(color: color, width: width),
//     );
//   }
// }
