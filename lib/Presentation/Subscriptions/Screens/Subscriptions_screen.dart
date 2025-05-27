import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/Bookings/bookings_apis.dart';
import 'package:wefix/Business/LanguageProvider/l10n_provider.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Data/model/packages_model.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Components/language_icon.dart';
import 'package:wefix/Presentation/Components/widget_dialog.dart';
import 'package:wefix/Presentation/Subscriptions/Components/subscriptions_card_widget.dart';
import 'package:wefix/Presentation/Subscriptions/Screens/compertion_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final List<int> selectedIndexes = [];
  bool loading = false;
  bool loading2 = false;

  PackagesModel? packageModel;

  void toggleSelection(int index) {
    setState(() {
      if (selectedIndexes.contains(index)) {
        selectedIndexes.remove(index);
      } else {
        if (selectedIndexes.length < 2) {
          selectedIndexes.add(index);
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getPackagesDetails();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors(context).primaryColor;
    LanguageProvider languageProvider =
        Provider.of<LanguageProvider>(context, listen: true);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("${AppText(context).subscription}"),
        centerTitle: true,
        actions: const [LanguageButton()],
      ),
      body: loading
          ? LinearProgressIndicator(
              color: AppColors(context).primaryColor,
              backgroundColor: AppColors.secoundryColor,
            )
          : DefaultTabController(
              length: packageModel?.packages.length ?? 0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppText(context)
                          .dontmissoutSubscribenowforspecialServices,
                      style: TextStyle(
                        fontSize: AppSize(context).mediumText3,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TabBar(
                      isScrollable: true,
                      indicatorColor: primaryColor,
                      labelColor: primaryColor,
                      unselectedLabelColor: Colors.black54,
                      tabs: packageModel?.packages
                              .map((e) => Tab(
                                  text: languageProvider.lang == "ar"
                                      ? e.titleAr
                                      : e.title))
                              .toList() ??
                          [],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: TabBarView(
                        children: packageModel?.packages
                                .map(
                                  (e) => ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: e.package.length,
                                    itemBuilder: (context, index) {
                                      final sub = e.package[index];
                                      final isSelected =
                                          selectedIndexes.contains(index);

                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 20),
                                        child: Stack(
                                          children: [
                                            SizedBox(
                                              height:
                                                  AppSize(context).height * 0.5,
                                              child: GestureDetector(
                                                onTap: () =>
                                                    toggleSelection(index),
                                                child: SubscriptionCard(
                                                  title: sub.title,
                                                  isLoading: loading2,
                                                  onTap: () {
                                                    subsicribeNow(sub.id)
                                                        .then((value) {});
                                                  },
                                                  price:
                                                      "${sub.price.toString()} ${AppText(context).jODMonth}",
                                                  priceAnnual: sub.priceAnnual
                                                      .toString(),
                                                  features: sub.features,
                                                  isSelected: isSelected,
                                                  package: sub, // Add this line
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 20,
                                              child: GestureDetector(
                                                onTap: () =>
                                                    toggleSelection(index),
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10,
                                                      vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? primaryColor
                                                        : Colors.grey.shade400,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color: Colors.black12,
                                                        blurRadius: 4,
                                                      )
                                                    ],
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const Icon(
                                                        Icons.compare_arrows,
                                                        size: 16,
                                                        color: Colors.white,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        isSelected
                                                            ? AppText(context)
                                                                .added
                                                            : AppText(context)
                                                                .compare,
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 12),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                )
                                .toList() ??
                            [],
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (selectedIndexes.length == 2)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CustomBotton(
                          title: AppText(context).compare,
                          onTap: () {
                            final selectedPlans = selectedIndexes
                                .map((index) =>
                                    packageModel?.packages[0].package[index])
                                .whereType<PackagePackage>()
                                .toList();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ComparisonScreen(plans: selectedPlans),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Future getPackagesDetails() async {
    setState(() {
      loading = true;
    });
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    try {
      BookingApi.getPackagesDetails(token: appProvider.userModel?.token ?? "")
          .then((value) {
        setState(() {
          packageModel = value;
          loading = false;
        });
      });
    } catch (e) {
      log(e.toString());
      setState(() {
        loading = false;
      });
    }
  }

  Future subsicribeNow(id) async {
    setState(() {
      loading2 = true;
    });
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    try {
      BookingApi.subsicribeNow(
              token: appProvider.userModel?.token ?? "", id: id)
          .then((value) {
        showDialog(
          context: context,
          builder: (context) {
            return WidgetDialog(
                onTap: () {
                  pop(context);
                  pop(context);
                },
                title: AppText(context, isFunction: true).successfully,
                desc: AppText(context, isFunction: true).subSuccess,
                isError: false);
          },
        );
        setState(() {
          loading2 = false;
        });
      });
    } catch (e) {
      log(e.toString());
      setState(() {
        loading2 = false;
      });
    }
  }
}
