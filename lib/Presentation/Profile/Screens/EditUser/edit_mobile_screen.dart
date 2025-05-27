import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/orders/profile_api.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Components/language_icon.dart';
import 'package:wefix/Presentation/Components/widget_dialog.dart';
import 'package:wefix/Presentation/Components/widget_phone_form_fields.dart';

class EditMobileScreen extends StatefulWidget {
  const EditMobileScreen({super.key});

  @override
  State<EditMobileScreen> createState() => _EditMobileScreenState();
}

class _EditMobileScreenState extends State<EditMobileScreen> {
  final key = GlobalKey<FormState>();
  TextEditingController phone = TextEditingController();
  bool loading = false;

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
        backgroundColor: AppColors(context).primaryColor,
        title: Text(
          "Edit Mobile",
          style: TextStyle(
            fontSize: AppSize(context).mediumText3,
            color: AppColors.whiteColor1,
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
              const SizedBox(height: 20),
              Text(
                "Mobile",
                style: TextStyle(
                  fontSize: AppSize(context).mediumText3,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              WidgetPhoneField(
                onCountryChanged: (value) {
                  setState(() {
                    phone.text = value.phoneNumber ?? '';
                  });
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: CustomBotton(
          title: 'Edit',
          loading: loading,
          onTap: () async {
            if (key.currentState!.validate()) {
              editPhone();
            }
          },
        ),
      ),
    );
  }

  Future editPhone() async {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    setState(() {
      loading = true;
    });
    await ProfileApis.editPhone(
      token: appProvider.userModel?.token ?? '',
      phone: phone.text,
    ).then((value) {
      setState(() {
        loading = false;
      });
      if (value is String) {
        showDialog(
          context: context,
          builder: (context) {
            return WidgetDialog(
              title: 'Warning',
              desc: value,
              isError: true,
            );
          },
        );
      } else {
        if (value == true) {
          showDialog(
            context: context,
            builder: (context) {
              return WidgetDialog(
                title: 'Successfully',
                desc: 'Mobile Number Edited Successfully',
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
              return const WidgetDialog(
                title: 'Warning',
                desc: 'Failed to Update Mobile Number',
                isError: true,
              );
            },
          );
        }
      }
    });
  }
}
