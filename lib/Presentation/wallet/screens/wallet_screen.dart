import 'package:flutter/material.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/LanguageProvider/l10n_provider.dart';
import 'package:wefix/Business/Transactions/transactions_apis.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/model/transactions_model.dart';
import 'package:wefix/Presentation/Checkout/Components/payment_method_bottom_sheet_widget.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Components/empty_screen.dart';
import 'package:wefix/Presentation/Components/language_icon.dart';
import 'package:wefix/Presentation/Loading/loading_text.dart';
import 'package:wefix/Presentation/wallet/components/transaction_loading_widget.dart';
import 'package:wefix/Presentation/wallet/components/transactions_widget.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../Data/appText/appText.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool? loading;
  bool? loadingWithdraw;
  TransactionsModel? transactions;

  @override
  void initState() {
    getTransactions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    LanguageProvider languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        actions: [
          LanguageButton(),
        ],
        title: Text(AppText(context).wallet),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: AppSize(context).height * 0.3,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    "assets/image/BACKGROUND.png",
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSize(context).width * 0.05,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppText(context).availableBalance,
                              style: TextStyle(
                                fontSize: AppSize(context).smallText1,
                                color: AppColors.whiteColor1,
                              ),
                            ),
                            loading == true
                                ? const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: LoadingText(
                                      width: 100,
                                      height: 30,
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${transactions?.wallet} ${AppText(context).jod}",
                                        style: TextStyle(
                                          fontSize: AppSize(context).largText1,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.whiteColor1,
                                        ),
                                      ),
                                      CustomBotton(
                                        width: AppSize(context).width * 0.35,
                                        height: AppSize(context).height * 0.04,
                                        color: AppColors.whiteColor1,
                                        title: AppText(context).maketransaction,
                                        textColor:
                                            AppColors(context).primaryColor,
                                        onTap: () {
                                          showPaymentMethod(context);
                                        },
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppText(context).recenttransactions,
                    style: TextStyle(
                      fontSize: AppSize(context).mediumText3,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            loading == true
                ? ListView.builder(
                    itemCount: 5,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return const TransactionsWidgetLoading();
                    },
                  )
                : transactions?.transactions.isEmpty ?? true
                    ? EmptyScreen(
                        image: "assets/icon/wallet_empty.svg",
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          String isoDate = "23 Feb , 2025";
                          // DateTime dateTime = DateTime.parse(isoDate);
                          // String formattedDate =
                          //     DateFormat('MMMM dd, yyyy').format(dateTime);
                          return TransactionsWidget(
                              loading: loading,
                              statusAr:
                                  transactions?.transactions[index].statusAr ??
                                      "",
                              name: transactions?.transactions[index].type ==
                                      "credit"
                                  ? AppText(context).deposit
                                  : AppText(context).withdraw,
                              date: DateFormat('MMMM dd, yyyy').format(
                                  transactions
                                          ?.transactions[index].createdDate ??
                                      DateTime.now()),
                              status:
                                  transactions?.transactions[index].status ??
                                      "",
                              value:
                                  "${transactions?.transactions[index].type == "credit" ? "+" : "-"}  ${transactions?.transactions[index].amount.toString() ?? ""}");
                        },
                        separatorBuilder: (context, index) =>
                            Divider(color: AppColors.greyColorback),
                        itemCount: transactions?.transactions.length ?? 0,
                      )
          ],
        ),
      ),
    );
  }

  Future showPaymentMethod(context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(builder: (context, set) {
        return const PaymentBottomSheet(
          isWallet: true,
        );
      }),
    ).whenComplete(() => getTransactions());
  }

  Future getTransactions() async {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    setState(() {
      loading = true;
    });
    Transactions.getAllTransactions(token: appProvider.userModel?.token ?? '')
        .then((value) {
      if (value != null) {
        setState(() {
          transactions = value;
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
      }
    });
  }
}
