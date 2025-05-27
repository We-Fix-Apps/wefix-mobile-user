import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Presentation/Components/custom_cach_network_image.dart';

class SliderWidget extends StatefulWidget {
  final List<String> images;
  const SliderWidget({super.key, required this.images});

  @override
  State<SliderWidget> createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: widget.images.map((e) {
        return SizedBox(
          width: AppSize(context).width,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: WidgetCachNetworkImage(
              image: e,
              boxFit: BoxFit.cover,
            ),
          ),
        );
      }).toList(),
      options: CarouselOptions(
        height: AppSize(context).height * .2,
        aspectRatio: .8,
        initialPage: 0,
        enableInfiniteScroll: true,
        reverse: false,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastEaseInToSlowEaseOut,
        enlargeCenterPage: true,
        viewportFraction: .7,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}
