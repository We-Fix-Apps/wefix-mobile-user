import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';

class PaymentsOptions extends StatelessWidget {
  final String icon;
  final String title;
  final bool selected;
  const PaymentsOptions(
      {super.key,
      required this.icon,
      required this.title,
      required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.whiteColor1,
        border: Border.all(
            color: selected
                ? AppColors(context).primaryColor
                : AppColors.backgroundColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            icon,
            width: 30,
            height: 30,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
          Radio(
            value: selected,
            groupValue: true,
            onChanged: (value) {},
            fillColor:
                WidgetStatePropertyAll(AppColors(context).primaryColor),
          ),
        ],
      ),
    );
  }
}
