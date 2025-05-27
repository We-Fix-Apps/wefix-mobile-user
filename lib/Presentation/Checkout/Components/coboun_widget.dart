import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Presentation/Components/widget_form_text.dart';

class CouponWidget extends StatefulWidget {
  final TextEditingController promoCodeController;
  final Function()? onTap;
  final bool? loading;
  const CouponWidget(
      {super.key, required this.promoCodeController, this.onTap, this.loading});

  @override
  State<CouponWidget> createState() => _CouponWidgetState();
}

class _CouponWidgetState extends State<CouponWidget> {
  // TextEditingController promoCodeController = TextEditingController();

  var key = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Form(
      key: key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "🎟️ ${AppText(context).saveonyourorder}",
            style: TextStyle(
              fontSize: AppSize(context).smallText1,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          WidgetTextField(
            AppText(context).checkout,
            controller: widget.promoCodeController,
            validator: (p0) {
              if (widget.promoCodeController.text.isEmpty) {
                return AppText(context, isFunction: true)
                    .thepromocodecantbeempty;
              } else {
                return null;
              }
            },
            haveBorder: false,
            prefixIcon: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(
                height: 10,
                child: SvgPicture.asset(
                  "assets/icon/discountshape.svg",
                  height: 20,
                ),
              ),
            ),
            suffixIcon: widget.loading == true
                ? Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: AppColors(context).primaryColor,
                      ),
                    ),
                  )
                : InkWell(
                    onTap: () {
                      if (key.currentState!.validate()) {
                        widget.onTap!();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 10,
                        child: CircleAvatar(
                          backgroundColor: AppColors(context).primaryColor,
                          child: SvgPicture.asset(
                            "assets/icon/arrowright2.svg",
                            color: AppColors.whiteColor1,
                            height: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
            fillColor: AppColors.greyColorback,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
