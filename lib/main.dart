import 'dart:io';
import 'dart:async';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:wefix/firebase_options.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart'; 
import 'package:wefix/main_managements.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:wefix/Data/Helper/cache_helper.dart';
import 'package:wefix/Data/Constant/app_constant.dart';
import 'package:wefix/Data/Constant/theme/dark_theme.dart';
import 'package:wefix/Data/Constant/theme/light_theme.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/LanguageProvider/l10n_provider.dart';
import 'package:wefix/Presentation/SplashScreen/splash_screen.dart';
import 'Data/model/user_model.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log('Handling a background message: ${message.messageId}');
  log('Message data: ${message.data}');
  // For background, show a system notification using flutter_local_notifications
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });

  // REGISTER BACKGROUND HANDLER BEFORE runApp
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await CacheHelper.init();

  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );

  UserModel? userModel = MainManagements.handelUserData();
  String? token;
  try {
    token = await FirebaseMessaging.instance.getToken();
  } catch (e) {
    log(e.toString());
  }
  HttpOverrides.global = MyHttpOverrides();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<LanguageProvider>(
          create: (_) => LanguageProvider(),
        ),
        ChangeNotifierProvider<AppProvider>(
          create: (_) => AppProvider(),
        ),
      ],
      builder: (c, w) {
        return MyApp(
          token: token,
          userModel: userModel,
        );
      },
    ),
  );
}

Future<void> requestNotificationPermission(BuildContext context) async {
  // Check the current permission status
  var status = await Permission.notification.status;

  if (status.isDenied) {
    // Ask user for permission
    var result = await Permission.notification.request();

    if (result.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifications enabled!')),
      );
    } else if (result.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifications denied.')),
      );
    } else if (result.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Notifications permanently denied. Please enable in settings.')),
      );
    }
  } else if (status.isGranted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifications already enabled.')),
    );
  }
}

class MyApp extends StatefulWidget {
  final UserModel? userModel;
  final String? token;
  const MyApp({Key? key, this.userModel, this.token}) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isWeb = kIsWeb;

  @override
  void initState() {
    super.initState();
    requestNotificationPermission(context);

    MainManagements.handelNotification(
      context: context,
      handler: _firebaseMessagingBackgroundHandler,
      navigatorKey: navigatorKey,
    );

    MainManagements.handelToken(
      context: context,
      token: widget.token ?? '',
    );

    MainManagements.handelLanguage(context: context);
  }

  @override
  Widget build(BuildContext context) {
    AppProvider language = Provider.of<AppProvider>(context);
    LanguageProvider languageProvider =
        Provider.of<LanguageProvider>(context, listen: true);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      builder: (context, child) {
        final botToastBuilder = BotToastInit();
        return botToastBuilder(
          context,
          MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor:
                  MediaQuery.of(context).textScaleFactor.clamp(.7, 1),
            ),
            child: child!,
          ),
        );
      },
      navigatorObservers: [BotToastNavigatorObserver()],
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: AppConstans.appName,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: Locale(languageProvider.lang ?? 'en'),
      supportedLocales: language.allLocale,
      theme: lightThemes,
      darkTheme: darkTheme,
      themeMode: ThemeMode.light,
      home: SplashScreen(
        userModel: widget.userModel,
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
