import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Presentation/Loading/loading_text.dart';

class LoadingCategory extends StatefulWidget {
  const LoadingCategory({super.key});

  @override
  State<LoadingCategory> createState() => _LoadingCategoryState();
}

class _LoadingCategoryState extends State<LoadingCategory> {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 10,
      separatorBuilder: (context, index) =>
          SizedBox(height: AppSize(context).height * 0.01),
      itemBuilder: (context, index) {
        return Container(
          height: AppSize(context).height * .08,
          width: double.infinity,
          decoration: BoxDecoration(
              color: AppColors.greyColorback,
              borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: CircleAvatar(
                    radius: 25,
                    backgroundColor: AppColors.greyColor,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: LoadingText(width: 5),
                    )),
              ),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                  child: Row(
                children: [
                  LoadingText(width: AppSize(context).width * 0.4),
                ],
              )),
              SvgPicture.asset("assets/icon/arrowright2.svg"),
              const SizedBox(width: 10)
            ],
          ),
        );
      },
    );
  }
}
