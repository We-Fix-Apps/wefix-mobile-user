import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/Contract/contract_apis.dart';
import 'package:wefix/Business/orders/profile_api.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Data/model/contract_details_model.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Components/empty_screen.dart';
import 'package:wefix/Presentation/Components/language_icon.dart';
import 'package:wefix/Presentation/Profile/Components/usage_details_widget.dart';
import 'package:wefix/layout_screen.dart';

class ContractScreen extends StatefulWidget {
  const ContractScreen({super.key});

  @override
  State<ContractScreen> createState() => _ContractScreenState();
}

class _ContractScreenState extends State<ContractScreen> {
  ContractDetails? contractDetails;
  bool? loading = false;
  bool? loading2 = false;
  String selectedPayment = 'visa';

  @override
  void initState() {
    getContractDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppText(context).contractDetails),
        centerTitle: true,
        actions: const [
          LanguageButton(),
        ],
      ),
      body: loading == true
          ? LinearProgressIndicator(
              color: AppColors(context).primaryColor,
              backgroundColor: AppColors.secoundryColor,
            )
          : contractDetails?.customerPackages == null
              ? EmptyScreen(
                  image: "assets/icon/contract_empty.svg",
                  title: "You don't have any subscriptions yet",
                  subtitle: "Subscribe now",
                  titleBtn: "Subscribe now",
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        downToTop(const HomeLayout(
                          index: 2,
                        )),
                        (route) => false);
                  },
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Contract Summary
                      Text(
                        "📄 ${AppText(context).contractSummary}",
                        style: TextStyle(
                            fontSize: AppSize(context).smallText1,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.greyColorback, width: 1),
                          color: AppColors.whiteColor1,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    contractDetails?.customerPackages.name
                                            .toUpperCase() ??
                                        " 0",
                                    style: TextStyle(
                                        fontSize: AppSize(context).mediumText3,
                                        color: AppColors(context).primaryColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.greenColorBack,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      contractDetails
                                              ?.customerPackages.status ??
                                          "",
                                      style: const TextStyle(
                                          color: AppColors.greenColor),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                  "${AppText(context).startdate}: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(contractDetails?.customerPackages.startDate.toString() ?? ''))}"),
                              Text(
                                  "${AppText(context).endDate}: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(contractDetails?.customerPackages.endDate.toString() ?? ''))}"),
                              const SizedBox(height: 8),
                              Text(
                                "${contractDetails?.customerPackages.price ?? 0} ${AppText(context).jODMonth}",
                                style: TextStyle(
                                    fontSize: AppSize(context).smallText1,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Usage Details
                      Text(
                        "📊 ${AppText(context).usageDetails}",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),

                      UsageDetailsWidget(
                          title: AppText(context).recurringVisits,
                          value:
                              contractDetails?.customerPackages.recurringVist ??
                                  0,
                          total: contractDetails
                                  ?.customerPackages.totalRecurringVist ??
                              0,
                          color: Colors.green),
                      UsageDetailsWidget(
                          title: AppText(context).ondemandVisits,
                          value:
                              contractDetails?.customerPackages.onDemandVisit ??
                                  0,
                          total: contractDetails
                                  ?.customerPackages.totalOnDemandVisit ??
                              0,
                          color: Colors.red),
                      UsageDetailsWidget(
                          title: AppText(context).emergencyVisits,
                          value: contractDetails
                                  ?.customerPackages.emeregencyVisit ??
                              0,
                          total: contractDetails
                                  ?.customerPackages.totalEmeregencyVisit ??
                              0,
                          color: Colors.orange),

                      const SizedBox(height: 20),

                      // Remaining Time
                      // Text(
                      //   "⏳ ${AppText(context).remainingTime}",
                      //   style: TextStyle(
                      //       fontSize: AppSize(context).smallText1,
                      //       fontWeight: FontWeight.bold),
                      // ),
                      // const SizedBox(height: 10),

                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Text(AppText(context).daysRemaining),
                      //     const Text("250 Days",
                      //         style: TextStyle(fontWeight: FontWeight.bold)),
                      //   ],
                      // ),
                      // const SizedBox(height: 5),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Text(AppText(context).nextVisitDue),
                      //     const Text("After 2 Days",
                      //         style: TextStyle(fontWeight: FontWeight.bold)),
                      //   ],
                      // ),
                      // const SizedBox(height: 5),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Text(AppText(context).savingsThisYear),
                      //     Text("JOD ${contractDetails?.customerPackages.price}",
                      //         style:
                      //             const TextStyle(fontWeight: FontWeight.bold)),
                      //   ],
                      // ),

                      const Spacer(),

                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: CustomBotton(
                              title: AppText(context).renew,
                              onTap: () {
                                showPaymentMethod(context);
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: CustomBotton(
                              title: "🚀 ${AppText(context).upgrade}",
                              onTap: () {
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    downToTop(HomeLayout(
                                      index: 2,
                                    )),
                                    (route) => false);
                              },
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }

  Future renew() async {
    setState(() {
      loading2 = true;
    });
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    try {
      await ProfileApis.renew(
        token: appProvider.userModel?.token ?? '',
      ).then((value) {
        pop(context);
        const snackBar = SnackBar(
          content: Text('Your renew has been completed successfully'),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() {
          loading2 = false;
        });
        log(value.toString());
      });
    } catch (e) {
      log('renew $e');
      setState(() {
        loading2 = false;
      });
    }
  }

  Future getContractDetails() async {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    setState(() {
      loading = true;
    });
    ContractsApis.getContractDetails(token: appProvider.userModel?.token ?? '')
        .then((value) {
      if (value?.customerPackages.name != null) {
        setState(() {
          contractDetails = value;
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
      }
    });
  }

  showPaymentMethod(context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(builder: (context, setState) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              runSpacing: 10,
              children: [
                Center(
                  child: Text(
                    AppText(context, isFunction: true).selectPaymentMethods,
                    style: TextStyle(
                        fontSize: AppSize(context).smallText1,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                _paymentOption(
                    "visa", "Visa", "assets/icon/visa.svg", setState),
                _paymentOption("qlic", "Cliq",
                    "assets/icon/final_cliq_logo-02_1.svg", setState),
                _paymentOption(
                    "wallet", "Wallet", "assets/icon/wallet.svg", setState),
                _paymentOption("bitcoin", "BitCoin",
                    "assets/icon/bitcoin-btc-logo.svg", setState),
                _paymentOption(
                    "Paybal", "Paybal", "assets/icon/paybal.svg", setState),
                _paymentOption("later", "Buy Later",
                    "assets/icon/delay_3360328.svg", setState),
                const Divider(),
                const SizedBox(height: 20),
                CustomBotton(
                    title: AppText(context, isFunction: true).continuesss,
                    loading: loading2,
                    onTap: () {
                      setState(() {
                        loading2 = true;
                      });
                      renew().then((value) {
                        setState(() {
                          loading2 = false;
                        });
                      });
                    }),
              ],
            ),
          ),
        );
      }),
    );
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
