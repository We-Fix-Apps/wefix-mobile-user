import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/LanguageProvider/l10n_provider.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Presentation/Loading/loading_text.dart';

class TransactionsWidget extends StatefulWidget {
  final String name;
  final String date;
  final String status;
  final String statusAr;

  final String value;
  // final Transaction? transaction;
  final bool? loading;

  const TransactionsWidget(
      {super.key,
      required this.name,
      required this.statusAr,
      required this.date,
      required this.status,
      required this.value,
      this.loading});

  @override
  State<TransactionsWidget> createState() => _TransactionsWidgetState();
}

class _TransactionsWidgetState extends State<TransactionsWidget> {
  @override
  Widget build(BuildContext context) {
    LanguageProvider languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
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
            "assets/icon/cash.svg",
            // color: AppColors(context).primaryColor,
            height: 15,
            width: 15,
          ),
        ),
      ),
      title: widget.loading == true
          ? const LoadingText(
              width: 100,
              height: 50,
            )
          : Text(
              widget.name,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppSize(context).smallText1),
            ),
      subtitle: widget.loading == true
          ? const LoadingText(
              width: 100,
              height: 50,
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.date,
                  style: const TextStyle(
                    color: AppColors.greyColor2,
                  ),
                ),
                Text(
                  languageProvider.lang == "ar"
                      ? widget.statusAr
                      : widget.status,
                  style: TextStyle(
                    color: widget.status == "Completd"
                        ? AppColors.greenColor
                        : widget.status == "Pending"
                            ? AppColors(context).primaryColor
                            : AppColors.redColor,
                  ),
                ),
              ],
            ),
      trailing: widget.loading == true
          ? const LoadingText(
              width: 100,
              height: 50,
            )
          : Text(
              "${widget.value} ${AppText(context).jod}",
              style: TextStyle(
                color: widget.name == "Deposit"
                    ? AppColors.greenColor
                    : AppColors.redColor,
                fontSize: AppSize(context).smallText1,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}
