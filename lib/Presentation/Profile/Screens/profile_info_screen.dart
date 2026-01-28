// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:image_picker/image_picker.dart';

import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/orders/profile_api.dart';
import 'package:wefix/Business/uplade_image.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/image_picker_class.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Data/model/profile_model.dart';

import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Components/custom_cach_network_image.dart';
import 'package:wefix/Presentation/Components/language_icon.dart';
import 'package:wefix/Presentation/Components/widget_dialog.dart';
import 'package:wefix/Presentation/Components/widget_form_text.dart';
import 'package:wefix/Presentation/Loading/drop_down_loading.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  TextEditingController phoneController = TextEditingController();
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  bool? loadingUpdate;
  bool isVisiable = false;
  File? imageFile;
  String? imageProfile;
  String? phone;
  RegExp regExp2 = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  ProfileModel? profileModel;

  bool loading = false;
  bool loadingEdit = false;

  bool? someUpdate;

  var formKey = GlobalKey<FormState>();

  @override
  void initState() {
    getUser().then((value) {
      firstName.text = profileModel?.profile?.firstname ?? "";
      lastName.text = profileModel?.profile?.lastname ?? "";
      email.text = profileModel?.profile?.email ?? "";
      imageProfile = profileModel?.profile?.profileImage ?? "";
    });

    // phoneController.text = appProvider.userModel?.userInfo?. ?? "";
    // password.text = appProvider.userModel?.userInfo?.password ?? '';
    // email.text = appProvider.user?.userInfo?.email ?? "";

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: AppSize(context).width * 0.25,
                      height: AppSize(context).width * 0.25,
                      decoration: BoxDecoration(
                        boxShadow: const [
                          BoxShadow(
                              blurRadius: 1,
                              blurStyle: BlurStyle.outer,
                              color: Colors.white)
                        ],
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(0),
                        height: AppSize(context).width * 0.4,
                        width: AppSize(context).width * 0.4,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: AppColors.greyColor1,
                            )),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10000),
                          child: WidgetCachNetworkImage(
                            image: imageProfile ?? "",
                            boxFit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: AppColors(context).primaryColor),
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: const [
                            BoxShadow(
                                blurRadius: 0,
                                blurStyle: BlurStyle.outer,
                                offset: Offset(0.1, 0))
                          ],
                          color: Colors.white),
                      child: Center(
                        child: IconButton(
                            splashRadius: 20,
                            onPressed: () async {
                              showBottom();
                              setState(() {});
                            },
                            icon: Icon(
                              Icons.edit,
                              color: AppColors(context).primaryColor,
                              size: 20,
                            )),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                "Personal Informtion",
                style: TextStyle(
                  fontSize: AppSize(context).mediumText3,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(
                color: AppColors.greyColor,
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  loading == true
                      ? const Expanded(child: DropDownLoading())
                      : Expanded(
                          child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppText(context).firstName,
                              style: TextStyle(
                                  fontSize: AppSize(context).smallText3),
                            ),
                            WidgetTextField(
                              "abdallah",
                              fillColor: AppColors.greyColorback,
                              controller: firstName,
                              validator: (p0) {
                                if (firstName.text.isEmpty) {
                                  return AppText(context, isFunction: true)
                                      .required;
                                } else {
                                  return null;
                                }
                              },
                              haveBorder: false,
                              radius: 5,
                            ),
                          ],
                        )),
                  const SizedBox(
                    width: 5,
                  ),
                  loading == true
                      ? const Expanded(child: DropDownLoading())
                      : Expanded(
                          child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppText(context).lastName,
                              style: TextStyle(
                                  fontSize: AppSize(context).smallText3),
                            ),
                            WidgetTextField(
                              "abuasab",
                              fillColor: AppColors.greyColorback,
                              controller: lastName,
                              validator: (p0) {
                                if (lastName.text.isEmpty) {
                                  return AppText(context, isFunction: true)
                                      .required;
                                } else {
                                  return null;
                                }
                              },
                              haveBorder: false,
                              radius: 5,
                            ),
                          ],
                        ))
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                AppText(context).email,
                style: TextStyle(fontSize: AppSize(context).smallText3),
              ),
              loading == true
                  ? const DropDownLoading()
                  : WidgetTextField(
                      "exampel@gmail.com",
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      fillColor: AppColors.greyColorback,
                      validator: (p0) {
                        if (email.text.isEmpty) {
                          return AppText(context, isFunction: true).required;
                        } else if (!regExp2.hasMatch(email.text)) {
                          return AppText(context, isFunction: true)
                              .invalidEmail;
                        }
                        return null;
                      },
                      haveBorder: false,
                      radius: 5,
                    ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          right: AppSize(context).width * 0.04,
          left: AppSize(context).width * 0.04,
          bottom: MediaQuery.of(context).viewInsets.bottom + 10,
          top: AppSize(context).height * 0.02,
        ),
        child: CustomBotton(
          title: AppText(context).update,
          loading: loadingEdit,
          onTap: () {
            if (formKey.currentState!.validate()) {
              editProfile();
            }
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      actions: const [
        LanguageButton(),
      ],
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: AppColors(context).primaryColor,
        statusBarIconBrightness: Brightness.light,
      ),
      backgroundColor: AppColors(context).primaryColor,
      title: Text(
        AppText(context).profile,
        style: TextStyle(
          fontSize: AppSize(context).mediumText3,
          color: AppColors.whiteColor1,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future getUser() async {
    setState(() {
      loading = true;
    });
    try {
      AppProvider appProvider =
          Provider.of<AppProvider>(context, listen: false);
      await ProfileApis.getProfileData(
        token: appProvider.userModel?.token ?? '',
      ).then((value) {
        if (mounted) {
          setState(() {
            profileModel = value;
          });
          setState(() {
            loading = false;
          });
        }
      });
    } catch (e) {
      log('getCart [ ERROR ] $e');
      setState(() {
        loading = false;
      });
    }
  }

  Future editProfile() async {
    setState(() {
      loadingEdit = true;
    });
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    try {
      await ProfileApis.editProfile(
        email: email.text,
        firstName: firstName.text,
        image: imageProfile ?? "",
        lastName: lastName.text,
        token: appProvider.userModel?.token ?? '',
      ).then((value) {
        showDialog(
          context: context,
          builder: (context) => const WidgetDialog(
            title: 'Successfully',
            desc: 'Your information has been updated successfully.',
            isError: false,
          ),
        );
        // appProvider.updateUserData(
        //     name: "${firstName.text} ${lastName.text}", email: email.text);
        setState(() {
          loadingEdit = false;
        });
        log(value.toString());
      });
    } catch (e) {
      log('editProfile() error = > $e');
      setState(() {
        loadingEdit = false;
      });
    }
  }

  Future uploadFile({bool? isCavar = false}) async {
    AppProvider appProvider = Provider.of(context, listen: false);

    await UpladeImages.upladeImage(
      token: '${appProvider.userModel?.token}',
      file: imageFile!,
    ).then((value) {
      if (value != null) {
        setState(() {
          imageProfile = value;
        });
      }
    });
  }

  void showBottom({bool isCover = false}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            // height: AppSize(context).height * 0.23,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 5,
                    decoration: BoxDecoration(
                        color: AppColors.greyColor1,
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  // * Add Car
                  InkWell(
                    onTap: () {
                      pickImage(
                              source: ImageSource.gallery,
                              context: context,
                              needPath: true)
                          .then((value) async {
                        if (value != null) {
                          setState(() {
                            imageFile = value;
                          });
                          await uploadFile(isCavar: isCover);
                          setState(() {
                            someUpdate = true;
                          });
                          pop(context);
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: AppColors.greyColor3,
                            child: Icon(
                              Icons.image_outlined,
                              color: AppColors.whiteColor1,
                            ),
                          ),
                          SizedBox(width: AppSize(context).width * 0.02),
                          RichText(
                            textAlign: TextAlign.start,
                            text: TextSpan(
                              text: 'Select a Picture From Gallery',
                              style: TextStyle(
                                color: AppColors.blackColor1,
                                fontSize: AppSize(context).mediumText4,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // * Add WishList
                  InkWell(
                    onTap: () {
                      pickImage(
                              source: ImageSource.camera,
                              context: context,
                              needPath: true)
                          .then((value) async {
                        if (value != null) {
                          setState(() {
                            imageFile = value;
                          });
                          await uploadFile(isCavar: isCover);
                          setState(() {
                            someUpdate = true;
                          });
                          pop(context);
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: AppColors.greyColor3,
                            child: Icon(
                              Icons.camera_alt_outlined,
                              color: AppColors.whiteColor1,
                            ),
                          ),
                          SizedBox(width: AppSize(context).width * 0.02),
                          RichText(
                            textAlign: TextAlign.start,
                            text: TextSpan(
                              text: 'Take a Picture From Camera',
                              style: TextStyle(
                                color: AppColors.blackColor1,
                                fontSize: AppSize(context).mediumText4,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
