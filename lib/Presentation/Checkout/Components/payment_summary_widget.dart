import 'package:flutter/material.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';

class PaymentSummaryWidget extends StatelessWidget {
  final String title;
  final String value;

  final bool? highlight;
  final bool? bold;
  final IconData? icon;
  const PaymentSummaryWidget(
      {super.key,
      required this.title,
      required this.value,
      this.highlight,
      this.bold,
      this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text(title,
                    style: TextStyle(
                      color: highlight ?? false
                          ? AppColors.greenColor
                          : AppColors.blackColor1,
                      fontWeight:
                          bold ?? false ? FontWeight.bold : FontWeight.normal,
                    )),
                if (icon != null) ...[
                  const SizedBox(width: 4),
                  Icon(icon, size: 16, color: AppColors.greyColor),
                ]
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: highlight ?? false
                  ? AppColors.greenColor
                  : AppColors.blackColor1,
              fontWeight: bold ?? false ? FontWeight.bold : FontWeight.normal,
            ),
          )
        ],
      ),
    );
    ;
  }
}
