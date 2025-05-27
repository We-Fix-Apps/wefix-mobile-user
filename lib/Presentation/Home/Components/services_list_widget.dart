import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/LanguageProvider/l10n_provider.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/model/home_model.dart';
import 'package:wefix/Presentation/Components/custom_cach_network_image.dart';
import 'package:wefix/Presentation/SubCategory/Screens/sub_category_screen.dart';
import 'package:wefix/Presentation/SubCategory/Screens/sub_services_screen.dart';
import 'package:wefix/Presentation/Subscriptions/Screens/Subscriptions_screen.dart';

import '../../SubCategory/Components/service_card_widget.dart';

class ServicesWidget extends StatefulWidget {
  final List<Category> categories;
  const ServicesWidget({super.key, required this.categories});

  @override
  State<ServicesWidget> createState() => _ServicesWidgetState();
}

class _ServicesWidgetState extends State<ServicesWidget> {
  final List<Map<String, dynamic>> services = [
    {'name': 'Smoke Detector', 'icon': "assets/image/wefix icon 1.png"},
    {'name': 'Maintenance Contract', 'icon': "assets/image/wefix icon 2.png"},
    {'name': 'Appliances Repair', 'icon': "assets/image/wefix icon 3.png"},
    {'name': 'Smoke Detector', 'icon': "assets/image/wefix icon 1.png"},
    {'name': 'Maintenance Contract', 'icon': "assets/image/wefix icon 2.png"},
    {'name': 'Appliances Repair', 'icon': "assets/image/wefix icon 3.png"},
    {'name': 'Smoke Detector', 'icon': "assets/image/wefix icon 1.png"},
    {'name': 'Maintenance Contract', 'icon': "assets/image/wefix icon 2.png"},
    {'name': 'Appliances Repair', 'icon': "assets/image/wefix icon 3.png"},
  ];

  @override
  void initState() {
    super.initState();
  }

  // void _showTutorial() {
  //   // Create a list of targets (widgets to highlight)
  //   List<TargetFocus> targets =
  //       List.generate(widget.categories.length, (index) {
  //     return TargetFocus(
  //       identify: "Target$index",
  //       keyTarget: cardKeys[index], // Attach the correct key for each service
  //       shape: ShapeLightFocus.RRect, // Rectangle shape for focus
  //       contents: [
  //         TargetContent(
  //           align: ContentAlign.top,
  //           builder: (context, controller) {
  //             return Container(
  //               padding: const EdgeInsets.all(10),
  //               child: const Text(
  //                 "Long press on a service to explore more options!",
  //                 style: TextStyle(
  //                     fontWeight: FontWeight.bold, color: Colors.white),
  //               ),
  //             );
  //           },
  //         ),
  //       ],
  //     );
  //   });

  //   // Create the tutorial coach mark instance
  //   tutorialCoachMark = TutorialCoachMark(
  //     targets: targets,
  //     colorShadow: Colors.black.withOpacity(0.7),
  //     textSkip: "Skip",
  //     paddingFocus: 10,
  //     onFinish: () {
  //       // Handle the finish action if needed
  //     },
  //     onSkip: () {
  //       return true;
  //     },
  //   )..show(context: context);
  // }

  @override
  Widget build(BuildContext context) {
    LanguageProvider languageProvider =
        Provider.of<LanguageProvider>(context, listen: true);
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
          childAspectRatio: .9),
      itemCount: widget.categories.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            widget.categories[index].subscribScreen == true
                ? Navigator.push(
                    context,
                    downToTop(SubscriptionScreen()),
                  )
                : widget.categories[index].subCategory?.isNotEmpty == true
                    ? Navigator.push(
                        context,
                        downToTop(SubCategoryScreen(
                          categories: widget.categories[index].subCategory,
                          title: languageProvider.lang == "ar"
                              ? widget.categories[index].titleAr ?? ""
                              : widget.categories[index].titleEn ?? "",
                        )),
                      )
                    : Navigator.push(
                        context,
                        downToTop(SubServicesScreen(
                          catId: widget.categories[index].id,
                          title: languageProvider.lang == "ar"
                              ? widget.categories[index].titleAr ?? ""
                              : widget.categories[index].titleEn ?? "",
                        )),
                      );
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.greyColor1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.secoundryColor.withOpacity(.2),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: WidgetCachNetworkImage(
                        image: widget.categories[index].icon ?? "",
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: AppSize(context).width * .2, // Set appropriate width
                    child: Text(
                      languageProvider.lang == "ar"
                          ? widget.categories[index].titleAr ?? ""
                          : widget.categories[index].titleEn ?? "",
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppSize(context).smallText4,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GlassmorphicBottomSheet extends StatefulWidget {
  final String title;
  _GlassmorphicBottomSheet({required this.title});

  @override
  State<_GlassmorphicBottomSheet> createState() =>
      _GlassmorphicBottomSheetState();
}

class _GlassmorphicBottomSheetState extends State<_GlassmorphicBottomSheet> {
  bool? isAddedd = false;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, controller) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(25)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Explore Options for ${widget.title}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.separated(
                      controller: controller,
                      itemCount: 5,
                      padding: const EdgeInsets.all(16),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, index) => ServiceCardWidget(
                        isAddedd: isAddedd,
                        onTap: () {
                          setState(() {
                            isAddedd = !isAddedd!;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
