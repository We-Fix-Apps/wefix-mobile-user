import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Presentation/Loading/loading_text.dart';

class NotificationCardWidget extends StatefulWidget {
  final String? title;
  final String? desc;
  final bool? loading;
  const NotificationCardWidget(
      {super.key, this.desc, this.title, this.loading = false});

  @override
  State<NotificationCardWidget> createState() => _NotificationCardWidgetState();
}

class _NotificationCardWidgetState extends State<NotificationCardWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      width: AppSize(context).width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.greyColorback,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset("assets/icon/notificationbing.svg"),
              ),
              widget.loading == true
                  ? LoadingText(width: AppSize(context).width * 0.3)
                  : Text(
                      widget.title ?? '',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.blackColor3,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ],
          ),
          const SizedBox(width: 20),
          widget.loading == true
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LoadingText(width: AppSize(context).width * 0.99),
                    const SizedBox(height: 5),
                    LoadingText(width: AppSize(context).width * 0.99),
                    const SizedBox(height: 5),
                    LoadingText(width: AppSize(context).width * 0.49),
                    const SizedBox(height: 5),
                  ],
                )
              : Text(
                  widget.desc ?? '',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.blackColor3,
                  ),
                )
        ],
      ),
    );
  }
}
