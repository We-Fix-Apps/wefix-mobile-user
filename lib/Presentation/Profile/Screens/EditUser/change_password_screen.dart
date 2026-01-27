import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/orders/profile_api.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/validations.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Components/language_icon.dart';
import 'package:wefix/Presentation/Components/widget_dialog.dart';
import 'package:wefix/Presentation/Components/widget_form_text.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final key = GlobalKey<FormState>();
  TextEditingController current = TextEditingController();
  TextEditingController newPass = TextEditingController();
  TextEditingController confirm = TextEditingController();
  bool currentPassword = true;
  bool newPassword = true;
  bool confirmPassword = true;
  bool loading = false;
  bool isLoading = false;
  Map<String, dynamic>? updatePasswordList;

  @override
  void dispose() {
    confirm.dispose();
    current.dispose();
    newPass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: const [
           LanguageButton(),
        ],
        title: Text(
          "change password",
          style: TextStyle(
            fontSize: AppSize(context).mediumText3,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: AppSize(context).appPadding,
        child: Form(
          key: key,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // * Current Password

              Text(
                'Current Password',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: AppSize(context).smallText2,
                  color: AppColors(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              WidgetTextField(
                'Current Password',
                controller: current,
                prefixIcon: const Icon(Icons.lock_open),
                obscureText: currentPassword,
                suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        currentPassword = !currentPassword;
                      });
                    },
                    icon: Icon(currentPassword == true
                        ? Icons.visibility_off
                        : Icons.visibility)),
                validator: (v) => Validations.checkNull(
                  v,
                  AppText(context, isFunction: true).required,
                ),
              ),
              // * New Password
              Text(
                'New Password',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: AppSize(context).smallText2,
                  color: AppColors(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              WidgetTextField(
                'New Password',
                controller: newPass,
                prefixIcon: const Icon(Icons.lock_open),
                obscureText: newPassword,
                suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        newPassword = !newPassword;
                      });
                    },
                    icon: Icon(newPassword == true
                        ? Icons.visibility_off
                        : Icons.visibility)),
                validator: (value) {
                  if (value != '') {
                    if (Validations.isPasswordValid(value)) {
                      return null;
                    } else {
                      return 'Password must have symbols, numbers, and letters';
                    }
                  } else {
                    return AppText(context, isFunction: true).required;
                  }
                },
              ),
              // * Confirm Password
              Text(
                ' Confirm Password',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: AppSize(context).smallText2,
                  color: AppColors(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              WidgetTextField(
                'Confirm Password',
                controller: confirm,
                prefixIcon: const Icon(Icons.lock_open),
                obscureText: confirmPassword,
                suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        confirmPassword = !confirmPassword;
                      });
                    },
                    icon: Icon(confirmPassword == true
                        ? Icons.visibility_off
                        : Icons.visibility)),
                validator: (v) {
                  if (v == newPass.text) {
                    return null;
                  } else {
                    return 'The Password Is Different From The Previous One';
                  }
                },
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
          height: AppSize(context).height * 0.06,
          title: AppText(context).edit,
          loading: loading,
          onTap: () async {
            if (key.currentState!.validate()) {
              ChangedPassword();
            }
          },
        ),
      ),
    );
  }

  Future ChangedPassword() async {
    setState(() {
      loading = true;
    });
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    try {
      await ProfileApis.changePassword(
        oldPassword: current.text,
        newPassword: newPass.text,
        token: appProvider.userModel?.token ?? '',
      ).then((value) {
        showDialog(
          context: context,
          builder: (context) => const WidgetDialog(
            title: 'Successfully',
            desc: 'Your password has been updated successfully.',
            isError: false,
          ),
        );
        setState(() {
          loading = false;
        });
        log(value.toString());
      });
    } catch (e) {
      log('ChangedPassword() error = > $e');
      setState(() {
        loading = false;
      });
    }
  }
}
