import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';

class WidgetTextField extends StatelessWidget {
  final String? hintText;
  final String? errorText;
  final bool obscureText;
  final Function(String)? onFieldSubmitted;
  final Widget? prefixIcon;
  final String? Function(dynamic)? validator;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final FocusNode? focusNode;
  final Color? fillColor;
  final int? maxLength;
  final int maxLines;
  final double? radius;
  final bool? readOnly;
  final EdgeInsetsGeometry? padding;
  final bool? haveBorder;
  final InputBorder? border;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final Function()? onTap;
  final List<TextInputFormatter>? inputFormatters;
  const WidgetTextField(
    this.hintText, {
    this.onChanged,
    this.readOnly,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.controller,
    this.validator,
    this.focusNode,
    this.maxLines = 1,
    this.maxLength,
    Key? key,
    this.fillColor,
    this.haveBorder,
    this.padding,
    this.onTap,
    this.hintStyle,
    this.radius,
    this.textStyle,
    this.inputFormatters,
    this.errorText,
    this.border,
    this.onFieldSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: maxLines,
      maxLength: maxLength,
      onChanged: onChanged,
      keyboardType: keyboardType,
      controller: controller,
      obscureText: obscureText,
      readOnly: readOnly ?? false,
      onFieldSubmitted: onFieldSubmitted,
      onTap: onTap,
      validator: validator,
      inputFormatters: inputFormatters,
      focusNode: focusNode,
      cursorColor: AppColors(context).primaryColor,
      textInputAction: TextInputAction.done,
      style: textStyle ?? TextStyle(fontSize: AppSize(context).smallText1),
      decoration: InputDecoration(
        hoverColor: AppColors(context).primaryColor,
        errorText: errorText,
        counter: const SizedBox(),
        hintStyle: hintStyle ??
            TextStyle(
                color: AppColors.greyColor3,
                fontSize: AppSize(context).smallText3,
                letterSpacing: .5),
        contentPadding: padding ?? const EdgeInsets.all(10.0),
        fillColor: fillColor ?? AppColors.backgroundColor,
        filled: true,
        prefixIcon: prefixIcon,
        hintText: hintText,
        suffixIcon: suffixIcon,
        border: border ??
            (haveBorder == false
                ? InputBorder.none
                : OutlineInputBorder(
                    gapPadding: 0,
                    borderSide: const BorderSide(color: AppColors.greyColor3),
                    borderRadius: BorderRadius.circular(radius ?? 7))),
        focusedBorder: OutlineInputBorder(
            gapPadding: 0,
            borderSide: BorderSide(
                color: haveBorder == null
                    ? AppColors.greyColor3
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(radius ?? 7)),
        errorBorder: OutlineInputBorder(
            gapPadding: 0,
            borderSide: const BorderSide(color: AppColors.redColor),
            borderRadius: BorderRadius.circular(radius ?? 7)),
        disabledBorder: OutlineInputBorder(
            gapPadding: 0,
            borderSide: BorderSide(
                color: haveBorder == null
                    ? AppColors.greyColor3
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(radius ?? 7)),
        enabledBorder: OutlineInputBorder(
            gapPadding: 0,
            borderSide: BorderSide(
                color: haveBorder == null
                    ? AppColors.greyColor3
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(radius ?? 7)),
      ),
    );
  }
}
