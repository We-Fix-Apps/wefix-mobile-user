import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/Notification/notification_apis.dart';
import 'package:wefix/Data/Api/auth_helper.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';
import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/appText/appText.dart';
import 'package:wefix/Data/model/notofications_model.dart' as wefix;
import 'package:wefix/Data/Notification/notification_cache_service.dart';

import 'package:wefix/Presentation/Components/language_icon.dart';
import 'package:wefix/Presentation/Profile/Screens/booking_details_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool? loading = false;
  List<wefix.Notification?> apiNotifications = [];
  List<CachedNotification> cachedNotifications = [];

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload cached notifications when screen becomes visible
    setState(() {
      cachedNotifications = NotificationCacheService.getCachedNotifications();
    });
  }

  void loadNotifications() {
    // Load cached notifications
    setState(() {
      cachedNotifications = NotificationCacheService.getCachedNotifications();
      log('📱 NotificationScreen: Loaded ${cachedNotifications.length} cached notifications');
    });
    
    // Check if user is B2B (company personnel)
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final isB2B = AuthHelper.isCompanyPersonnel(appProvider);
    
    if (isB2B) {
      log('📱 NotificationScreen: B2B user detected - skipping API call, showing cached notifications only');
      setState(() {
        loading = false;
      });
    } else {
      // Only fetch API notifications for B2C users
      getNotifications();
    }
  }

  List<CachedNotification> get b2bNotifications {
    return NotificationCacheService.getB2BNotifications();
  }

  List<CachedNotification> get b2cNotifications {
    return NotificationCacheService.getB2CNotifications();
  }

  @override
  Widget build(BuildContext context) {
    // Check if user is B2B (company personnel)
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final isB2B = AuthHelper.isCompanyPersonnel(appProvider);
    
    // Reload cached notifications to get latest data
    final b2bNotifs = b2bNotifications;
    final b2cNotifs = b2cNotifications;
    final allCachedCount = b2bNotifs.length + b2cNotifs.length;
    final allNotificationsCount = allCachedCount + apiNotifications.length;
    
    log('📱 NotificationScreen build: isB2B=$isB2B, B2B=${b2bNotifs.length}, B2C=${b2cNotifs.length}, API=${apiNotifications.length}, Total=$allNotificationsCount');
    
    return Scaffold(
      appBar: AppBar(
        title: Text(AppText(context).notifications),
        actions: [
          if (cachedNotifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear All',
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear All Notifications'),
                    content: const Text('Are you sure you want to clear all cached notifications?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                );
                
                if (confirmed == true) {
                  await NotificationCacheService.clearAllNotifications();
                  setState(() {
                    cachedNotifications = [];
                  });
                }
              },
            ),
          const LanguageButton(),
        ],
        centerTitle: true,
      ),
      body: isB2B
          ? _buildB2BNotificationsView(context, b2bNotifs, b2cNotifs)
          : loading == true
              ? LinearProgressIndicator(
                  color: AppColors(context).primaryColor,
                  backgroundColor: AppColors.secoundryColor,
                )
              : allNotificationsCount == 0
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset("assets/icon/notification.svg", width: 64, height: 64, color: AppColors.greyColor2),
                          const SizedBox(height: 16),
                          Text(
                            'No notifications',
                            style: TextStyle(
                              fontSize: AppSize(context).smallText1,
                              color: AppColors.greyColor2,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                  children: [
                    // B2B Notifications Section
                    if (b2bNotifications.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          'B2B Notifications',
                          style: TextStyle(
                            fontSize: AppSize(context).smallText1,
                            fontWeight: FontWeight.bold,
                            color: AppColors(context).primaryColor,
                          ),
                        ),
                      ),
                      ...b2bNotifications.map((notification) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                            child: ListTile(
                              shape: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: AppColors.backgroundColor)),
                              tileColor: AppColors.backgroundColor,
                              leading: SvgPicture.asset("assets/icon/notification.svg"),
                              title: Text(
                                notification.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: AppSize(context).smallText2,
                                ),
                              ),
                              subtitle: notification.description.isNotEmpty
                                  ? Text(
                                      notification.description,
                                      style: TextStyle(
                                        color: AppColors.greyColor2,
                                        fontSize: AppSize(context).smallText3,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : null,
                              trailing: Text(
                                DateFormat('yyyy-MM-dd HH:mm').format(notification.createdDate),
                                style: TextStyle(
                                    fontSize: AppSize(context).smallText3,
                                    color: AppColors.greyColor2),
                              ),
                              onTap: () {
                                if (notification.ticketId != null && notification.ticketId!.isNotEmpty) {
                                  Navigator.push(
                                      context,
                                      rightToLeft(TicketDetailsScreen(
                                          id: notification.ticketId!)));
                                }
                              },
                            ),
                          )),
                      const SizedBox(height: 8),
                    ],
                    
                    // B2C Notifications Section
                    if (b2cNotifications.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          'B2C Notifications',
                          style: TextStyle(
                            fontSize: AppSize(context).smallText1,
                            fontWeight: FontWeight.bold,
                            color: AppColors(context).primaryColor,
                          ),
                        ),
                      ),
                      ...b2cNotifications.map((notification) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                            child: ListTile(
                              shape: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: AppColors.backgroundColor)),
                              tileColor: AppColors.backgroundColor,
                              leading: SvgPicture.asset("assets/icon/notification.svg"),
                              title: Text(
                                notification.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: AppSize(context).smallText2,
                                ),
                              ),
                              subtitle: notification.description.isNotEmpty
                                  ? Text(
                                      notification.description,
                                      style: TextStyle(
                                        color: AppColors.greyColor2,
                                        fontSize: AppSize(context).smallText3,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : null,
                              trailing: Text(
                                DateFormat('yyyy-MM-dd HH:mm').format(notification.createdDate),
                                style: TextStyle(
                                    fontSize: AppSize(context).smallText3,
                                    color: AppColors.greyColor2),
                              ),
                              onTap: () {
                                if (notification.ticketId != null && notification.ticketId!.isNotEmpty) {
                                  Navigator.push(
                                      context,
                                      rightToLeft(TicketDetailsScreen(
                                          id: notification.ticketId!)));
                                }
                              },
                            ),
                          )),
                      const SizedBox(height: 8),
                    ],
                    
                    // API Notifications Section (if any)
                    if (apiNotifications.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          'Other Notifications',
                          style: TextStyle(
                            fontSize: AppSize(context).smallText1,
                            fontWeight: FontWeight.bold,
                            color: AppColors(context).primaryColor,
                          ),
                        ),
                      ),
                      ...apiNotifications.map((notification) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                            child: ListTile(
                              shape: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: AppColors.backgroundColor)),
                              tileColor: AppColors.backgroundColor,
                              leading: SvgPicture.asset("assets/icon/notification.svg"),
                              title: Text(
                                notification?.title ?? "",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: AppSize(context).smallText2,
                                ),
                              ),
                              trailing: Text(
                                DateFormat('yyyy-MM-dd').format(DateTime.parse(notification?.createdDate.toString() ?? '')),
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
                          )),
                    ],
                  ],
                ),
    );
  }

  Future getNotifications() async {
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    final token = appProvider.userModel?.token;
    
    // Only fetch API notifications if user is logged in
    if (token == null || token.isEmpty) {
      setState(() {
        loading = false;
      });
      return;
    }
    
    setState(() {
      loading = true;
    });
    NoyificationApis.getNotification(token: token)
        .then((value) {
      setState(() {
        apiNotifications = value;
        loading = false;
      });
    }).catchError((error) {
      setState(() {
        loading = false;
      });
    });
  }

  // Build notifications view for B2B users (cache only, no API call)
  Widget _buildB2BNotificationsView(BuildContext context, List<CachedNotification> b2bNotifs, List<CachedNotification> b2cNotifs) {
    final allNotifications = b2bNotifs.length + b2cNotifs.length;

    if (allNotifications == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset("assets/icon/notification.svg", width: 64, height: 64, color: AppColors.greyColor2),
            const SizedBox(height: 16),
            Text(
              'No notifications',
              style: TextStyle(
                fontSize: AppSize(context).smallText1,
                color: AppColors.greyColor2,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      children: [
        // B2B Notifications Section
        if (b2bNotifs.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'B2B Notifications',
              style: TextStyle(
                fontSize: AppSize(context).smallText1,
                fontWeight: FontWeight.bold,
                color: AppColors(context).primaryColor,
              ),
            ),
          ),
          ...b2bNotifs.map((notification) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                child: ListTile(
                  shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.backgroundColor)),
                  tileColor: AppColors.backgroundColor,
                  leading: SvgPicture.asset("assets/icon/notification.svg"),
                  title: Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppSize(context).smallText2,
                    ),
                  ),
                  subtitle: notification.description.isNotEmpty
                      ? Text(
                          notification.description,
                          style: TextStyle(
                            color: AppColors.greyColor2,
                            fontSize: AppSize(context).smallText3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      : null,
                  trailing: Text(
                    DateFormat('yyyy-MM-dd HH:mm').format(notification.createdDate),
                    style: TextStyle(
                        fontSize: AppSize(context).smallText3,
                        color: AppColors.greyColor2),
                  ),
                  onTap: () {
                    if (notification.ticketId != null && notification.ticketId!.isNotEmpty) {
                      Navigator.push(
                          context,
                          rightToLeft(TicketDetailsScreen(
                              id: notification.ticketId!)));
                    }
                  },
                ),
              )),
          const SizedBox(height: 8),
        ],

        // B2C Notifications Section
        if (b2cNotifs.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'B2C Notifications',
              style: TextStyle(
                fontSize: AppSize(context).smallText1,
                fontWeight: FontWeight.bold,
                color: AppColors(context).primaryColor,
              ),
            ),
          ),
          ...b2cNotifs.map((notification) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                child: ListTile(
                  shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.backgroundColor)),
                  tileColor: AppColors.backgroundColor,
                  leading: SvgPicture.asset("assets/icon/notification.svg"),
                  title: Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppSize(context).smallText2,
                    ),
                  ),
                  subtitle: notification.description.isNotEmpty
                      ? Text(
                          notification.description,
                          style: TextStyle(
                            color: AppColors.greyColor2,
                            fontSize: AppSize(context).smallText3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      : null,
                  trailing: Text(
                    DateFormat('yyyy-MM-dd HH:mm').format(notification.createdDate),
                    style: TextStyle(
                        fontSize: AppSize(context).smallText3,
                        color: AppColors.greyColor2),
                  ),
                  onTap: () {
                    if (notification.ticketId != null && notification.ticketId!.isNotEmpty) {
                      Navigator.push(
                          context,
                          rightToLeft(TicketDetailsScreen(
                              id: notification.ticketId!)));
                    }
                  },
                ),
              )),
        ],
      ],
    );
  }
}
