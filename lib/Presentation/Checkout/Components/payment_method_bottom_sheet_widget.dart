import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/Transactions/transactions_apis.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Components/widget_dialog.dart';
import 'package:wefix/Presentation/Components/widget_form_text.dart';
import 'package:wefix/Presentation/Subscriptions/Screens/Subscriptions_screen.dart';
import 'package:wefix/layout_screen.dart';

import '../../../Data/appText/appText.dart';

class PaymentBottomSheet extends StatefulWidget {
  final bool? isWallet;
  final bool? loading;

  final Function()? onTap;
  const PaymentBottomSheet(
      {super.key, this.isWallet, this.onTap, this.loading});

  @override
  State<PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<PaymentBottomSheet> {
  String selectedPayment = 'visa';
  bool needsMaterial = false;
  final TextEditingController materialCostController = TextEditingController();
  final TextEditingController amount = TextEditingController();
  String? selectedType;
  final key = GlobalKey<FormState>();

  bool? createTransactionsLoading;

  @override
  void dispose() {
    materialCostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppProvider appProvider = Provider.of(context, listen: false);

    return SingleChildScrollView(
      child: Form(
        key: key,
        child: Padding(
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
                widget.isWallet == false
                    ? const SizedBox()
                    : WidgetTextField(
                        AppText(context, isFunction: true)
                            .entertheamountyouwanttoaddtoyourwallet,
                        controller: amount,
                        keyboardType: TextInputType.number,
                        validator: (p0) {
                          if (p0!.isEmpty) {
                            return AppText(context, isFunction: true)
                                .pleaseentertheamount;
                          } else if (double.tryParse(p0) == null) {
                            return AppText(context, isFunction: true)
                                .pleaseenteravalidnumber;
                          } else if (double.parse(p0) <= 0) {
                            return "Please enter a positive number";
                          }
                          return null;
                        },
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                widget.isWallet == false
                    ? const SizedBox()
                    : _dropdownField(
                        AppText(context, isFunction: true).transactiontype, [
                        AppText(context, isFunction: true).credit,
                        AppText(context, isFunction: true).debit
                      ]),
                const SizedBox(height: 10),
                _paymentOption("visa", "Visa", "assets/icon/visa.svg"),
                _paymentOption(
                    "qlic", "Cliq", "assets/icon/final_cliq_logo-02_1.svg"),
                widget.isWallet == true
                    ? const SizedBox()
                    : _paymentOption(
                        "wallet", "Wallet", "assets/icon/wallet.svg"),
                _paymentOption(
                    "bitcoin", "BitCoin", "assets/icon/bitcoin-btc-logo.svg"),
                _paymentOption("Paybal", "Paybal", "assets/icon/paybal.svg"),
                widget.isWallet == true
                    ? const SizedBox()
                    : _paymentOption(
                        "later", "Buy Later", "assets/icon/delay_3360328.svg"),
                const Divider(),
                const SizedBox(height: 20),
                CustomBotton(
                    title: AppText(context, isFunction: true).continuesss,
                    loading: widget.loading ?? createTransactionsLoading,
                    onTap: () {
                      if (key.currentState!.validate()) {
                        widget.isWallet == true
                            ? ccreateTransactions().then((value) {
                                // Navigator.pop(context);
                              })
                            : widget.onTap!();
                      }
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dropdownField(String label, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: AppSize(context).width,
        height: AppSize(context).height * 0.06,
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: AppColors.greyColor3),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
            child: DropdownButton<String>(
              isDense: true,
              isExpanded: true,
              underline: const SizedBox(),
              value: selectedType,
              hint: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                child: Text(label),
              ),
              items: items
                  .map((item) =>
                      DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedType = value;
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  Future ccreateTransactions() async {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    setState(() => createTransactionsLoading = true);
    await Transactions.createTransactins(
      token: appProvider.userModel?.token ?? "",
      amount: amount.text,
      type: selectedType ?? "Credit ",
    ).then((value) async {
      if (value == true) {
        setState(() => createTransactionsLoading = false);

        showDialog(
          context: context,
          builder: (context) => WidgetDialog(
            title: AppText(context, isFunction: true).successfully,
            desc: AppText(context, isFunction: true)
                .yourtransactionhasbeensuccessfullycompleted,
            isError: false,
            onTap: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => WidgetDialog(
            title: AppText(context, isFunction: true).warning,
            desc:
                AppText(context, isFunction: true).yourtransactionhasbeenfailed,
            isError: true,
            onTap: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        );
        setState(() => createTransactionsLoading = false);
      }
    });
  }

  bool _isCostOver100() {
    final cost = double.tryParse(materialCostController.text);
    return cost != null && cost > 100;
  }

  Widget _paymentOption(String value, String label, String icon) {
    final isSelected = selectedPayment == value;
    return InkWell(
      onTap: () => setState(() => selectedPayment = value),
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

  void showUpgradeDialog(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.whiteColor1,
          icon: Center(
            child: Text(
              "🚀",
              style: TextStyle(fontSize: AppSize(context).largText1),
            ),
          ),
          title: Text(
            AppText(context, isFunction: true).upgradeandSaveBig,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          // ignore: prefer_const_constructors
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              Text(
                AppText(context, isFunction: true)
                    .subscribenowandsave50JODDonmissoutonthisspecialoffer,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity, // Ensures buttons take full width
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: CustomBotton(
                      height: AppSize(context).height * .04,
                      title: AppText(context, isFunction: true).subscribeNow,
                      onTap: () {
                        Navigator.push(
                          context,
                          downToTop(const SubscriptionScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomBotton(
                      border: true,
                      color: AppColors.whiteColor1,
                      height: AppSize(context).height * .04,
                      title: AppText(context, isFunction: true).skip,
                      textColor: AppColors(context).primaryColor,
                      onTap: () {
                        Navigator.pushAndRemoveUntil(context,
                            downToTop(const HomeLayout()), (route) => false);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
