import 'dart:io';
import 'dart:async';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await CacheHelper.init();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

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

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  log('Handling a background message: ${message.messageId}');
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
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _streamSubscription;

  @override
  void initState() {
    initConnectivity();
    MainManagements.handelNotification(
        context: context,
        handler: _firebaseMessagingBackgroundHandler,
        navigatorKey: _navigatorKey);
    MainManagements.handelToken(context: context, token: widget.token ?? '');
    MainManagements.handelLanguage(context: context);
    _streamSubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    super.initState();
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
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
        // Wrap BotToastInit first
        final botToastBuilder = BotToastInit();

        // Apply BotToast and clamp textScaleFactor
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
      navigatorKey: _navigatorKey,
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

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      log(e.toString());
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }
    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    AppProvider appProvider = Provider.of<AppProvider>(context);
    setState(() {
      appProvider.connectivityResult = result;
    });
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
