import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wefix/Business/Authantication/auth_apis.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/Functions/validations.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Components/language_icon.dart';
import 'package:wefix/Presentation/Components/widget_dialog.dart';
import 'package:wefix/Presentation/Components/widget_form_text.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  bool loading = false;
  final key = GlobalKey<FormState>();
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          LanguageButton(),
        ],
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors(context).primaryColor,
          statusBarIconBrightness: Brightness.light,
        ),
        backgroundColor: AppColors.whiteColor1,
        title: Text(
          "",
          style: TextStyle(
            fontSize: AppSize(context).mediumText3,
            color: AppColors(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSize(context).appPadding,
        child: Form(
          key: key,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.04),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.24,
                width: double.infinity,
                child: SvgPicture.asset(
                  'assets/icon/forget.svg',
                  height: 200,
                ),
              ),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.04),
              Center(
                child: Text(
                  AppText(context).forgetPassword,
                  style: TextStyle(
                    fontSize: AppSize(context).mediumText3,
                    color: AppColors(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Divider(
                  color: AppColors.greyColor1.withOpacity(0.5),
                ),
              ),

              // * Email Or Phone
              Text(
                "${AppText(context, isFunction: true).email}",
                style: TextStyle(
                  color: AppColors.greyColor3,
                  fontSize: AppSize(context).smallText3,
                ),
              ),
              SizedBox(height: AppSize(context).height * 0.02),
              WidgetTextField(
                "${AppText(context, isFunction: true).email}",
                controller: controller,
                keyboardType: TextInputType.emailAddress,
                validator: (p0) => Validations.checkNull(
                    p0, AppText(context, isFunction: true).required),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(20),
        child: CustomBotton(
          title: AppText(context).send,
          loading: loading,
          onTap: () async {
            if (key.currentState!.validate()) {
              await forgetpassword();
            }
          },
        ),
      ),
    );
  }

  Future forgetpassword() async {
    setState(() {
      loading = true;
    });
    await Authantication.updatePassword(userName: controller.text)
        .then((value) {
      setState(() {
        loading = false;
      });
      if (value == true) {
        showDialog(
          context: context,
          builder: (context) {
            return WidgetDialog(
              title: AppText(context, isFunction: true).successfully,
              desc: AppText(context, isFunction: true)
                  .yourrequesthasbeensentPleasecheckyouremail,
              isError: false,
              onTap: () {
                pop(context);
                pop(context);
              },
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return WidgetDialog(
              title: AppText(context, isFunction: true).warning,
              desc: AppText(context, isFunction: true).failedtoSendYourrequest,
              isError: true,
            );
          },
        );
      }
    });
  }
}
