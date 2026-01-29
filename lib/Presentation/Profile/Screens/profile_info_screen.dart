// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:image_picker/image_picker.dart';

import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/orders/profile_api.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/image_picker_class.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Data/model/profile_model.dart';

// import 'package:wefix/Presentation/Components/custom_botton_widget.dart'; // Not needed - profile is readonly
import 'package:wefix/Presentation/Components/language_icon.dart';
import 'package:wefix/Presentation/Components/widget_dialog.dart';
import 'package:wefix/Presentation/Components/widget_form_text.dart';
import 'package:wefix/Presentation/Loading/drop_down_loading.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wefix/Business/end_points.dart';
import 'package:wefix/l10n/app_localizations.dart';

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
    super.initState();
    // Load initial data from AppProvider as fallback
    _populateFieldsFromAppProvider();
    // Then load and populate from API
    getUser();
  }

  // Populate fields from AppProvider (fallback values)
  void _populateFieldsFromAppProvider() {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    if (appProvider.userModel != null) {
      final customer = appProvider.userModel!.customer;
      // Try to extract first and last name from full name
      final nameParts = customer.name.split(' ');
      if (nameParts.length >= 2) {
        firstName.text = nameParts[0];
        lastName.text = nameParts.sublist(1).join(' ');
      } else if (nameParts.isNotEmpty) {
        firstName.text = nameParts[0];
      }
      email.text = customer.email.isNotEmpty ? customer.email : "";
      // phoneController.text = customer.mobile ?? "";
    }
  }

  // Populate fields from ProfileModel (after API load)
  void _populateFieldsFromProfile() {
    if (profileModel?.profile != null) {
      firstName.text = profileModel!.profile!.firstname ?? firstName.text;
      lastName.text = profileModel!.profile!.lastname ?? lastName.text;
      email.text = profileModel!.profile!.email ?? email.text;
      imageProfile = profileModel!.profile!.profileImage ?? imageProfile;
    }
  }

  // Helper function to get user initials
  String _getInitials(String? firstName, String? lastName) {
    String name = '';
    if (firstName != null && firstName.isNotEmpty) {
      name += firstName[0].toUpperCase();
    }
    if (lastName != null && lastName.isNotEmpty) {
      name += lastName[0].toUpperCase();
    }
    if (name.isEmpty) {
      return 'U';
    }
    return name;
  }

  // Helper function to check if image URL is valid
  bool _isValidImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return false;
    if (imageUrl.toLowerCase() == "null") return false;
    if (imageUrl.trim().isEmpty) return false;
    return true;
  }

  // Helper function to build full URL for profile image from backend-mms
  // Now uses /WeFixFiles/Images/ path to match backend-oms structure (single source of truth)
  String _buildImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return "";
    
    // If already a full URL (http/https), return as is
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    
    // Build base URL from backend-mms
    // mmsBaseUrl format: https://wefix-backend-mms.ngrok.app/api/v1/
    String baseUrl = EndPoints.mmsBaseUrl.replaceAll('/api/v1/', '').replaceAll(RegExp(r'/$'), '');
    
    // Normalize path - backend-mms now stores images in /WeFixFiles/Images/ to match backend-oms
    String cleanPath = imagePath.startsWith('/') ? imagePath : '/$imagePath';
    
    // If path already starts with /WeFixFiles, use it as is
    if (cleanPath.startsWith('/WeFixFiles')) {
      return '$baseUrl$cleanPath';
    }
    
    // For backward compatibility: if path is /uploads/filename, convert to /WeFixFiles/Images/filename
    if (cleanPath.startsWith('/uploads/')) {
      String filename = cleanPath.replaceFirst('/uploads/', '');
      return '$baseUrl/WeFixFiles/Images/$filename';
    }
    
    // If just a filename, assume it's in /WeFixFiles/Images/
    return '$baseUrl/WeFixFiles/Images/$cleanPath';
  }

  @override
  Widget build(BuildContext context) {
    final profileImageUrl = profileModel?.profile?.profileImage;
    
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
                          child: imageFile != null
                              ? Image.file(
                                  imageFile!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Fallback to network image or initials
                                    if (_isValidImageUrl(profileImageUrl)) {
                                      return CachedNetworkImage(
                                        imageUrl: _buildImageUrl(profileImageUrl),
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => CircleAvatar(
                                          backgroundColor: AppColors(context).primaryColor.withOpacity(0.1),
                                          child: Text(
                                            _getInitials(profileModel?.profile?.firstname, profileModel?.profile?.lastname),
                                            style: TextStyle(
                                              color: AppColors(context).primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) => CircleAvatar(
                                          backgroundColor: AppColors(context).primaryColor.withOpacity(0.1),
                                          child: Text(
                                            _getInitials(profileModel?.profile?.firstname, profileModel?.profile?.lastname),
                                            style: TextStyle(
                                              color: AppColors(context).primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    return CircleAvatar(
                                      backgroundColor: AppColors(context).primaryColor.withOpacity(0.1),
                                      child: Text(
                                        _getInitials(profileModel?.profile?.firstname, profileModel?.profile?.lastname),
                                        style: TextStyle(
                                          color: AppColors(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : _isValidImageUrl(profileImageUrl)
                                  ? CachedNetworkImage(
                                      imageUrl: _buildImageUrl(profileImageUrl),
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => CircleAvatar(
                                        backgroundColor: AppColors(context).primaryColor.withOpacity(0.1),
                                        child: Text(
                                          _getInitials(profileModel?.profile?.firstname, profileModel?.profile?.lastname),
                                          style: TextStyle(
                                            color: AppColors(context).primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => CircleAvatar(
                                        backgroundColor: AppColors(context).primaryColor.withOpacity(0.1),
                                        child: Text(
                                          _getInitials(profileModel?.profile?.firstname, profileModel?.profile?.lastname),
                                          style: TextStyle(
                                            color: AppColors(context).primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    )
                                  : CircleAvatar(
                                      backgroundColor: AppColors(context).primaryColor.withOpacity(0.1),
                                      child: Text(
                                        _getInitials(profileModel?.profile?.firstname, profileModel?.profile?.lastname),
                                        style: TextStyle(
                                          color: AppColors(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                          ),
                        ),
                      ),
                    ),
                    // Edit icon removed - profile is readonly for now
                    // Container(
                    //   width: 35,
                    //   height: 35,
                    //   decoration: BoxDecoration(
                    //       border: Border.all(
                    //           color: AppColors(context).primaryColor),
                    //       borderRadius: BorderRadius.circular(50),
                    //       boxShadow: const [
                    //         BoxShadow(
                    //             blurRadius: 0,
                    //             blurStyle: BlurStyle.outer,
                    //             offset: Offset(0.1, 0))
                    //       ],
                    //       color: Colors.white),
                    //   child: Center(
                    //     child: IconButton(
                    //         splashRadius: 20,
                    //         onPressed: () async {
                    //           showBottom();
                    //           setState(() {});
                    //         },
                    //         icon: Icon(
                    //           Icons.edit,
                    //           color: AppColors(context).primaryColor,
                    //           size: 20,
                    //         )),
                    //   ),
                    // ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                AppLocalizations.of(context)!.personalInformtion,
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
                              readOnly: true,
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
                              readOnly: true,
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
                      readOnly: true,
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
      // Update button removed - profile is readonly for now
      // bottomNavigationBar: Padding(
      //   padding: EdgeInsets.only(
      //     right: AppSize(context).width * 0.04,
      //     left: AppSize(context).width * 0.04,
      //     bottom: MediaQuery.of(context).viewInsets.bottom + 10,
      //     top: AppSize(context).height * 0.02,
      //   ),
      //   child: CustomBotton(
      //     title: AppText(context).update,
      //     loading: loadingEdit,
      //     onTap: () {
      //       if (formKey.currentState!.validate()) {
      //         editProfile();
      //       }
      //     },
      //   ),
      // ),
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
      final token = appProvider.accessToken ?? appProvider.userModel?.token ?? '';
      if (token.isEmpty) {
          setState(() {
            loading = false;
          });
        return;
      }
      
      // Check if user is company personnel (roles: 18, 20, 21, 22, 26)
      final roleId = appProvider.userModel?.customer.roleId;
      final roleIdInt = roleId is int ? roleId : (roleId is String ? int.tryParse(roleId.toString()) : null);
      final bool isCompany = roleIdInt != null && (roleIdInt == 18 || roleIdInt == 20 || roleIdInt == 21 || roleIdInt == 22 || roleIdInt == 26);
      
      final profile = await ProfileApis.getProfileData(
        token: token,
        isCompany: isCompany,
      );
      if (mounted) {
        setState(() {
          profileModel = profile;
          // Populate fields after loading profile data
          _populateFieldsFromProfile();
          loading = false;
        });
      }
    } catch (e) {
      log('getUser [ ERROR ] $e');
      if (mounted) {
      setState(() {
        loading = false;
      });
      }
    }
  }

  Future editProfile() async {
    setState(() {
      loadingEdit = true;
    });
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    try {
      // Check if user is company personnel (roles: 18, 20, 21, 22, 26)
      final roleId = appProvider.userModel?.customer.roleId;
      final roleIdInt = roleId is int ? roleId : (roleId is String ? int.tryParse(roleId.toString()) : null);
      final bool isCompany = roleIdInt != null && (roleIdInt == 18 || roleIdInt == 20 || roleIdInt == 21 || roleIdInt == 22 || roleIdInt == 26);
      
      // Use backend-mms for profile update only if user is company personnel
      ProfileModel? updatedProfile;
      if (isCompany) {
        updatedProfile = await ProfileApis.updateProfileMMS(
          email: email.text,
          firstName: firstName.text,
          lastName: lastName.text,
          token: appProvider.accessToken ?? appProvider.userModel?.token ?? '',
          imageFile: imageFile, // Send file directly if selected
          existingImageUrl: imageFile == null ? imageProfile : null, // Use existing URL if no new file
        );
      } else {
        // Use old backend-oms endpoint for regular users
      await ProfileApis.editProfile(
        email: email.text,
        firstName: firstName.text,
          image: imageFile == null ? (imageProfile ?? "") : "",
        lastName: lastName.text,
        token: appProvider.userModel?.token ?? '',
        );
        // For old endpoint, we need to reload profile data
        updatedProfile = await ProfileApis.getProfileData(
          token: appProvider.userModel?.token ?? '',
          isCompany: false,
        );
      }
      
      if (updatedProfile != null) {
        // Update local state with new profile data immediately
        setState(() {
          profileModel = updatedProfile;
          imageProfile = updatedProfile?.profile?.profileImage ?? imageProfile;
          imageFile = null; // Clear file after successful upload
          // Update form fields
          firstName.text = updatedProfile?.profile?.firstname ?? firstName.text;
          lastName.text = updatedProfile?.profile?.lastname ?? lastName.text;
          email.text = updatedProfile?.profile?.email ?? email.text;
        });
        
        // Refresh profile data from server to ensure consistency
        await getUser();
        
        if (mounted) {
        showDialog(
          context: context,
            builder: (context) => WidgetDialog(
              title: AppLocalizations.of(context)!.successfully,
              desc: AppLocalizations.of(context)!.yourinformationhasbeenupdatedsuccessfully,
            isError: false,
          ),
        );
        }
      } else {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => WidgetDialog(
              title: AppLocalizations.of(context)!.errorTitle,
              desc: AppLocalizations.of(context)!.failedToUpdateProfile,
              isError: true,
            ),
          );
        }
      }
      
        setState(() {
          loadingEdit = false;
      });
    } catch (e) {
      log('editProfile() error = > $e');
      setState(() {
        loadingEdit = false;
      });
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => WidgetDialog(
            title: AppLocalizations.of(context)!.errorTitle,
            desc: AppLocalizations.of(context)!.errorOccurredWhileUpdatingProfile,
            isError: true,
          ),
        );
      }
    }
  }

  Future uploadFile({bool? isCavar = false}) async {
    // Image will be uploaded directly when saving profile
    // No need to upload separately anymore
        setState(() {
      // Just update the preview, actual upload happens in editProfile()
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
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.selectaPictureFromGallery,
                            textAlign: TextAlign.start,
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
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.takeaPictureFromCamera,
                            textAlign: TextAlign.start,
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
