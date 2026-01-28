import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';

class EmptyScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? image;
  final String? titleBtn;

  final Function()? onTap;

  const EmptyScreen({
    Key? key,
    this.title = 'No Items Found',
    this.subtitle = 'There’s nothing here yet. Please check back later!',
    this.image,
    this.titleBtn,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              image ?? "assets/icon/empty.svg",
              height: AppSize(context).height * .4,
            ),
            // const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors(context).primaryColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            titleBtn == null
                ? const SizedBox()
                : CustomBotton(
                    title: titleBtn ?? "",
                    onTap: onTap,
                  )
          ],
        ),
      ),
    );
  }
}
