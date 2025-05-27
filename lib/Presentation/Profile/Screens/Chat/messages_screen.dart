import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/Shop/shop_api.dart';
import 'package:wefix/Business/uplade_image.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/image_picker_class.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Data/model/messges_model.dart';
import 'package:wefix/Presentation/Components/custom_cach_network_image.dart';
import 'package:wefix/Presentation/Components/language_icon.dart';
import 'package:wefix/Presentation/Components/widget_form_text.dart';

class CommentsScreenById extends StatefulWidget {
  final int? index;
  final int? reqId;
  final String chatId;
  final String? contactId;
  final String? image;
  final String? name;

  const CommentsScreenById({
    super.key,
    this.index,
    this.reqId,
    required this.chatId,
    this.contactId,
    this.image,
    this.name,
  });

  @override
  State<CommentsScreenById> createState() => _CommentsScreenByIdState();
}

class _CommentsScreenByIdState extends State<CommentsScreenById> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController commentController = TextEditingController();
  MassegesModel? massegesModel;
  bool? loadingMessage;
  bool? someUpdate;
  String? image;
  File? imageFile;

  @override
  void initState() {
    getMessagesList().then((value) {
      log(massegesModel?.messgelist?.last.image.toString() ?? "");
    });

    log(widget.image.toString());

    updateMessage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            LanguageButton(),
          ],
          title: Text(
            AppText(context).massages,
            style: TextStyle(),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        bottomNavigationBar: Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * .85,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                    key: _formKey,
                    child: WidgetTextField(
                      "${AppText(context).enterText}",
                      prefixIcon: IconButton(
                          onPressed: () {
                            showBottom().then((value) {});
                          },
                          icon: const Icon(
                            Icons.attach_file,
                            color: AppColors.greyColor1,
                          )),
                      validator: (v) {
                        if (commentController.text.isEmpty) {
                          return AppText(context , isFunction: true).thisfeildcanbeempty;
                        } else {
                          return null;
                        }
                      },
                      fillColor: AppColors.whiteColor3,
                      controller: commentController,
                    ),
                  ),
                ),
              ),
              IconButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      sendMEssages().then((value) {
                        getMessagesList();
                        commentController.clear();
                      });
                    }
                  },
                  icon: Icon(
                    Icons.send,
                    color: AppColors(context).primaryColor,
                  )),
            ],
          ),
        ),
        body: SingleChildScrollView(
          reverse: true,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(1000),
                        child: Image.asset("assets/image/icon_logo.png",
                            width: 50, height: 50, fit: BoxFit.cover)),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name ?? "",
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                const Divider(
                  height: 2,
                  color: AppColors.greyColor1,
                ),
                const SizedBox(
                  height: 15,
                ),
                loadingMessage == true
                    ? Center(
                        child: CircularProgressIndicator(
                          color: AppColors(context).primaryColor,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ListView.separated(
                              separatorBuilder: (context, index) =>
                                  const SizedBox(
                                height: 10,
                              ),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: massegesModel?.messgelist?.length ?? 0,
                              itemBuilder: (context, index) {
                                return Row(
                                  mainAxisAlignment:
                                      massegesModel?.messgelist![index].type ==
                                              "receiver"
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                  children: [
                                    massegesModel?.messgelist![index].message ==
                                            ""
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: WidgetCachNetworkImage(
                                                width:
                                                    AppSize(context).width * .5,
                                                height:
                                                    AppSize(context).width * .5,
                                                image: massegesModel
                                                        ?.messgelist![index]
                                                        .image ??
                                                    ""),
                                          )
                                        : Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment: massegesModel
                                                        ?.messgelist![index]
                                                        .type ==
                                                    "receiver"
                                                ? CrossAxisAlignment.end
                                                : CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Container(
                                                  width: (massegesModel
                                                              ?.messgelist![
                                                                  index]
                                                              .message!
                                                              .length)! >
                                                          30
                                                      ? AppSize(context).width *
                                                          .65
                                                      : null,
                                                  decoration: BoxDecoration(
                                                    color: massegesModel
                                                                ?.messgelist![
                                                                    index]
                                                                .type ==
                                                            "receiver"
                                                        ? AppColors
                                                            .lightGreyColor
                                                        : AppColors(context)
                                                            .primaryColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      massegesModel
                                                              ?.messgelist![
                                                                  index]
                                                              .message ??
                                                          "",
                                                      textAlign:
                                                          TextAlign.right,
                                                      maxLines: 20,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color: massegesModel
                                                                    ?.messgelist![
                                                                        index]
                                                                    .type ==
                                                                "receiver"
                                                            ? AppColors
                                                                .blackColor1
                                                            : AppColors
                                                                .whiteColor1,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // DateFormat()
                                              Text(
                                                massegesModel
                                                        ?.messgelist![index]
                                                        .insertdate ??
                                                    "",
                                                style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 10),
                                              )
                                            ],
                                          ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ));
  }

  Future getMessagesList() async {
    setState(() {
      loadingMessage = true;
    });
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    try {
      await ShopApis.getMessagesList(
        chatId: widget.chatId,
        token: appProvider.userModel?.token ?? '',
      ).then((value) {
        setState(() {
          massegesModel = value;
        });
        setState(() {
          loadingMessage = false;
        });

        log(massegesModel?.messgelist![0].message.toString() ?? "");
      });
    } catch (e) {
      setState(() {
        loadingMessage = false;
      });
      log('Login Is Error');
    }
  }

  Future sendMEssages() async {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    try {
      await ShopApis.sendMessages(
        chatId: widget.chatId,
        attachment: image ?? "",
        message: commentController.text,
        attachmentName: "",
        token: appProvider.userModel?.token ?? '',
      ).then((value) {
        setState(() {
          massegesModel = value;
        });

        log(massegesModel?.messgelist![0].message.toString() ?? "");
      });
    } catch (e) {
      log('Login Is Error');
    }
  }

  Future updateMessage() async {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    await ShopApis.updateMessages(
      token: appProvider.userModel?.token ?? '',
      chatId: widget.contactId,
    );
  }

  Future showBottom({bool isCover = false}) async {
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
                          await uploadFile(isCavar: isCover).then((value) {
                            sendMEssages().then((value) {
                              getMessagesList();
                            });
                          });
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
                          await uploadFile(isCavar: isCover).then((value) {
                            sendMEssages().then((value) {
                              getMessagesList();
                            });
                          });
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

  Future uploadFile({bool? isCavar = false}) async {
    AppProvider appProvider = Provider.of(context, listen: false);

    await UpladeImages.upladeImage(
      token: '${appProvider.userModel?.token}',
      file: imageFile!,
    ).then((value) {
      if (value != null) {
        setState(() {
          image = value;
        });
      }
    });
  }
}
