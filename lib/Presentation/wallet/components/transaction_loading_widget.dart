import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Presentation/Loading/loading_text.dart';

class TransactionsWidgetLoading extends StatefulWidget {
  const TransactionsWidgetLoading({
    super.key,
  });

  @override
  State<TransactionsWidgetLoading> createState() =>
      _TransactionsWidgetLoadingState();
}

class _TransactionsWidgetLoadingState extends State<TransactionsWidgetLoading> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: Container(
          width: AppSize(context).width * .12,
          height: AppSize(context).width * .12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: AppColors.greyColorback,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SvgPicture.asset(
              "assets/icon/moneyP.svg",
              height: 15,
              width: 15,
            ),
          ),
        ),
        title: const LoadingText(
          width: 100,
          height: 10,
        ),
        subtitle: const SizedBox(
          child: LoadingText(
            width: 60,
            height: 10,
          ),
        ),
        trailing: const LoadingText(
          width: 60,
          height: 30,
        ));
  }
}
