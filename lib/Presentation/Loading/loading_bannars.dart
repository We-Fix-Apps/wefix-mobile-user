import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Presentation/Loading/loading_text.dart';

class LoadingBannars extends StatefulWidget {
  const LoadingBannars({super.key});

  @override
  State<LoadingBannars> createState() => _LoadingBannarsState();
}

class _LoadingBannarsState extends State<LoadingBannars> {
  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LoadingText(width: AppSize(context).width),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LoadingText(width: AppSize(context).width),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LoadingText(width: AppSize(context).width),
        ),
      ],
      options: CarouselOptions(
        height: AppSize(context).height * .35,
        aspectRatio: .0,
        initialPage: 0,
        enableInfiniteScroll: true,
        reverse: false,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 5),
        autoPlayAnimationDuration: const Duration(seconds: 1),
        autoPlayCurve: Curves.fastEaseInToSlowEaseOut,
        enlargeCenterPage: true,
        enlargeFactor: 0,
        scrollDirection: Axis.horizontal,
        viewportFraction: 1,
      ),
    );
  }
}
