import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Data/model/contacts_model.dart';
import 'package:wefix/Presentation/Components/language_icon.dart';
import 'package:wefix/Presentation/Profile/Screens/Chat/messages_screen.dart';

class ListUser extends StatefulWidget {
  const ListUser({super.key});

  @override
  State<ListUser> createState() => _ListUserState();
}

class _ListUserState extends State<ListUser> {
  bool? loading = false;
  ContactsModel? contactsModel;

  @override
  void initState() {
    // getContactsList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: const [
            LanguageButton(),
          ],
          title: Text(AppText(context).massages),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  ListView.separated(
                    separatorBuilder: (context, index) => const Divider(
                      color: AppColors.greyColor1,
                      height: 1,
                    ),
                    itemCount: 5,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //       builder: (context) => CommentsScreenById(
                          //         chatId: "1",
                          //         image:
                          //             "https://t3.ftcdn.net/jpg/10/18/35/56/360_F_1018355691_3GfF6Dk0iXqHcACgcgr0ptLKP7Zat8Qv.jpg",
                          //         name: "Abdallah abuasab",
                          //         contactId: "32",
                          //         index: index,
                          //         reqId: 1,
                          //       ),
                          //     ));
                        },
                        trailing: const Icon(Icons.arrow_forward_ios_rounded),
                        title: Text(
                          "Abdallah abuasab",
                          style:
                              TextStyle(fontSize: AppSize(context).smallText1),
                        ),
                        // ignore: prefer_const_constructors
                        subtitle: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Hello world",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.greyColorFont,
                                  fontWeight: FontWeight.normal),
                            ),
                            Text(
                              "",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.greyColor1),
                          ),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl:
                                  "https://t3.ftcdn.net/jpg/10/18/35/56/360_F_1018355691_3GfF6Dk0iXqHcACgcgr0ptLKP7Zat8Qv.jpg",
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  // Future getContactsList() async {
  //   if (mounted) {
  //     setState(() {
  //       loading = true;
  //     });
  //   }
  //   AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
  //   await ShopApis.getContactsChat(
  //     token: appProvider.userModel?.token ?? '',
  //   ).then((value) {
  //     if (value != null) {
  //       if (mounted) {
  //         setState(() {
  //           contactsModel = value;
  //         });
  //       }

  //       if (mounted) {
  //         setState(() {
  //           loading = false;
  //         });
  //       }
  //     } else {
  //       if (mounted) {
  //         setState(() {
  //           loading = false;
  //         });
  //       }
  //     }
  //   });
  // }
}
