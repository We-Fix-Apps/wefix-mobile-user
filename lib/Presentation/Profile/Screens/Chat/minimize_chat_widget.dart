import 'dart:io';

import 'package:flutter/material.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Presentation/Components/custom_cach_network_image.dart';

class ChatOverlay extends StatefulWidget {
  const ChatOverlay({super.key});

  @override
  State<ChatOverlay> createState() => _ChatOverlayState();
}

class _ChatOverlayState extends State<ChatOverlay> {
  bool _isChatOpen = false;
  Offset _offset = const Offset(100, 100);
  final _formKey = GlobalKey<FormState>();
  TextEditingController commentController = TextEditingController();

  bool? loadingMessage;
  bool? someUpdate;
  String? image;
  File? imageFile;
  final serverURL = 'https://api.wefixjo.com/ChatHub';
  HubConnection? hubConnection;
  List messagesList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Chat Window
          if (_isChatOpen)
            Positioned(
              left: _offset.dx,
              top: _offset.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _offset += details.delta;
                  });
                },
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 300,
                    height: 400,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text('Chat'),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.minimize),
                              onPressed: () {
                                setState(() {
                                  _isChatOpen = false;
                                });
                              },
                            ),
                          ],
                        ),
                        Expanded(
                            child: Column(
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
                                            borderRadius:
                                                BorderRadius.circular(1000),
                                            child: Image.asset(
                                                "assets/image/icon_logo.png",
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover)),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        const Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "",
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
                                              color: AppColors(context)
                                                  .primaryColor,
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: ListView.separated(
                                                  separatorBuilder:
                                                      (context, index) =>
                                                          const SizedBox(
                                                    height: 10,
                                                  ),
                                                  shrinkWrap: true,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  itemCount:
                                                      messagesList.length ?? 0,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Row(
                                                      mainAxisAlignment: messagesList[
                                                                      index][
                                                                  "toUserId"] ==
                                                              1
                                                          ? MainAxisAlignment
                                                              .end
                                                          : MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        messagesList[index][
                                                                    "message"] ==
                                                                ""
                                                            ? ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                child: WidgetCachNetworkImage(
                                                                    width: AppSize(context)
                                                                            .width *
                                                                        .5,
                                                                    height:
                                                                        AppSize(context).width *
                                                                            .5,
                                                                    image: messagesList[index]
                                                                            [
                                                                            "image"] ??
                                                                        ""),
                                                              )
                                                            : Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment: messagesList[index]
                                                                            [
                                                                            "toUserId"] ==
                                                                        1
                                                                    ? CrossAxisAlignment
                                                                        .end
                                                                    : CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            4.0),
                                                                    child:
                                                                        Container(
                                                                      width: (messagesList[index]["message"].toString().length) >
                                                                              30
                                                                          ? AppSize(context).width *
                                                                              .65
                                                                          : null,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: messagesList[index]["toUserId"] ==
                                                                                1
                                                                            ? AppColors.lightGreyColor
                                                                            : AppColors(context).primaryColor,
                                                                        borderRadius:
                                                                            BorderRadius.circular(20),
                                                                      ),
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                        child:
                                                                            Text(
                                                                          messagesList[index]["message"] ??
                                                                              "",
                                                                          textAlign:
                                                                              TextAlign.right,
                                                                          maxLines:
                                                                              20,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style:
                                                                              TextStyle(
                                                                            color: messagesList[index]["toUserId"] == 1
                                                                                ? AppColors.blackColor1
                                                                                : AppColors.whiteColor1,
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
                        )),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Floating bubble
          if (!_isChatOpen)
            Positioned(
              left: _offset.dx,
              top: _offset.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _offset += details.delta;
                  });
                },
                child: FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      _isChatOpen = true;
                    });
                  },
                  child: const Icon(Icons.chat),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
