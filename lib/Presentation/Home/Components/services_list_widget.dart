import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/LanguageProvider/l10n_provider.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/model/home_model.dart';
import 'package:wefix/Presentation/Components/custom_cach_network_image.dart';
import 'package:wefix/Presentation/Components/widget_dialog.dart';
import 'package:wefix/Presentation/SubCategory/Screens/sub_category_screen.dart';
import 'package:wefix/Presentation/SubCategory/Screens/sub_services_screen.dart';
import 'package:wefix/Presentation/Subscriptions/Screens/Subscriptions_screen.dart';
import 'package:wefix/Presentation/auth/login_screen.dart';

import '../../../Business/AppProvider/app_provider.dart';

class ServicesWidget extends StatefulWidget {
  final List<Category> categories;
  final int roleId;
  final GlobalKey? key1;
  const ServicesWidget({super.key, required this.categories, this.key1, required this.roleId});

  @override
  State<ServicesWidget> createState() => _ServicesWidgetState();
}

class _ServicesWidgetState extends State<ServicesWidget> {
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 10) / 3;
        final itemHeight = (constraints.maxWidth - 10) / 3;
        return Wrap(
          spacing: 5,
          runSpacing: 5,
          children: List.generate(widget.categories.length, (index) {
            final category = widget.categories[index];
            return Container(
                width: itemWidth,
                height: itemHeight,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.greyColor1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: InkWell(
                    key: index == 0 ? widget.key1 : null,
                    onTap: () {
                      AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
                      final isGuest = appProvider.userModel == null || appProvider.userModel?.token == null || appProvider.userModel!.token.isEmpty;
                      if (isGuest == true) {
                        showDialog(
                            context: context,
                            builder: (context) => WidgetDialog(
                                title: 'Worning',
                                desc: 'You Must Be Login For Use This Feature!',
                                isError: true,
                                bottonText: 'Login',
                                onTap: () => Navigator.pushAndRemoveUntil(
                                      context,
                                      downToTop(const LoginScreen()),
                                      (route) => false,
                                    )));
                      } else {
                        category.subscribScreen == true
                            ? Navigator.push(context, downToTop(const SubscriptionScreen()))
                            : category.subCategory?.isNotEmpty == true
                                ? Navigator.push(context, downToTop(SubCategoryScreen(categories: category.subCategory, title: category.titleEn, titleAr: category.titleAr)))
                                : Navigator.push(context, downToTop(SubServicesScreen(catId: category.id, title: languageProvider.lang == "ar" ? category.titleAr : category.titleEn)));
                      }
                    },
                    child: Center(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisSize: MainAxisSize.min, spacing: 5, children: [
                      WidgetCachNetworkImage(image: category.icon ?? "", height: 70, width: 70, boxFit: BoxFit.cover),
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: Text(languageProvider.lang == "ar" ? category.titleAr : category.titleEn,
                              textAlign: TextAlign.center, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: AppSize(context).smallText4, fontWeight: FontWeight.bold)))
                    ]))));
          }),
        );
      },
    );
  }
}
