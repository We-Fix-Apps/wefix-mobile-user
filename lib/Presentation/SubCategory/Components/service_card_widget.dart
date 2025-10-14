import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/LanguageProvider/l10n_provider.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Data/model/sub_cat_model.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Components/custom_cach_network_image.dart';

class ServiceCardWidget extends StatefulWidget {
  bool? isDetails;
  bool? isAddedd;
  Function()? onTap;
  final Service? services;
  final bool? isSubsicribed;

  ServiceCardWidget({
    super.key,
    this.isAddedd,
    this.onTap,
    this.isDetails,
    this.services,
    this.isSubsicribed,
  });

  @override
  State<ServiceCardWidget> createState() => _ServiceCardWidgetState();
}

class _ServiceCardWidgetState extends State<ServiceCardWidget> {
  int count = 0;

  void increment() {
    setState(() {
      count++;
    });
  }

  void decrement() {
    if (count > 0) {
      setState(() {
        count--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    AppProvider appProvider = Provider.of<AppProvider>(context);
    LanguageProvider languageProvider =
        Provider.of<LanguageProvider>(context, listen: true);
    return Padding(
      key: widget.key,
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.whiteColor1,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: AppColors.greyColor1),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    WidgetCachNetworkImage(
                      image: widget.services?.icon ?? "",
                      width: 100,
                      height: 100,
                    ),
                    const SizedBox(width: 5),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: AppSize(context).width * .6,
                              child: Text(
                                languageProvider.lang == "ar"
                                    ? widget.services?.nameAr ?? ""
                                    : widget.services?.name ?? "Service Name",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                                style: TextStyle(
                                  fontSize: AppSize(context).smallText1,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSize(context).height * .01),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                widget.isSubsicribed == true
                                    ? Text(
                                        appProvider.userModel?.customer
                                                    .roleId ==
                                                2
                                            ? "${widget.services?.numOfTicket ?? ''} ${AppText(context).ticket}"
                                            : "${AppText(context).price} ${AppText(context).jod} ${widget.services?.subscriptionPrice}",
                                        style: TextStyle(
                                          color: AppColors.greyColor2,
                                          fontSize: AppSize(context).smallText3,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      )
                                    : Text(
                                        appProvider.userModel?.customer
                                                    .roleId ==
                                                2
                                            ? "${widget.services?.numOfTicket ?? ''} ${AppText(context).ticket}"
                                            : "${AppText(context).price} ${AppText(context).jod} ${widget.services?.discountPrice}",
                                        style: TextStyle(
                                          color: AppColors.greyColor2,
                                          fontSize: AppSize(context).smallText3,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                const SizedBox(width: 10),
                                appProvider.userModel?.customer.roleId == 2
                                    ? SizedBox()
                                    : (widget.isSubsicribed == false ||
                                            widget.isSubsicribed == null)
                                        ? const SizedBox()
                                        : Text(
                                            "${AppText(context).jod} ${widget.services?.price}",
                                            style: TextStyle(
                                              color: AppColors.greyColor2,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              fontSize:
                                                  AppSize(context).smallText3,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 1, color: AppColors.backgroundColor),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    languageProvider.lang == "ar"
                        ? widget.services?.descriptionAr ?? "---"
                        : widget.services?.description ?? "---",
                    style: TextStyle(
                      fontSize: AppSize(context).smallText4,
                      color: AppColors.greyColor2,
                    ),
                  ),
                ),
                widget.isDetails == false
                    ? count == 0
                        ? CustomBotton(
                            title: "Add",
                            height: AppSize(context).height * .04,
                            border: true,
                            borderColor: AppColors(context).primaryColor,
                            textColor: AppColors.whiteColor1,
                            color: AppColors(context).primaryColor,
                            onTap: increment,
                          )
                        : Container(
                            height: AppSize(context).height * .04,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: AppColors(context).primaryColor),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove,
                                      color: AppColors(context).primaryColor),
                                  onPressed: decrement,
                                ),
                                Text(
                                  "$count",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors(context).primaryColor,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add,
                                      color: AppColors(context).primaryColor),
                                  onPressed: increment,
                                ),
                              ],
                            ),
                          )
                    : CustomBotton(
                        title: widget.isAddedd == false
                            ? AppText(context).add
                            : AppText(context).remove,
                        height: AppSize(context).height * .04,
                        border: true,
                        borderColor: widget.isAddedd == true
                            ? AppColors.redColor
                            : AppColors(context).primaryColor,
                        textColor: widget.isAddedd == true
                            ? AppColors.redColor
                            : AppColors.whiteColor1,
                        color: widget.isAddedd == false
                            ? AppColors(context).primaryColor
                            : AppColors.whiteColor1,
                        onTap: widget.onTap,
                      )
              ],
            ),
          ),
          if (widget.isSubsicribed == true)
            appProvider.userModel?.customer.roleId == 2
                ? SizedBox()
                : Positioned(
                    top: -10,
                    left: -5, // Move to top-left corner
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors(context).primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            "assets/icon/support-ticket.svg",
                            height: 20,
                            width: 20,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${widget.services?.numOfTicket ?? ''} ${AppText(context).ticket}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
        ],
      ),
    );
  }
}
