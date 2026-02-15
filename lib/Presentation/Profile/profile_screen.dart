import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/LanguageProvider/l10n_provider.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/Helper/cache_helper.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Presentation/Components/language_icon.dart';
import 'package:wefix/Presentation/Components/widget_dialog.dart';
import 'package:wefix/Presentation/Profile/Components/web_view_screen.dart';
import 'package:wefix/Presentation/Profile/Screens/bookings_screen.dart';
import 'package:wefix/Presentation/Profile/Screens/contract_details_screen.dart';
import 'package:wefix/Presentation/Profile/Screens/proparity_screen.dart';
import 'package:wefix/Presentation/auth/login_screen.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Presentation/Profile/Components/widget_card.dart';
import 'package:wefix/Presentation/Profile/Screens/content_screen.dart';
import 'package:wefix/Presentation/Profile/Screens/profile_info_screen.dart';
import 'package:wefix/Presentation/Profile/Screens/EditUser/edit_mobile_screen.dart';
import 'package:wefix/Presentation/Profile/Screens/EditUser/change_password_screen.dart';
import 'package:wefix/Presentation/wallet/screens/wallet_screen.dart';
import 'package:wefix/l10n/app_localizations.dart';
import 'package:wefix/Business/orders/profile_api.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    LanguageProvider languageProvider = Provider.of<LanguageProvider>(context, listen: false);

    // B2B users: Admin 18, Team Leader 20, Technician 21, etc., Super User 26
    final roleId = appProvider.userModel?.customer.roleId;
    final roleIdInt = roleId is int ? roleId : (roleId is String ? int.tryParse(roleId.toString()) : null);
    final bool isB2B = roleIdInt != null && (roleIdInt == 18 || roleIdInt == 20 || roleIdInt == 21 || roleIdInt == 22 || roleIdInt == 26);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppText(context).menu),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: const [
          LanguageButton(),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              if (appProvider.userModel?.token != null) ...[
                if (!isB2B) ...[
                  WidgetCard(title: AppText(context).wallet, onTap: () => Navigator.push(context, rightToLeft(const WalletScreen()))),
                  const SizedBox(height: 10),
                ],
                WidgetCard(title: AppText(context).history, onTap: () => Navigator.push(context, rightToLeft(const BookingScreen()))),
                const SizedBox(height: 10),
                WidgetCard(title: AppText(context).myProperty, onTap: () => Navigator.push(context, rightToLeft(const ApartmentScreen(status: "Active", statusColor: AppColors.greenColor)))),
                const SizedBox(height: 10),
                WidgetCard(title: AppText(context).contractDetails, onTap: () => Navigator.push(context, rightToLeft(const ContractScreen()))),
                const SizedBox(height: 10),
              ],
              WidgetCard(
                  title: AppText(context).privacyPolicy,
                  onTap: () => Navigator.push(
                      context,
                      rightToLeft(WebviewScreen(
                          url: languageProvider.lang == "ar" ? 'https://wefixjo.com/AboutUs/PrivacyPolicyArApp' : 'https://wefixjo.com/AboutUs/PrivacyPolicyApp',
                          title: AppText(context, isFunction: true).privacyPolicy)))),
              const SizedBox(height: 10),
              WidgetCard(
                title: AppText(context).termsAndConditions,
                onTap: () => Navigator.push(
                    context,
                    rightToLeft(WebviewScreen(
                        url: languageProvider.lang == "ar" ? 'https://wefixjo.com/AboutUs/TermAndConditionArApp' : 'https://wefixjo.com/AboutUs/TermAndConditionApp',
                        title: AppText(context, isFunction: true).termsAndConditions))),
              ),
              const SizedBox(height: 10),
              WidgetCard(title: AppText(context).aboutUs, onTap: () => Navigator.push(context, rightToLeft(const ContentScreen(isAbout: true)))),
              const SizedBox(height: 10),
              WidgetCard(
                  title: appProvider.userModel?.token == null ? AppText(context).login : AppText(context).logout,
                  onTap: () {
                    // Set logout flag in cache to prevent auto-navigation on app restart
                    CacheHelper.saveData(key: CacheHelper.isLoggedOut, value: true);
                    // Clear user data but preserve for biometric login
                    setState(() => appProvider.clearUser(preserveUserDataForBiometric: true));
                    appProvider.clearTokens();
                    // Navigate to login screen and remove all previous routes
                    Navigator.pushAndRemoveUntil(context, rightToLeft(const LoginScreen()), (route) => false);
                  }),
              if (appProvider.userModel?.token != null) ...[
                const SizedBox(height: 10),
                WidgetCard(
                    isDelete: true,
                    title: AppText(context).deletemyAccount,
                    onTap: () async {
                      // Show confirmation dialog first
                      final confirmResult = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(AppLocalizations.of(context)?.confirmDelete ?? 'Confirm Delete'),
                            content: Text(AppLocalizations.of(context)?.areYouSureDeleteAccount ?? 'Are you sure you want to delete your account? This action cannot be undone. All your data will be permanently deleted.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: Text(AppLocalizations.of(context)?.delete ?? 'Delete'),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmResult == true && mounted) {
                        // Show loading dialog
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        );

                        try {
                          final token = appProvider.accessToken ?? appProvider.userModel?.token ?? '';
                          
                          // Determine if user is B2B or B2C
                          final roleId = appProvider.userModel?.customer.roleId;
                          final roleIdInt = roleId is int ? roleId : (roleId is String ? int.tryParse(roleId.toString()) : null);
                          final bool isB2B = roleIdInt != null && (roleIdInt == 18 || roleIdInt == 20 || roleIdInt == 21 || roleIdInt == 22 || roleIdInt == 26);
                          
                          final result = await ProfileApis.deleteAccount(token: token, isB2B: isB2B);

                          if (mounted) {
                            Navigator.pop(context); // Close loading dialog

                            if (result == true) {
                              // Show success dialog
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return WidgetDialog(
                                    title: AppText(context, isFunction: true).successfully,
                                    desc: AppLocalizations.of(context)?.accountDeletedSuccessfully ?? 'Your account has been deleted successfully.',
                                    isError: false,
                                    onTap: () {
                                      // Set logout flag in cache
                                      CacheHelper.saveData(key: CacheHelper.isLoggedOut, value: true);
                                      // Clear user data but preserve for biometric login
                                      setState(() => appProvider.clearUser(preserveUserDataForBiometric: true));
                                      appProvider.clearTokens();
                                      // Navigate to login screen and remove all previous routes
                                      Navigator.pushAndRemoveUntil(context, downToTop(const LoginScreen()), (route) => false);
                                    },
                                  );
                                },
                              );
                            } else {
                              // Show error dialog
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return WidgetDialog(
                                    title: 'Error',
                                    desc: AppLocalizations.of(context)?.errorDeletingAccount ?? 'Failed to delete account. Please try again later.',
                                    isError: true,
                                    onTap: () => Navigator.pop(context),
                                  );
                                },
                              );
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            Navigator.pop(context); // Close loading dialog
                            showDialog(
                              context: context,
                              builder: (context) {
                                return WidgetDialog(
                                  title: 'Error',
                                  desc: AppLocalizations.of(context)?.errorDeletingAccount ?? 'An error occurred while deleting your account. Please try again later.',
                                  isError: true,
                                  onTap: () => Navigator.pop(context),
                                );
                              },
                            );
                          }
                        }
                      }
                    }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  showModalSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        // ignore: prefer_const_constructors
        return Padding(
          padding: EdgeInsets.only(left: 15, right: 15, top: 15, bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: AppSize(context).width * .15,
                  height: AppSize(context).height * .008,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppColors.greyColor),
                ),
              ),
              const SizedBox(height: 20),
              // * Edit Profile
              ListTile(
                leading: const Icon(Icons.person, color: AppColors.greyColor3),
                title: Text(
                  AppText(context).editProfile,
                  style: TextStyle(fontSize: AppSize(context).smallText2),
                ),
                onTap: () {
                  Navigator.push(context, rightToLeft(const MyProfileScreen()));
                },
              ),
              const Divider(height: 1, color: AppColors.greyColorback),
              // * Edit Mobile
              ListTile(
                  leading: const Icon(
                    Icons.phone,
                    color: AppColors.greyColor3,
                  ),
                  title: Text(
                    AppText(context).editmobile,
                    style: TextStyle(
                      fontSize: AppSize(context).smallText2,
                    ),
                  ),
                  onTap: () {
                    pop(context);
                    Navigator.push(context, rightToLeft(const EditMobileScreen()));
                  }),
              const Divider(height: 1, color: AppColors.greyColorback),
              // * Change Password
              ListTile(
                leading: const Icon(
                  Icons.lock,
                  color: AppColors.greyColor3,
                ),
                title: Text(
                  AppText(context).changepassword,
                  style: TextStyle(
                    fontSize: AppSize(context).smallText2,
                  ),
                ),
                onTap: () {
                  pop(context);
                  Navigator.push(context, rightToLeft(const ChangePasswordScreen()));
                },
              ),
              const Divider(height: 1, color: AppColors.greyColorback),
            ],
          ),
        );
      },
    );
  }
}
