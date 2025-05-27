// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';

class CustomCheckConnection extends StatelessWidget {
  final Widget child;
  const CustomCheckConnection({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    return appProvider.connectivityResult == ConnectivityResult.none
        ? Scaffold(
            body: Center(
              child: Container(
                width: AppSize(context).width * 0.3,
                height: AppSize(context).height * 0.15,
                decoration: BoxDecoration(
                  color: AppColors.greyColor1,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                        color: AppColors.greyColor2),
                    SizedBox(
                      height: AppSize(context).width * 0.2,
                    ),
                    Text('Check your internet connection',
                        style: TextStyle(
                          fontSize: AppSize(context).mediumText2,
                        ))
                  ],
                ),
              ),
            ),
          )
        : child;
  }
}
