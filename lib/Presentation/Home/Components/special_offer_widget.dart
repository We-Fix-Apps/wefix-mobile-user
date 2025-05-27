import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/LanguageProvider/l10n_provider.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/model/home_model.dart';
import 'package:wefix/Presentation/Components/custom_cach_network_image.dart';
import 'package:wefix/Presentation/SubCategory/Screens/sub_services_screen.dart';

import '../../../Data/Functions/navigation.dart';

class OffersSection extends StatefulWidget {
  final List<Service> services;

  const OffersSection({super.key, required this.services});

  @override
  State<OffersSection> createState() => _OffersSectionState();
}

class _OffersSectionState extends State<OffersSection> {
  @override
  Widget build(BuildContext context) {
    LanguageProvider languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Special Offers Title

          // Special Offers Horizontal Scroll
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              separatorBuilder: (context, index) => const SizedBox(
                width: 5,
              ),
              itemCount: widget.services.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      downToTop(SubServicesScreen(
                        catId: widget.services[index].id,
                        title: languageProvider.lang == "ar"
                            ? widget.services[index].nameAr ?? ""
                            : widget.services[index].name ?? "",
                      )),
                    );
                  },
                  child: _specialOfferItem(
                    context,
                    image: widget.services[index].image ?? "",
                    title: languageProvider.lang == "ar"
                        ? widget.services[index].nameAr ?? ""
                        : widget.services[index].name ?? "",
                    price: "${widget.services[index].price} JOD",
                  ),
                );
              },
            ),
          ),

          // // Most Requested Vertical List
          // _mostRequestedItem(
          //   context,
          //   image:
          //       "https://cdn.shopify.com/s/files/1/0413/1202/6777/articles/how-to-clean-your-split-ac-indoor-unit-at-home_36bb1e12-59ce-47c4-9a87-ea83f53af77b.jpg?v=1616919533",
          //   title: 'Smart Lock with Camera',
          //   price: 'Starts from 100 JOD',
          // ),
          // _mostRequestedItem(
          //   context,
          //   image:
          //       "https://cdn.shopify.com/s/files/1/0413/1202/6777/articles/how-to-clean-your-split-ac-indoor-unit-at-home_36bb1e12-59ce-47c4-9a87-ea83f53af77b.jpg?v=1616919533",
          //   title: 'Fingerprint Lock TTLock',
          //   price: 'Starts from 70 JOD',
          // ),
          // _mostRequestedItem(
          //   context,
          //   image: 'assets/smoke_detector.png',
          //   title: 'Smoke & Gas Detector',
          //   price: 'Starts from 75 JOD',
          // ),
        ],
      ),
    );
  }

  Widget _specialOfferItem(BuildContext context,
      {required String image, required String title, required String price}) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Container(
            width: AppSize(context).height * .2,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: WidgetCachNetworkImage(image: image),
            )),
        Opacity(
          opacity: .5,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.blackColor1,
              borderRadius: BorderRadius.circular(10),
            ),
            width: AppSize(context).height * .2,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: AppSize(context).height * .15,
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.whiteColor1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Text(
              //   price,
              //   style: const TextStyle(
              //     color: AppColors.whiteColor1,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
            ],
          ),
        ),
      ],
    );
  }
}
