import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingText extends StatelessWidget {
  final double width;
  final Color? color;
  final double? height;

  final double? radius;
  const LoadingText(
      {super.key, this.color, required this.width, this.height, this.radius});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: color ?? Colors.grey[100]!,
      child: Container(
        width: width,
        height: height ?? 9.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius ?? 8.0),
        ),
      ),
    );
  }
}
