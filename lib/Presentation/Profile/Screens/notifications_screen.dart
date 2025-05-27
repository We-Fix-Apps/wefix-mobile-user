import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/Notification/notification_apis.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Data/model/notofications_model.dart' as wefix;

import 'package:wefix/Presentation/Components/language_icon.dart';
import 'package:wefix/Presentation/Profile/Screens/booking_details_screen.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool? loading = false;
  List<wefix.Notification?> notifications = [];

  @override
  void initState() {
    getNotifications();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppText(context).notifications),
        actions: [
          LanguageButton(),
        ],
        centerTitle: true,
      ),
      body: loading == true
          ? LinearProgressIndicator(
              color: AppColors(context).primaryColor,
              backgroundColor: AppColors.secoundryColor,
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                  child: ListTile(
                    shape: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: AppColors.backgroundColor)),
                    tileColor: AppColors.backgroundColor,
                    leading: SvgPicture.asset("assets/icon/notification.svg"),
                    title: Text(
                      notification?.title ?? "",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppSize(context).smallText2,
                      ),
                    ),
                    // subtitle: Text(
                    //   notification?.description ?? "",
                    //   style: TextStyle(
                    //     color: AppColors.greyColor2,
                    //     fontSize: AppSize(context).smallText3,
                    //   ),
                    // ),
                    trailing: Text(
                      "${DateFormat('yyyy-MM-dd').format(DateTime.parse(notification?.createdDate.toString() ?? ''))}",
                      style: TextStyle(
                          fontSize: AppSize(context).smallText3,
                          color: AppColors.greyColor2),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          rightToLeft(TicketDetailsScreen(
                              id: notification?.ticketId.toString() ?? "0")));
                    },
                  ),
                );
              },
            ),
    );
  }

  Future getNotifications() async {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    setState(() {
      loading = true;
    });
    NoyificationApis.getNotification(token: appProvider.userModel?.token ?? '')
        .then((value) {
      if (value.isNotEmpty) {
        setState(() {
          notifications = value;
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
      }
    });
  }
}
