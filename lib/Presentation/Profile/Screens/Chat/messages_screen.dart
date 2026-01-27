import 'dart:developer';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/Chat/chat_apis.dart';
import 'package:wefix/Business/uplade_image.dart';
import 'package:wefix/Business/upload_files_list.dart';

import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:wefix/Data/Functions/image_picker_class.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Data/model/messges_model.dart';
import 'package:wefix/Presentation/Components/custom_cach_network_image.dart';
import 'package:wefix/Presentation/Components/language_icon.dart';
import 'package:wefix/Presentation/Components/widget_form_text.dart';
import 'package:wefix/Presentation/Profile/Screens/proparity_screen.dart';

class CommentsScreenById extends StatefulWidget {
  final String? image;
  final String? name;
  final int? ticketId;
  final int? toUserId;

  const CommentsScreenById({
    super.key,
    this.toUserId,
    this.ticketId,
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
  final serverURL = 'https://api.wefixjo.com/ChatHub';
  // final serverURL = 'https://apitestwefix.oneit.website/ChatHub';

  HubConnection? hubConnection;
  List messagesList = [];
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    setupSignalR();
    getMessgaes();

    log(widget.image.toString());
    // updateMessage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: const [
            LanguageButton(),
          ],
          title: Text(
            AppText(context).massages,
            style: const TextStyle(),
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
                      AppText(context).enterText,
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
                          return AppText(context, isFunction: true)
                              .thisfeildcanbeempty;
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
                      sendMEssages("").then((value) {
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
        body: loadingMessage == true
            ? LinearProgressIndicator(
                color: AppColors(context).primaryColor,
                backgroundColor: AppColors.backgroundColor,
              )
            : Stack(
                children: [
                  SingleChildScrollView(
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
                                  child: Image.asset(
                                      "assets/image/icon_logo.png",
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover)),
                              const SizedBox(
                                width: 10,
                              ),
                              const Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "WeFix Support",
                                    style: TextStyle(fontSize: 20),
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
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: messagesList.length ?? 0,
                                        itemBuilder: (context, index) {
                                          return Row(
                                            mainAxisAlignment:
                                                messagesList[index]
                                                            ["toUserId"] ==
                                                        widget.toUserId
                                                    ? MainAxisAlignment.end
                                                    : MainAxisAlignment.start,
                                            children: [
                                              messagesList[index]["message"] ==
                                                      ""
                                                  ? Container(
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: AppColors
                                                              .greyColor1,
                                                          width: 1,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        child: WidgetCachNetworkImage(
                                                            boxFit:
                                                                BoxFit.contain,
                                                            width:
                                                                AppSize(context)
                                                                        .width *
                                                                    .5,
                                                            height:
                                                                AppSize(context)
                                                                        .width *
                                                                    .5,
                                                            image: messagesList[
                                                                        index]
                                                                    ["image"] ??
                                                                ""),
                                                      ),
                                                    )
                                                  : Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment: messagesList[
                                                                      index][
                                                                  "toUserId"] ==
                                                              widget.toUserId
                                                          ? CrossAxisAlignment
                                                              .end
                                                          : CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4.0),
                                                          child: Container(
                                                            width: (messagesList[index]
                                                                            [
                                                                            "message"]
                                                                        .toString()
                                                                        .length) >
                                                                    30
                                                                ? AppSize(context)
                                                                        .width *
                                                                    .65
                                                                : null,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: messagesList[
                                                                              index]
                                                                          [
                                                                          "toUserId"] ==
                                                                      widget
                                                                          .toUserId
                                                                  ? AppColors
                                                                      .lightGreyColor
                                                                  : AppColors(
                                                                          context)
                                                                      .primaryColor,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                messagesList[
                                                                            index]
                                                                        [
                                                                        "message"] ??
                                                                    "",
                                                                maxLines: 20,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    TextStyle(
                                                                  color: messagesList[index]
                                                                              [
                                                                              "toUserId"] ==
                                                                          widget
                                                                              .toUserId
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
                                                        // Text(
                                                        //   massegesModel
                                                        //           ?.messgelist![index]
                                                        //           .insertdate ??
                                                        //       "",
                                                        //   style: const TextStyle(
                                                        //       color: Colors.grey,
                                                        //       fontSize: 10),
                                                        // )
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
                  ),
                ],
              ));
  }

  void setupSignalR() async {
    hubConnection = HubConnectionBuilder().withUrl(serverURL).build();
    hubConnection!.onclose(({error}) => log('Close Connection'));
    hubConnection?.on("ReceiveMessage", _handelNewPrice);

    await hubConnection?.start();
    log("SignalR connection established.");
    await joinTicket();
  }

  _handelNewPrice(arguments) async {
    setState(() {
      messagesList.add(arguments![0]);
    });
    await _audioPlayer
        .play(AssetSource('video/mixkit-correct-answer-tone-2870.wav'));

    log(messagesList.toString());
  }

  Future sendMEssages(chatImage) async {
    AppProvider appProvider = Provider.of(context, listen: false);

    await ChatApis.sendMessages(
      toUserId: 0,
      ticketId: widget.ticketId ?? 0,
      message: commentController.text,
      image: chatImage ?? "",
      context: context,
      token: appProvider.userModel?.token,
    ).then((value) {
      if (value != null) {
        log('Message sent successfully');
        commentController.clear();
        setState(() {
          someUpdate = true;
        });
      } else {
        log('Failed to send message');
      }
    });

    // if (hubConnection?.state == HubConnectionState.Connected) {
    //   await hubConnection?.invoke('SendMessageToTicket', args: [
    //     widget.ticketId ?? 0,
    //     1,
    //     commentController.text,
    //     chatImage ?? "",
    //   ]);
    // }
  }

  Future getMessgaes() async {
    AppProvider appProvider = Provider.of(context, listen: false);
    setState(() {
      loadingMessage = true;
    });

    await ChatApis.getMessages(
      id: widget.ticketId.toString(),
      token: appProvider.userModel?.token,
    ).then((value) {
      if (value != null && value is List) {
        setState(() {
          messagesList.addAll(value);
          loadingMessage = false;
        });
        log("Fetched ${value.length} messages.");
      } else {
        log('Failed to fetch messages or invalid data');
      }
    }).catchError((error) {
      setState(() {
        loadingMessage = false;
      });
      log("Error in getMessgaes: $error");
    });
  }

  Future<void> joinTicket() async {
    await hubConnection?.invoke('JoinTicket', args: [widget.ticketId ?? 0, 3]);
    print('📌 Joined Ticket Group: ${widget.ticketId}');
  }

  void onMessage(Function(dynamic message) callback) {
    hubConnection?.on('ReceiveMessage', (args) {
      callback(args?.first);
    });
  }

  Future<void> disconnect() async {
    await hubConnection?.stop();
    print('🔌 Disconnected');
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
                          await uploadFile(isCavar: isCover)
                              .whenComplete(() {});
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
                          await uploadFile(isCavar: isCover)
                              .whenComplete(() {});
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

    await UpladeFiles.upladeImagesWithPaths(
      token: '${appProvider.userModel?.token}',
      filePaths: [imageFile!.path.toString()],
    ).then((value) {
      if (value != null) {
        sendMEssages(value[0]);
        setState(() {
          image = value[0];
        });
      }
    });
  }
}
