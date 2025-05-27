import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/LanguageProvider/l10n_provider.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/model/home_model.dart';
import 'package:wefix/Presentation/Components/custom_cach_network_image.dart';
import 'package:wefix/Presentation/SubCategory/Screens/sub_services_screen.dart';

class SubCategoryScreen extends StatefulWidget {
  final String? title;
  final List<Category>? categories;
  const SubCategoryScreen({super.key, this.title, this.categories});

  @override
  State<SubCategoryScreen> createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  @override
  Widget build(BuildContext context) {
        LanguageProvider languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Sub Category'),
        centerTitle: true,
      ),
      body:  GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
          childAspectRatio: .9),
      itemCount: widget.categories?.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
          Navigator.push(
                    context,
                    downToTop(SubServicesScreen(
                      catId: widget.categories?[index].id ?? 0,
                      title: languageProvider.lang == "ar"
                          ? widget.categories![index].titleAr ?? ""
                          : widget.categories![index].titleEn ?? "",
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
                        image: widget.categories?[index].icon ?? "",
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: AppSize(context).width * .2, // Set appropriate width
                    child: Text(
                      languageProvider.lang == "ar"
                          ? widget.categories![index].titleAr ?? ""
                          : widget.categories![index].titleEn ?? "",
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
    )
  
    );
  }
}
