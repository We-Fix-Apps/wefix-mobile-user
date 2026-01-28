import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/LanguageProvider/l10n_provider.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Data/model/sub_cat_model.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Components/custom_cach_network_image.dart';

class ServiceQuintityCardWidget extends StatefulWidget {
  bool? isDetails;
  bool? isAddedd;
  Function()? onTap;
  Function()? increment;
  Function()? decrement;
  final bool? isSubsicribed;
  final GlobalKey? serviceCardKey;

  final Service? services;
  int count;

  ServiceQuintityCardWidget({
    super.key,
    this.isDetails,
    this.services,
    this.increment,
    this.decrement,
    this.serviceCardKey,
    this.onTap,
    this.isAddedd,
    required this.count,
    this.isSubsicribed,
  });

  @override
  State<ServiceQuintityCardWidget> createState() =>
      _ServiceQuintityCardWidgetState();
}

class _ServiceQuintityCardWidgetState extends State<ServiceQuintityCardWidget> {
  @override
  Widget build(BuildContext context) {
    LanguageProvider languageProvider =
        Provider.of<LanguageProvider>(context, listen: true);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        key: widget.serviceCardKey,
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
                color: AppColors.whiteColor1,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: AppColors.greyColor1)),
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                // Title section
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const SizedBox(width: 5),
                            SizedBox(
                              width: AppSize(context).width * .6,
                              child: Text(
                                languageProvider.lang == "ar"
                                    ? widget.services?.nameAr ?? ""
                                    : widget.services?.name ?? "Service Name",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: AppSize(context).smallText1,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                widget.isSubsicribed == true
                                    ? Text(
                                        "${AppText(context).price} ${AppText(context).jod} ${widget.services?.subscriptionPrice}",
                                        style: TextStyle(
                                          color: AppColors.greyColor2,
                                          fontSize: AppSize(context).smallText3,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      )
                                    : Text(
                                        "${AppText(context).price} ${AppText(context).jod} ${widget.services?.discountPrice}",
                                        style: TextStyle(
                                            color: AppColors.greyColor2,
                                            fontSize:
                                                AppSize(context).smallText3,
                                            fontWeight: FontWeight.w400),
                                      ),
                                const SizedBox(
                                  width: 10,
                                ),
                                (widget.isSubsicribed == false ||
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
                                            fontWeight: FontWeight.w400),
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

                // Description
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

                // Quantity Control
                if (widget.isDetails != true)
                  widget.count == 0
                      ? CustomBotton(
                          title: AppText(context).add,
                          height: AppSize(context).height * .04,
                          border: true,
                          borderColor: AppColors(context).primaryColor,
                          textColor: AppColors.whiteColor1,
                          color: AppColors(context).primaryColor,
                          onTap: widget.increment,
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                padding: const EdgeInsets.all(0),
                                icon: Icon(Icons.remove,
                                    color: AppColors(context).primaryColor),
                                onPressed: widget.decrement,
                              ),
                              Text(
                                "${widget.count}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors(context).primaryColor,
                                  fontSize: AppSize(context).mediumText3,
                                ),
                              ),
                              IconButton(
                                padding: const EdgeInsets.all(0),
                                icon: Icon(Icons.add,
                                    color: AppColors(context).primaryColor),
                                onPressed: widget.increment,
                              ),
                            ],
                          ),
                        )
              ],
            ),
          ),
          if (widget.isSubsicribed == true)
            Positioned(
              top: -10,
              left: -5,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors(context).primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
