import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/appText/appText.dart';

class ListRateTypeWidget extends StatelessWidget {
  final String? title;
  final String? selectedRating;
  final Function(String)? onRatingSelected;

  const ListRateTypeWidget({
    super.key,
    this.title,
    this.selectedRating,
    this.onRatingSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: AppSize(context).width * 0.5,
                child: Text(
                  title ?? "",
                  style: TextStyle(
                    fontSize: AppSize(context).mediumText3,
                    color: AppColors(context).primaryColor,
                  ),
                ),
              ),
              Row(
                children: [
                  _buildFace(
                    context,
                    iconPath: "assets/icon/smile.svg",
                    color: AppColors.greenColor,
                    label: AppText(context).happy,
                  ),
                  const SizedBox(width: 5),
                  _buildFace(
                    context,
                    iconPath: "assets/icon/good.svg",
                    color: AppColors(context).primaryColor,
                    label: AppText(context).good,
                  ),
                  const SizedBox(width: 5),
                  _buildFace(
                    context,
                    iconPath: "assets/icon/sadface.svg",
                    color: AppColors.redColor,
                    label: AppText(context).bad,
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFace(BuildContext context,
      {required String iconPath, required Color color, required String label}) {
    final isSelected = selectedRating == label;
    return InkWell(
      onTap: () => onRatingSelected?.call(label),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
        ),
        child: SvgPicture.asset(
          iconPath,
          color: isSelected ? color : color.withOpacity(0.5),
          width: 30,
          height: 30,
        ),
      ),
    );
  }
}
