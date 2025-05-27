import 'package:flutter/material.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Presentation/Loading/loading_text.dart';

class MEssagesLoadingContact extends StatelessWidget {
  const MEssagesLoadingContact({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (context, index) => const Divider(
        color: AppColors.greyColor1,
        height: 1,
      ),
      itemCount: 6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return ListTile(
          onTap: () {},
          trailing: const Icon(Icons.arrow_forward_ios_rounded),
          title: const LoadingText(width: 100),
          // ignore: prefer_const_constructors
          subtitle: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(
                height: 5,
              ),
              LoadingText(width: 30),
              SizedBox(
                height: 5,
              ),
              LoadingText(width: 50)
            ],
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.lightGreyColor,
                )),
            child: LoadingText(
              width: AppSize(context).width * .15,
              height: AppSize(context).height * .7,
            ),
          ),
        );
      },
    );
  }
}
