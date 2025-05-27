import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';

class CircularLoginWidget extends StatefulWidget {
  final Function()? onTapGoogle;
  final Function()? onTapFaceBook;

  const CircularLoginWidget({super.key, this.onTapGoogle, this.onTapFaceBook});

  @override
  State<CircularLoginWidget> createState() => _CircularLoginWidgetState();
}

class _CircularLoginWidgetState extends State<CircularLoginWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
          onTap: widget.onTapFaceBook,
          child: const CircleAvatar(
            radius: 25,
            backgroundColor: AppColors.greyColorback,
            child: Image(
                height: 25,
                image: AssetImage("assets/icon/Facebook - png 0.png")),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        InkWell(
          onTap: widget.onTapGoogle,
          child: const CircleAvatar(
            radius: 25,
            backgroundColor: AppColors.greyColorback,
            child: Image(
              height: 25,
              image: AssetImage("assets/icon/Google - png 0.png"),
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        // if (Platform.isIOS == true)
        //   const CircleAvatar(
        //     radius: 25,
        //     backgroundColor: AppColors.greyColorback,
        //     child: Image(
        //         height: 25, image: AssetImage("assets/icon/appleIcon.png")),
        //   )
      ],
    );
  }
}
