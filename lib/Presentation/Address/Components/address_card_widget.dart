import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/model/address_model.dart';

class AddressCardWidget extends StatelessWidget {
  final CustomerAddress? address;
  const AddressCardWidget({super.key, this.address});

  @override
  Widget build(BuildContext context) {
    AppProvider appProvider = Provider.of(context, listen: false);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyColorback, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: AppSize(context).width * .8,
                    child: Text(
                      address?.address ?? 'Home',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppSize(context).mediumText4,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // address?.isDefault == false
                  //     ? const SizedBox()
                  //     : Container(
                  //         padding: const EdgeInsets.symmetric(
                  //             horizontal: 8, vertical: 4),
                  //         decoration: BoxDecoration(
                  //           color: AppColors.greenColor,
                  //           borderRadius: BorderRadius.circular(12),
                  //         ),
                  //         child: Text(
                  //           'Main address',
                  //           style: TextStyle(
                  //             color: AppColors.whiteColor1,
                  //             fontSize: AppSize(context).smallText4,
                  //           ),
                  //         ),
                  //       ),
                ],
              ),
              // address?.isDefault == false
              //     ? const SizedBox()
              //     : SvgPicture.asset("assets/icon/selected.svg"),
            ],
          ),
          const SizedBox(
            height: 5,
          ),

          const Divider(
            color: AppColors.greyColorback,
            height: 5,
          ),
          const SizedBox(
            height: 5,
          ),

          // Name and Phone
          Text(
            '${appProvider.userModel?.customer.name} | ${appProvider.userModel?.customer.mobile}',
            style: TextStyle(
              fontSize: AppSize(context).smallText1,
              color: AppColors.blackColor3,
            ),
          ),
          const SizedBox(height: 12),

          // Description / Address details
          // const Text(
          //   'Lorem ipsum dolor sit amet consectetur. In nunc congue '
          //   'mollis ornare eget facilisis. Eu nec pellentesque nisl libero '
          //   'placerat aliquam nulla a velit. 32133',
          //   style: TextStyle(
          //     fontSize: 14,
          //     color: Colors.black54,
          //     height: 1.4,
          //   ),
          // ),
        ],
      ),
    );
  }
}
