import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Presentation/appointment/Components/google_maps_widget.dart';
import 'package:wefix/Presentation/Loading/loading_text.dart';

class WidgetAddressCheckout extends StatefulWidget {
  final String addressName;
  final String addressNameStreet;
  final String lat;
  final String long;

  final bool? loading;
  const WidgetAddressCheckout({
    super.key,
    required this.addressName,
    this.loading,
    required this.lat,
    required this.long,
    required this.addressNameStreet,
  });

  @override
  State<WidgetAddressCheckout> createState() => _WidgetAddressCheckoutState();
}

class _WidgetAddressCheckoutState extends State<WidgetAddressCheckout> {
  @override
  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: AppColors.lightGreyColor, width: .5)),
      child: Column(
        children: [
          SizedBox(
            width: AppSize(context).width,
            height: AppSize(context).height * .15,
            child: WidgewtGoogleMaps(
              isFromCheckOut: true,
              lat: double.tryParse(widget.lat),
              loang: double.tryParse(widget.long),
            ),
          ),
          // SizedBox(
          //   height: AppSize(context).height * .01,
          // ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Column(
          //     children: [
          //       Row(
          //         children: [
          //           SvgPicture.asset(
          //             "assets/icon/pin-svgrepo-com.svg",
          //             color: AppColors(context).primaryColor,
          //             height: 20,
          //           ),
          //           const SizedBox(
          //             width: 10,
          //           ),
          //           SizedBox(
          //             width: AppSize(context).width * .8,
          //             child: Text(
          //               widget.addressName,
          //               maxLines: 1,
          //               overflow: TextOverflow.ellipsis,
          //               style: TextStyle(fontSize: AppSize(context).smallText3),
          //             ),
          //           ),
          //         ],
          //       ),
          //       const Divider(
          //         color: AppColors.greyColorback,
          //       ),
          //       Row(
          //         children: [
          //           SvgPicture.asset(
          //             "assets/icon/walk-svgrepo-com.svg",
          //             color: AppColors(context).primaryColor,
          //             height: 25,
          //           ),
          //           const SizedBox(
          //             width: 10,
          //           ),
          //           Text(
          //             widget.addressNameStreet,
          //             style: TextStyle(fontSize: AppSize(context).smallText3),
          //           ),
          //         ],
          //       ),
          //     ],
          //   ),
          // )
        ],
      ),
    );
  }
}
