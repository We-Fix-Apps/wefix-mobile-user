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


class ServicesWidget extends StatefulWidget {
  final List<Category> categories;
  final int roleId;
  final GlobalKey? key1;

  const ServicesWidget({
    super.key,
    required this.categories,
    this.key1,
    required this.roleId,
  });

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
        // 10 = spacing compensation (2 gaps × 5)

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
                  category.subscribScreen == true
                      ? Navigator.push(
                          context,
                          downToTop(const SubscriptionScreen()),
                        )
                      : category.subCategory?.isNotEmpty == true
                          ? Navigator.push(
                              context,
                              downToTop(
                                SubCategoryScreen(
                                  categories: category.subCategory,
                                  title: category.titleEn,
                                  titleAr: category.titleAr,
                                ),
                              ),
                            )
                          : Navigator.push(
                              context,
                              downToTop(
                                SubServicesScreen(
                                  catId: category.id,
                                  title: languageProvider.lang == "ar"
                                      ? category.titleAr
                                      : category.titleEn,
                                ),
                              ),
                            );
                },
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 10,
                    children: [
                      WidgetCachNetworkImage(
                        image: category.icon ?? "",
                        height: 60,
                        width: 60,
                        boxFit: BoxFit.contain,
                      ),
                      Text(
                        languageProvider.lang == "ar"
                            ? category.titleAr ?? ""
                            : category.titleEn ?? "",
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppSize(context).smallText4,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// class _GlassmorphicBottomSheet extends StatefulWidget {
//   final String title;
//   _GlassmorphicBottomSheet({required this.title});

//   @override
//   State<_GlassmorphicBottomSheet> createState() => _GlassmorphicBottomSheetState();
// }

// class _GlassmorphicBottomSheetState extends State<_GlassmorphicBottomSheet> {
//   bool? isAddedd = false;

//   @override
//   Widget build(BuildContext context) {
//     return DraggableScrollableSheet(
//       initialChildSize: 0.65,
//       minChildSize: 0.4,
//       maxChildSize: 0.9,
//       builder: (_, controller) {
//         return ClipRRect(
//           borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
//           child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.85),
//                 borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 10,
//                     spreadRadius: 2,
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   const SizedBox(height: 12),
//                   Container(
//                     width: 40,
//                     height: 5,
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade400,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     'Explore Options for ${widget.title}',
//                     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 10),
//                   Expanded(
//                     child: ListView.separated(
//                       controller: controller,
//                       itemCount: 5,
//                       padding: const EdgeInsets.all(16),
//                       separatorBuilder: (_, __) => const SizedBox(height: 12),
//                       itemBuilder: (_, index) => ServiceCardWidget(
//                         isAddedd: isAddedd,
//                         onTap: () {
//                           setState(() {
//                             isAddedd = !isAddedd!;
//                           });
//                         },
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
