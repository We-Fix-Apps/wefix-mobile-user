import 'package:flutter/material.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Presentation/Loading/loading_text.dart';

class LoadingHomeCategory extends StatefulWidget {
  const LoadingHomeCategory({super.key});

  @override
  State<LoadingHomeCategory> createState() => _LoadingHomeCategoryState();
}

class _LoadingHomeCategoryState extends State<LoadingHomeCategory> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSize(context).height * .13,
      child: ListView.separated(
        itemCount: 6,
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) =>
            SizedBox(width: AppSize(context).width * 0.02),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(1.0),
            child: Column(
              children: [
                Container(
                  width: AppSize(context).width * .16,
                  height: AppSize(context).width * .16,
                  decoration: BoxDecoration(
                    color: AppColors.greyColor,
                    borderRadius: BorderRadius.circular(1000),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: LoadingText(width: AppSize(context).width),
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      LoadingText(width: AppSize(context).width * 0.13),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
