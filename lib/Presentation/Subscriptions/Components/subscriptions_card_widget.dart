import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/LanguageProvider/l10n_provider.dart';
import 'package:wefix/Business/orders/profile_api.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Data/model/packages_model.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Components/widget_dialog.dart';
import 'package:wefix/Presentation/Components/widget_form_text.dart';
import 'package:wefix/Presentation/Loading/loading_text.dart';
import 'package:wefix/Presentation/Subscriptions/Components/featuer_widget.dart';

class SubscriptionCard extends StatefulWidget {
  final String? title;
  final String? image;
  final String? price;
  final String? priceAnnual;
  final String? imageFoter;
  final Color? color;
  final Function()? onTap;
  final List? features;
  final bool? isActive;
  final bool? isRecommended;

  bool? isLoading;
  final bool? isSelected;
  final PackagePackage? package; // Add this to access package details

  SubscriptionCard({
    super.key,
    this.title,
    this.price,
    this.isRecommended,
    this.features,
    this.imageFoter,
    this.image,
    this.color,
    this.isActive,
    this.priceAnnual,
    this.isSelected,
    this.onTap,
    this.isLoading,
    this.package, // Add this
  });

  @override
  State<SubscriptionCard> createState() => _SubscriptionCardState();
}

class _SubscriptionCardState extends State<SubscriptionCard> {
  String selectedPayment = 'visa';
  TextEditingController ageController = TextEditingController();
  TextEditingController distanceController = TextEditingController();
  dynamic calculatedPrice = 0;
  bool showCalculatedPrice = false;
  bool loading2 = false;

  @override
  Widget build(BuildContext context) {
    LanguageProvider languageProvider = Provider.of<LanguageProvider>(context, listen: true);
    return Center(
      child: Container(
        width: AppSize(context).width * 0.7,
        decoration: BoxDecoration(
          color: AppColors.whiteColor1,
          border: Border.all(color: widget.isSelected == true ? AppColors(context).primaryColor : AppColors.greyColor),
          borderRadius: BorderRadius.circular(0),
        ),
        child: Container(
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: AppColors.whiteColor1,
            borderRadius: BorderRadius.circular(0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: AppSize(context).height * .25,
                // width: AppSize(context).width * .5,
                decoration: BoxDecoration(color: widget.color?.withOpacity(.2)),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      widget.isRecommended == true
                          ? Image.asset(
                              "assets/image/favourites.png",
                              width: 40,
                              height: 40,
                            )
                          : const SizedBox.shrink(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: widget.color,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: Text(
                                  widget.title?.toUpperCase() ?? "Google One",
                                  style: TextStyle(
                                    fontSize: AppSize(context).smallText1,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.whiteColor1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSize(context).height * .01),
                      Column(
                        children: [
                          Text(AppText(context).startfrom),
                          Text(
                            "${widget.price.toString()} ${AppText(context).jod}",
                            style: TextStyle(
                              fontSize: AppSize(context).largText1,
                              color: AppColors.blackColor1,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.whiteColor1,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                              child: Text(
                                AppText(context).jODMonth,
                                style: TextStyle(
                                  fontSize: AppSize(context).smallText4,
                                  color: widget.color,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(width: 8),
                            SizedBox(
                              width: AppSize(context).width * 0.45,
                              child: Text(
                                AppText(context).feature,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              AppText(context).value,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        height: AppSize(context).height * .01,
                        color: AppColors.backgroundColor,
                      ),
                      FeatureWidget(
                        color: widget.color,
                        feature: AppText(context).correctivevisits,
                        value:
                            widget.package?.numberOfRegularVisit == 100 ? AppText(context).unlimited : widget.package?.numberOfRegularVisit.toString() ?? "0",
                      ),
                      FeatureWidget(
                        color: widget.color,
                        feature: AppText(context).preventivevisits,
                        value: widget.package?.numberOnDemandVisit == 100 ? AppText(context).unlimited : widget.package?.numberOnDemandVisit.toString() ?? "0",
                      ),
                      FeatureWidget(
                        color: widget.color,
                        feature: AppText(context).consultations,
                        value: widget.package?.consultation == 100 ? AppText(context).unlimited : widget.package?.consultation.toString() ?? "0",
                      ),
                      FeatureWidget(
                        color: widget.color,
                        feature: AppText(context).emeregencyService,
                        value:
                            widget.package?.numberOfUrgentVisits == 100 ? AppText(context).unlimited : widget.package?.numberOfUrgentVisits.toString() ?? "0",
                      ),
                      FeatureWidget(
                        color: widget.color,
                        feature: AppText(context).femaleService,
                        value: widget.package?.numberOfFemalUse == 100 ? AppText(context).unlimited : widget.package?.numberOfFemalUse.toString() ?? "0",
                      ),
                      FeatureWidget(
                        color: widget.color,
                        feature: AppText(context).interiorDesign,
                        value: widget.package?.interiorDesign == "0" ? "- \n  \n" : widget.package?.interiorDesign.toString() ?? "-  \n \n",
                      ),
                    ],
                  ),
                ),
              ),
              // SizedBox(height: AppSize(context).height * .02),
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Image(
                    image: AssetImage(widget.imageFoter ?? "assets/image/green.png"),
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: EdgeInsets.all(AppSize(context).height * .015),
                    child: Stack(
                      children: [
                        InkWell(
                          onTap: () {
                            showDetailsInput(context);
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              widget.isLoading == true
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator())
                                  : Text(
                                      widget.price ?? "JOD 90 / month",
                                      style: TextStyle(
                                        fontSize: AppSize(context).smallText1,
                                        color: AppColors.blackColor1,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                              Container(
                                height: AppSize(context).height * .05,
                                width: AppSize(context).width * .5,
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(horizontal: AppSize(context).width * .1),
                                decoration: BoxDecoration(
                                  color: widget.color,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  AppText(context).subscribeNow,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: AppSize(context).smallText1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showDetailsInput(BuildContext context) {
    var key = GlobalKey<FormState>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(builder: (context, setState) {
        return Form(
          key: key,
          child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      AppText(context).enterDetails,
                      style: TextStyle(fontSize: AppSize(context).smallText1, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  WidgetTextField(
                    AppText(context).distanceFromCenter,
                    controller: distanceController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppText(context, isFunction: true).required;
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  if (showCalculatedPrice)
                    loading2 == true
                        ? const LoadingText(width: 100)
                        : Text(
                            "${AppText(context).calculatedPrice}: JOD $calculatedPrice",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors(context).primaryColor,
                            ),
                          ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: CustomBotton(
                          title: AppText(context).calculate,
                          onTap: () {
                            if (key.currentState!.validate()) {
                              if (distanceController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(AppText(context).pleaseFillAllFields)),
                                );
                                return;
                              }

                              // Calculate price based on inputs
                              calculate(setState);

                              setState(() {
                                showCalculatedPrice = true;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomBotton(
                          title: AppText(context).proceedToPayment,
                          onTap: () {
                            if (!showCalculatedPrice) {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return WidgetDialog(
                                      title: AppText(context, isFunction: true).warning,
                                      desc: AppText(context, isFunction: true).pleaseCalculateFirst,
                                      isError: true);
                                },
                              );
                              return;
                            }

                            // Close this bottom sheet and open payment
                            else
                              Navigator.pop(context);
                            showPaymentMethod(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  void showPaymentMethod(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => StatefulBuilder(
              builder: (context, set) {
                return Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      runSpacing: 10,
                      children: [
                        Center(
                          child: Text(
                            AppText(context).selectPaymentMethods,
                            style: TextStyle(fontSize: AppSize(context).smallText1, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _paymentOption("visa", AppText(context, isFunction: true).visa, "assets/icon/bank-card_17727858.svg", set),
                        _paymentOption("qlic", AppText(context, isFunction: true).cliq, "assets/icon/final_cliq_logo-02_1.svg", set),
                        _paymentOption("wallet", AppText(context, isFunction: true).wallet, "assets/icon/wallet.svg", set),
                        _paymentOption("Paybal", AppText(context, isFunction: true).paypal, "assets/icon/paybal.svg", set),
                        _paymentOption("later", "${AppText(context, isFunction: true).paylater}", "assets/icon/delay_3360328.svg", set),
                        const Divider(),
                        const SizedBox(height: 20),
                        Center(
                          child: Image.asset(
                            "assets/icon/verified.png",
                            width: 170,
                          ),
                        ),
                        const SizedBox(height: 20),
                        CustomBotton(
                          title: AppText(context).continuesss,
                          loading: widget.isLoading,
                          onTap: () {
                            set(() {
                              widget.isLoading = true;
                            });
                            widget.onTap!();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ));
  }

  Future calculate(void Function(void Function()) setState) async {
    setState(() {
      loading2 = true;
    });
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    try {
      ProfileApis.calculateSubPrice(
        token: appProvider.userModel?.token ?? "",
        age: ageController.text,
        area: distanceController.text,
        packageId: widget.package?.id.toString() ?? "0",
      ).then((value) {
        setState(() {
          appProvider.saveDateAndDistance({
            "age": ageController.text,
            "distance": distanceController.text,
            "price": value.toString(),
          });
          calculatedPrice = value;
          // packageModel = value;
          loading2 = false;
        });

        // if (value == false) {
        //   showDialog(
        //     context: context,
        //     builder: (context) {
        //       return WidgetDialog(
        //           onTap: () {
        //             pop(context);
        //             pop(context);
        //           },
        //           title: AppText(context, isFunction: true).warning,
        //           desc: AppText(context, isFunction: true).contactUs,
        //           isError: false);
        //     },
        //   );
        // }
      });
    } catch (e) {
      log(e.toString());
      setState(() {
        loading2 = false;
      });
    }
  }

  Widget _paymentOption(String value, String label, String icon, void Function(void Function()) localSetState) {
    final isSelected = selectedPayment == value;
    return InkWell(
      onTap: () => localSetState(() => selectedPayment = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors(context).primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppColors(context).primaryColor.withOpacity(0.05) : AppColors.whiteColor1,
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              width: 30,
            ),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            if (isSelected) Icon(Icons.check_circle, color: AppColors(context).primaryColor),
          ],
        ),
      ),
    );
  }
}
