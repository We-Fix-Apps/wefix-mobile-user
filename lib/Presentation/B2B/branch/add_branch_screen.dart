import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/B2b/b2b_api.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Presentation/Components/custom_botton_widget.dart';
import 'package:wefix/Presentation/Components/widget_form_text.dart';

class AddBranchScreen extends StatefulWidget {
  const AddBranchScreen({super.key});

  @override
  State<AddBranchScreen> createState() => _AddBranchScreenState();
}

class _AddBranchScreenState extends State<AddBranchScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController branchName = TextEditingController();
  final TextEditingController branchNameAr = TextEditingController();

  final TextEditingController email = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController address = TextEditingController();

  bool isLoading = false;

  File? _imageFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Handle submit logic here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Branch"),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ---------------- TextFields ----------------
              WidgetTextField(
                "branchName",
                keyboardType: TextInputType.name,
                fillColor: AppColors.greyColorback,
                haveBorder: false,
                controller: branchName,
                validator: (p0) {
                  if (branchName.text.isEmpty) {
                    return AppText(context, isFunction: true).required;
                  }
                  return null;
                },
                radius: 5,
              ),
              const SizedBox(height: 15),

              WidgetTextField(
                "branchName Ar",
                keyboardType: TextInputType.name,
                fillColor: AppColors.greyColorback,
                haveBorder: false,
                controller: branchNameAr,
                validator: (p0) {
                  if (branchNameAr.text.isEmpty) {
                    return AppText(context, isFunction: true).required;
                  }
                  return null;
                },
                radius: 5,
              ),
              const SizedBox(height: 15),

              WidgetTextField(
                AppText(context, isFunction: true).email,
                fillColor: AppColors.greyColorback,
                haveBorder: false,
                keyboardType: TextInputType.emailAddress,
                controller: email,
                validator: (p0) {
                  if (email.text.isEmpty) {
                    return AppText(context, isFunction: true).required;
                  }
                  return null;
                },
                radius: 5,
              ),
              const SizedBox(height: 15),

              WidgetTextField(
                AppText(context, isFunction: true).phone,
                fillColor: AppColors.greyColorback,
                haveBorder: false,
                keyboardType: TextInputType.phone,
                controller: phone,
                validator: (p0) {
                  if (phone.text.isEmpty) {
                    return AppText(context, isFunction: true).required;
                  }
                  return null;
                },
                radius: 5,
              ),
              const SizedBox(height: 15),

              WidgetTextField(
                AppText(context, isFunction: true).city,
                fillColor: AppColors.greyColorback,
                haveBorder: false,
                controller: city,
                validator: (p0) {
                  if (city.text.isEmpty) {
                    return AppText(context, isFunction: true).required;
                  }
                  return null;
                },
                radius: 5,
              ),
              const SizedBox(height: 15),

              WidgetTextField(
                AppText(context, isFunction: true).address,
                fillColor: AppColors.greyColorback,
                haveBorder: false,
                controller: address,
                validator: (p0) {
                  if (address.text.isEmpty) {
                    return AppText(context, isFunction: true).required;
                  }
                  return null;
                },
                radius: 5,
              ),
              const SizedBox(height: 30),

              // ---------------- Submit Button ----------------
              CustomBotton(
                  title: "Add Branch",
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      createBranch().then((v) {
                        Navigator.pop(context, true);
                      });
                    }
                  },
                  loading: isLoading),
            ],
          ),
        ),
      ),
    );
  }

  Future createBranch() async {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    setState(() => isLoading = true);
    await B2bApi.createBranch(
      context: context,
      token: appProvider.userModel?.token ?? '',
      // customerId: 0,
      name: branchName.text,
      nameAr: branchNameAr.text,
      phone: phone.text,
      city: city.text,
      address: address.text,
      latitude: "",
      longitude: "",
    ).then((value) async {
      setState(() => isLoading = false);
      if (value ?? false) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors(context).primaryColor,
            content: const Text("Branch added successfully ✅"),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors(context).primaryColor,
            content: const Text("Failed to add branch. Please try again"),
          ),
        );
      }
    });
  }
}
