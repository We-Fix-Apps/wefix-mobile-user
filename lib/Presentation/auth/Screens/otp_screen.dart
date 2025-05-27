// ignore_for_file: file_names, use_build_context_synchronously, avoid_print

import 'dart:async';
import 'dart:developer';

import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/Authantication/auth_apis.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Data/model/login_model.dart';
import 'package:wefix/Data/model/user_model.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Components/language_icon.dart';
import 'package:wefix/Presentation/Components/widget_dialog.dart';

import 'package:wefix/layout_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Presentation/Components/custom_button.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:provider/provider.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String? verificationId;
  final String? otp;

  final String? phone;
  final List? signUp;
  const VerifyCodeScreen(
      {super.key, this.verificationId, this.phone, this.signUp, this.otp});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final key = GlobalKey<FormState>();
  TextEditingController textEditingController = TextEditingController();
  StreamController<ErrorAnimationType>? errorController;
  bool hasError = false;
  bool loading = false;
  bool loading2 = false;

  bool loadingResend = false;
  String currentText = "";
  UserModel? userModel;
  LoginModel? loginModel;

  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    super.initState();
  }

  @override
  void dispose() {
    errorController!.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: buildBottom(),
    );
  }

  Scaffold _buildBody() {
    AppLocalizations lang = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        actions: [
          LanguageButton(),
        ],
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text(
          AppText(context).verify,
        ),
      ),
      body: Stack(
        children: [
          SvgPicture.asset("assets/icon/background.svg"),
          SafeArea(
              child: SingleChildScrollView(
            padding: AppSize(context).appPadding,
            child: Form(
              key: key,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppText(context).verify,
                    style: TextStyle(
                      fontSize: AppSize(context).largText2,
                      color: AppColors(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSize(context).height * 0.01),
                  Text(
                    AppText(context).verifyYourMobailNumber,
                    style: TextStyle(
                      fontSize: AppSize(context).mediumText2,
                      color: AppColors.blackColor1,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: AppSize(context).height * 0.01),
                  Text(
                    '${AppText(context).wesentcodetothenumber} ${widget.phone}',
                    style: TextStyle(
                      fontSize: AppSize(context).smallText2,
                      color: AppColors.greyColor3,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  SizedBox(height: AppSize(context).height * 0.1),
                  PinCodeTextField(
                    appContext: context,
                    textStyle: TextStyle(
                      fontSize: AppSize(context).mediumText3,
                      color: AppColors.whiteColor1,
                    ),
                    pastedTextStyle: const TextStyle(
                      color: AppColors.whiteColor1,
                      fontWeight: FontWeight.bold,
                    ),
                    length: 4,
                    backgroundColor: AppColors.whiteColor1,
                    animationType: AnimationType.fade,
                    enablePinAutofill: true,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(5),
                      fieldHeight: 55,
                      fieldWidth: 60,
                      selectedColor: AppColors(context).primaryColor,
                      inactiveFillColor: AppColors.greyColorback,
                      selectedFillColor: AppColors.whiteColor1,
                      inactiveColor: AppColors.whiteColor1,
                      activeColor: AppColors.whiteColor1,
                      activeFillColor: AppColors(context).primaryColor,
                      disabledColor: AppColors.whiteColor1,
                    ),
                    cursorColor: Colors.black,
                    animationDuration: const Duration(milliseconds: 300),
                    enableActiveFill: true,
                    errorAnimationController: errorController,
                    controller: textEditingController,
                    keyboardType: TextInputType.number,
                    boxShadows: const [
                      BoxShadow(
                        offset: Offset(0, 1),
                        color: Colors.black12,
                        blurRadius: 10,
                      )
                    ],
                    onCompleted: (v) {
                      debugPrint("Completed");
                    },
                    onChanged: (value) {
                      debugPrint(value);
                      setState(() {
                        currentText = value;
                      });
                    },
                    beforeTextPaste: (text) {
                      debugPrint("Allowing to paste $text");
                      return true;
                    },
                  ),
                  SizedBox(height: AppSize(context).height * 0.01),
                  Center(
                    child: loadingResend == true
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '${AppText(context).dontreceivecode}',
                                style: TextStyle(
                                  fontSize: AppSize(context).smallText2,
                                  color: AppColors.blackColor1,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              const SizedBox(
                                width: 30,
                                height: 30,
                                child: CircularProgressIndicator(),
                              ),
                            ],
                          )
                        : RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text: '${AppText(context).dontreceivecode} ? ',
                              style: TextStyle(
                                fontSize: AppSize(context).smallText2,
                                color: AppColors.blackColor1,
                                fontWeight: FontWeight.normal,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: AppText(context).resend,
                                  style: TextStyle(
                                    fontSize: AppSize(context).smallText1,
                                    color: AppColors(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      login().then((value) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          backgroundColor: AppColors.greenColor,
                                          content: Text(
                                              AppText(context, isFunction: true)
                                                  .successfully),
                                        ));
                                      });
                                    },
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Padding buildBottom() {
    // AppLocalizations lang = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.only(
        right: AppSize(context).width * 0.04,
        left: AppSize(context).width * 0.04,
        bottom: AppSize(context).height * 0.03,
        top: AppSize(context).height * 0.02,
      ),
      child: CustomBotton(
        title: AppText(context).confirm,
        loading: loading,
        onTap: () async {
          checkOtp();
        },
      ),
    );
  }

  checkOtp() {
    if (widget.otp == textEditingController.text) {
      checkOtpFun();
    } else {
      showDialog(
        context: context,
        builder: (context) => WidgetDialog(
          title: AppText(context, isFunction: true).warning,
          desc: AppText(context, isFunction: true).otpWrong,
          isError: true,
        ),
      );
    }
  }

  Future login() async {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    try {
      setState(() {
        loading2 = true;
      });
      await Authantication.login(user: {
        'Mobile': widget.phone,
      }).then((value) {
        if (value?.status != false) {
          setState(() {
            loginModel = value;
          });

          setState(() {
            loading2 = false;
          });
        } else {
          setState(() {
            loading2 = false;
          });
        }
      });
    } catch (e) {
      log('Login Is Error');
      setState(() {
        loading = false;
      });
    }
  }

  Future checkOtpFun() async {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    try {
      setState(() {
        loading = true;
      });
      await Authantication.checkOtp(
        otp: textEditingController.text,
        fcmToken: appProvider.fcmToken ?? "",
        phone: widget.phone.toString(),
      ).then((value) {
        setState(() {
          userModel = value;
        });
        if (value?.status == true) {
          appProvider.addUser(user: value);
          log(appProvider.userModel?.token.toString() ?? "");
          Navigator.pushAndRemoveUntil(
              context, downToTop(const HomeLayout()), (route) => false);

          setState(() {
            loading = false;
          });
        } else {
          showDialog(
            context: context,
            builder: (context) => WidgetDialog(
              title: AppText(context, isFunction: true).warning,
              desc: AppText(context, isFunction: true).otpWrong,
              isError: true,
            ),
          );
          setState(() {
            loading = false;
          });
        }
      });
    } catch (e) {
      log('Login Is Error');
      setState(() {
        loading = false;
      });
    }
  }

  // Future verfiyPhoneCode() async {
  //   // AppLocalizations lang = AppLocalizations.of(context)!;

  //   setState(() {
  //     loading = true;
  //   });
  //   try {
  //     PhoneAuthCredential credential = PhoneAuthProvider.credential(
  //       verificationId: widget.verificationId!,
  //       smsCode: textEditingController.text,
  //     );
  //     await auth.signInWithCredential(credential);
  //     await signIn();
  //   } on FirebaseAuthException catch (e) {
  //     log(e.message.toString());
  //     setState(() {
  //       loading = false;
  //     });

  //     showDialog(
  //         context: context,
  //         builder: (context) => CustomDialog(
  //             title: AppText(context, isFunction: true).warning,
  //             icon: Icon(
  //               Icons.priority_high_rounded,
  //               size: 45,
  //             ),
  //             description: AppText(context, isFunction: true).notCorrect,
  //             buttonText: AppText(context, isFunction: true).back));
  //   }
  // }

  // Future resendCode() async {
  //   // AppLocalizations lang = AppLocalizations.of(context)!;

  //   setState(() {
  //     loadingResend = true;
  //   });
  //   await auth.verifyPhoneNumber(
  //       phoneNumber: widget.phone ?? widget.signUp?[1]['Phone'],
  //       verificationCompleted: (PhoneAuthCredential credential) async {},
  //       verificationFailed: (FirebaseAuthException e) {
  //         setState(() {
  //           loading = false;
  //         });
  //         log(e.message.toString());
  //         showDialog(
  //             context: context,
  //             builder: (context) => CustomDialog(
  //                 title: AppText(context, isFunction: true).warning,
  //                 icon: Icon(
  //                   Icons.priority_high_rounded,
  //                   size: 45,
  //                 ),
  //                 description: AppText(context, isFunction: true).notCorrect,
  //                 buttonText: AppText(context, isFunction: true).back));
  //       },
  //       codeSent: (String verificationId, int? resendToken) {
  //         setState(() {
  //           loadingResend = false;
  //         });
  //       },
  //       codeAutoRetrievalTimeout: (String verificationId) {},
  //       timeout: const Duration(seconds: 120));
  // }

  // Future signIn() async {
  //   AppProvider appProvider = Provider.of(context, listen: false);
  //   await AuthApi.login(phone: widget.phone ?? "").then((value) {
  //     if (value is String) {
  //       showDialog(
  //           context: context,
  //           builder: (context) => CustomDialog(
  //               title: AppText(context, isFunction: true).warning,
  //               icon: const Icon(
  //                 Icons.priority_high_rounded,
  //                 size: 45,
  //               ),
  //               description: value,
  //               buttonText: AppText(context, isFunction: true).back));
  //     } else {
  //       appProvider.addUser(value);
  //       Navigator.pushAndRemoveUntil(
  //           context, downToTop(const LayoutScreen()), (route) => false);
  //     }
  //   });
  // }
}
