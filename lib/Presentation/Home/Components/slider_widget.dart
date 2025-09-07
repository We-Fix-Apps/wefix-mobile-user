import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Presentation/Components/custom_cach_network_image.dart';
import 'package:wefix/Presentation/SubCategory/Screens/sub_services_screen.dart';
import 'package:wefix/layout_screen.dart';

class SliderWidget extends StatefulWidget {
  final List<String> images;
  final List<int>? catId;
  final GlobalKey? key1;
  final Function()? onTap;
  const SliderWidget(
      {super.key, required this.images, this.onTap, this.catId, this.key1});

  @override
  State<SliderWidget> createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      key:widget.key1 ,
      items: widget.images.asMap().entries.map((entry) {
        int index = entry.key;
        String image = entry.value;

        return InkWell(
          onTap: () {
            log('Image tapped: $image at index: $index');
            if (widget.catId?[index] == 0) {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                builder: (context) {
                  return const HomeLayout(
                    index: 2,
                  );
                },
              ), (route) => false);
            } else {
              Navigator.push(
                context,
                downToTop(
                  SubServicesScreen(
                    title: AppText(context, isFunction: true)
                        .category, // optionally replace with a real one
                    catId: widget.catId![index],
                  ),
                ),
              );
            }
          },
          child: SizedBox(
            width: AppSize(context).width,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: WidgetCachNetworkImage(
                // key: widget.key1,
                image: image,
                boxFit: BoxFit.fill,
              ),
            ),
          ),
        );
      }).toList(),
      options: CarouselOptions(
      
        height: AppSize(context).height * .2,
        aspectRatio: 1,
        initialPage: 0,
        enableInfiniteScroll: true,
        reverse: false,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastEaseInToSlowEaseOut,
        enlargeCenterPage: true,
        viewportFraction: .85,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}
