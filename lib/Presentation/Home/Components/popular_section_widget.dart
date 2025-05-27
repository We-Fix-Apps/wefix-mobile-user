import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/LanguageProvider/l10n_provider.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Data/model/home_model.dart';
import 'package:wefix/Presentation/Components/custom_cach_network_image.dart';
import 'package:wefix/Presentation/SubCategory/Screens/sub_services_screen.dart';

import '../../../Data/Constant/theme/color_constant.dart';

class PopularServicesSection extends StatefulWidget {
  final List<Service> services;
  const PopularServicesSection({super.key, required this.services});

  @override
  State<PopularServicesSection> createState() => _PopularServicesSectionState();
}

class _PopularServicesSectionState extends State<PopularServicesSection> {
  @override
  Widget build(BuildContext context) {
    LanguageProvider languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    return SizedBox(
      height: AppSize(context).height * .25,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.services.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                downToTop(SubServicesScreen(
                  catId: widget.services[index].id,
                  title: languageProvider.lang == "ar"
                      ? widget.services[index].nameAr?? ""
                      : widget.services[index].name ?? "",
                )),
              );
            },
            child: _mostRequestedItem(
              context,
              image: widget.services[index].image ?? "",
              title: languageProvider.lang == "ar"
                  ? widget.services[index].nameAr ?? ""
                  : widget.services[index].name ?? "",
              price: "${widget.services[index].price} ${AppText(context).jod}",
            ),
          );
        },
      ),
    );
  }

  Widget _mostRequestedItem(BuildContext context,
      {required String image, required String title, required String price}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // Makes the column take minimal space
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: AppSize(context).width * .4,
            height: AppSize(context).height * .15,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child:
                  WidgetCachNetworkImage(image: image), // Corrected class name
            ),
          ),
        ),
        SizedBox(
          width: AppSize(context).width * .4,
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.blackColor1,
              fontSize: AppSize(context).smallText3,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Text(
        //   price,
        //   style: TextStyle(
        //     color: AppColors(context).primaryColor,
        //     fontSize: AppSize(context).smallText3,
        //   ),
        // )
      ],
    );
  }
}
