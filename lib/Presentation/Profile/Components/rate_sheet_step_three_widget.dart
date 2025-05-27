// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:wefix/Data/Constant/theme/color_constant.dart';
// import 'package:wefix/Data/Functions/app_size.dart';
// import 'package:wefix/Data/appText/appText.dart';
// import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
// import 'package:wefix/Presentation/Components/widget_form_text.dart';
// import 'package:wefix/Presentation/Profile/Components/list_rate_type_widget.dart';

// class RateSheetStepThree extends StatefulWidget {
//   const RateSheetStepThree({super.key});

//   @override
//   State<RateSheetStepThree> createState() => _RateSheetStepThreeState();
// }

// class _RateSheetStepThreeState extends State<RateSheetStepThree> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: AppColors.whiteColor1,
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Row(
//               children: [
//                 SvgPicture.asset("assets/icon/smile.svg",
//                     color: AppColors.greenColor, width: 40, height: 40),
//                 const SizedBox(width: 5),
//                 Text(
//                   "${AppText(context ,isFunction: true).tellusmore}",
//                   style: TextStyle(
//                     fontSize: AppSize(context).smallText1,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 )
//               ],
//             ),
//             const Divider(
//               color: AppColors.backgroundColor,
//             ),
//             const SizedBox(
//               height: 10,
//             ),
//              WidgetTextField(
//               "${AppText(context , isFunction: true).tellusmore} ...",
//               maxLines: 3,
//             ),
//              WidgetTextField(
//               AppText(context , isFunction: true).phone,
//               keyboardType: TextInputType.numberWithOptions(),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   CustomBotton(
//                     title:AppText(context , isFunction: true).skip,
//                     onTap: () {},
//                     width: AppSize(context).width * 0.2,
//                     height: AppSize(context).height * 0.04,
//                     color: AppColors.whiteColor1,
//                     border: true,
//                     textColor: AppColors(context).primaryColor,
//                   ),
//                   SizedBox(
//                     width: AppSize(context).width * 0.02,
//                   ),
//                   CustomBotton(
//                     title: "Done",
//                     onTap: () {},
//                     height: AppSize(context).height * 0.04,
//                     width: AppSize(context).width * 0.2,
//                   )
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
