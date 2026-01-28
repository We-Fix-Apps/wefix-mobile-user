import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';

class WidgetCard extends StatefulWidget {
  final String title;
  final String? svg;
  final bool? isDelete;

  final Function()? onTap;
  const WidgetCard({super.key, required this.title, this.onTap, this.svg, this.isDelete = false});

  @override
  State<WidgetCard> createState() => _WidgetCardState();
}

class _WidgetCardState extends State<WidgetCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.greyColorback,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // SvgPicture.asset(
            //   widget.svg ?? "",
            //   width: 30,
            //   height: 30,
            // ),
            Text(
              widget.title,
              style: TextStyle(
                fontSize: AppSize(context).smallText1,
                color: widget.isDelete == true ? AppColors.redColor : AppColors.blackColor1,
                fontWeight: FontWeight.normal,
              ),
            ),
            const Spacer(),
            SvgPicture.asset(
              'assets/icon/arrowright2.svg',
              width: AppSize(context).width * .05,
              height: AppSize(context).height * .03,
            ),
          ],
        ),
      ),
    );
  }
}
