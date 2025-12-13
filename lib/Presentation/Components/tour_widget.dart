import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Helper/cache_helper.dart';
import 'package:wefix/Presentation/Components/custom_cach_network_image.dart';

class CustomeTutorialCoachMark {
  CustomeTutorialCoachMark._();
  static late TutorialCoachMark tutorialCoachMark;
  static List<TargetFocus> addTargets(
    List<Map<dynamic, dynamic>> content,
    List<GlobalKey<State<StatefulWidget>>?> keys,
  ) {
    return keys
        .asMap()
        .entries
        .where((entry) {
          // Filter out null keys and keys without attached widgets
          final key = entry.value;
          if (key == null) return false;
          // Check if key has a current context (widget is attached)
          return key.currentContext != null;
        })
        .map((entry) {
          final index = entry.key;
          final key = entry.value;

          final data = content[index];

          return TargetFocus(
            identify: key.toString(),
            keyTarget: key,
            contents: [
              TargetContent(
                align: data["isTop"] == true
                    ? ContentAlign.top
                    : ContentAlign.bottom,
                builder: (context, controller) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      data['icon'] == null
                          ? const SizedBox.shrink()
                          : Icon(
                              data['icon'],
                              size: 50,
                              color: AppColors(context).primaryColor,
                            ),
                      data['image'] != null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Container(
                                //   width: 70,
                                //   height: 70,
                                //   decoration: BoxDecoration(
                                //       shape: BoxShape.circle,
                                //       color: Colors.white,
                                //       border: Border.all(
                                //           color: AppColors.secoundryColor)),
                                //   child: Image.asset(
                                //     data['image'] ?? "",
                                //   ),
                                // ),
                                data["isTop"] == true
                                    ? SizedBox()
                                    : Image.asset(
                                        "assets/image/white c-01.png",
                                        width: 150,
                                        height: 150,
                                      )
                              ],
                            )
                          : const SizedBox.shrink(),
                      Text(
                        data['title'] ?? "",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20.0,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          data['description'] ?? "",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
            shape: ShapeLightFocus.RRect,
          );
        })
        .whereType<TargetFocus>()
        .toList(); // ✅ remove nulls
  }

  static void createTutorial(List<GlobalKey<State<StatefulWidget>>?> keys,
      List<Map<dynamic, dynamic>> content) {
    tutorialCoachMark = TutorialCoachMark(
      skipWidget: SizedBox(),
      targets: addTargets(content, keys),
      colorShadow: Colors.black,
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: .4,
      imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      onFinish: () {},
      onClickTarget: (target) {},
      onClickTargetWithTapPosition: (target, tapDetails) {},
      onClickOverlay: (target) {},
    );
  }

  static void showTutorial(BuildContext context, {bool? isShow = true}) {
    if (isShow == true) {
      tutorialCoachMark.show(context: context);
    }
  }
}
