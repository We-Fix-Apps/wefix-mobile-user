import 'package:flutter/material.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';

class WidgetCard extends StatefulWidget {
  final String title;
  final Function()? onTap;
  const WidgetCard({super.key, required this.title, this.onTap});

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
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.greyColorback,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontSize: AppSize(context).smallText1,
                color: AppColors.blackColor1,
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_outlined,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
