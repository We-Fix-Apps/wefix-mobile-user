import 'package:flutter/material.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';

class BoxWalletWidget extends StatefulWidget {
  final bool? hasBorder;
  final Color? bckgroundColor;
  final String? title;
  final String? subTitle;
  final String? textBut;
  final Function()? onTap;
  final Widget? icon;

  const BoxWalletWidget(
      {super.key,
      this.hasBorder,
      this.bckgroundColor,
      this.title,
      this.subTitle,
      this.icon,
      this.textBut,
      this.onTap});

  @override
  State<BoxWalletWidget> createState() => _BoxWalletWidgetState();
}

class _BoxWalletWidgetState extends State<BoxWalletWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSize(context).width * .5,
      height: AppSize(context).height * .2,
      decoration: BoxDecoration(
          border: Border.all(
              color: widget.hasBorder ?? false
                  ? AppColors.blackColor1
                  : AppColors.whiteColor1),
          color: widget.bckgroundColor ?? AppColors.whiteColor1,
          borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title ?? "",
              style: TextStyle(
                  fontSize: AppSize(context).largText4,
                  color: widget.hasBorder == false
                      ? AppColors.whiteColor1
                      : AppColors(context).primaryColor,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              widget.subTitle ?? "",
              style: TextStyle(
                color: widget.hasBorder == false
                    ? AppColors.whiteColor1
                    : AppColors.blackColor1,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                widget.icon ?? const SizedBox(),
                const SizedBox(
                  width: 3,
                ),
                InkWell(
                  onTap: widget.onTap,
                  child: Text(
                    widget.textBut ?? "",
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: AppSize(context).mediumText3,
                      color: widget.hasBorder == false
                          ? AppColors.whiteColor1
                          : AppColors.blackColor1,
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
