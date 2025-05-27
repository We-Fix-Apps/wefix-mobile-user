import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/LanguageProvider/l10n_provider.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Data/model/packages_model.dart';
import 'package:wefix/Presentation/Checkout/Components/payment_method_bottom_sheet_widget.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Components/widget_dialog.dart';
import 'package:wefix/Presentation/Components/widget_form_text.dart';
import 'package:wefix/Presentation/Profile/Screens/proparity_screen.dart';

class SubscriptionCard extends StatefulWidget {
  final String? title;
  final String? price;
  final String? priceAnnual;
  final Function()? onTap;
  final List? features;
  final bool? isActive;
  bool? isLoading;
  final bool? isSelected;
  final PackagePackage? package; // Add this to access package details

  SubscriptionCard({
    super.key,
    this.title,
    this.price,
    this.features,
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
  double calculatedPrice = 0;
  bool showCalculatedPrice = false;

  @override
  Widget build(BuildContext context) {
    LanguageProvider languageProvider =
        Provider.of<LanguageProvider>(context, listen: true);
    return Center(
      child: Container(
        width: AppSize(context).width * 0.7,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.whiteColor1,
          border: Border.all(
              color: widget.isSelected == true
                  ? AppColors(context).primaryColor
                  : AppColors.greyColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.whiteColor1,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppText(context).recommended,
                style: const TextStyle(
                  color: AppColors.blackColor1,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.title ?? "Google One",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () {
                  showDetailsInput(context);
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    widget.isLoading == true
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator())
                        : Text(
                            widget.price ?? "JOD 90 / month",
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.blackColor1,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                    Container(
                      height: 40,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppColors(context).primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        showCalculatedPrice
                            ? "JOD $calculatedPrice / ${AppText(context).month}"
                            : widget.price ??
                                "JOD 90 / ${AppText(context).month}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "${AppText(context).orprepayannually}:",
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 4),
              Text(
                widget.priceAnnual ?? "JOD 90 / month",
                style: const TextStyle(
                  color: AppColors.secoundryColor,
                  fontSize: 16,
                ),
              ),
              const Divider(height: 30),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListView.separated(
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Row(
                        children: [
                          widget.features![index].status == true
                              ? const Icon(Icons.check,
                                  size: 18, color: AppColors.greenColor)
                              : const Icon(Icons.close,
                                  size: 18, color: AppColors.greyColor1),
                          const SizedBox(width: 8),
                          Text(languageProvider.lang == "ar"
                              ? "${widget.features![index].featureAr}"
                              : "${widget.features![index].feature}"),
                        ],
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const SizedBox(height: 8);
                    },
                    itemCount: widget.features?.length ?? 0,
                  )
                ],
              ),
              // const SizedBox(height: 20),
              // CustomBotton(
              //   title: AppText(context).subscribeNow,
              //   loading: widget.isLoading,
              //   onTap: () {
              //     showDetailsInput(context);
              //   },
              // ),
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
                      style: TextStyle(
                          fontSize: AppSize(context).smallText1,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  WidgetTextField(
                    AppText(context).apartmentAge,
                    controller: ageController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppText(context, isFunction: true).required;
                      }
                      return null;
                    },
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
                    Text(
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
                              if (ageController.text.isEmpty ||
                                  distanceController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(AppText(context)
                                          .pleaseFillAllFields)),
                                );
                                return;
                              }

                              // Calculate price based on inputs
                              double basePrice = double.tryParse(widget.price
                                          ?.replaceAll(
                                              RegExp(r'[^0-9.]'), '') ??
                                      '0') ??
                                  0;
                              int age = int.tryParse(ageController.text) ?? 0;
                              int distance =
                                  int.tryParse(distanceController.text) ?? 0;

                              // Example calculation - adjust according to your business logic
                              double ageFactor = age > 20 ? 1.2 : 1.0;
                              double distanceFactor = distance > 10 ? 1.1 : 1.0;
                              calculatedPrice =
                                  (basePrice * ageFactor * distanceFactor);

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
                                      title: AppText(context, isFunction: true)
                                          .warning,
                                      desc: AppText(context, isFunction: true)
                                          .pleaseCalculateFirst,
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
                            style: TextStyle(
                                fontSize: AppSize(context).smallText1,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _paymentOption(
                            "visa", "Visa", "assets/icon/visa.svg", set),
                        _paymentOption("qlic", "Cliq",
                            "assets/icon/final_cliq_logo-02_1.svg", set),
                        _paymentOption(
                            "wallet", "Wallet", "assets/icon/wallet.svg", set),
                        _paymentOption("bitcoin", "BitCoin",
                            "assets/icon/bitcoin-btc-logo.svg", set),
                        _paymentOption(
                            "Paybal", "Paybal", "assets/icon/paybal.svg", set),
                        _paymentOption("later", "Buy Later",
                            "assets/icon/delay_3360328.svg", set),
                        const Divider(),
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

  Widget _paymentOption(String value, String label, String icon,
      void Function(void Function()) localSetState) {
    final isSelected = selectedPayment == value;
    return InkWell(
      onTap: () => localSetState(() => selectedPayment = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? AppColors(context).primaryColor
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? AppColors(context).primaryColor.withOpacity(0.05)
              : AppColors.whiteColor1,
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
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors(context).primaryColor),
          ],
        ),
      ),
    );
  }
}
