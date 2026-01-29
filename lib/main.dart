import 'dart:io';
import 'dart:async';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:wefix/injection_container.dart';
import 'package:wefix/firebase_options.dart';
import 'package:wefix/main_managements.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:wefix/Data/Helper/cache_helper.dart';
import 'package:wefix/Data/Constant/app_constant.dart';
import 'package:wefix/Data/Constant/theme/dark_theme.dart';
import 'package:wefix/Data/Constant/theme/light_theme.dart';
import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/LanguageProvider/l10n_provider.dart';
import 'package:wefix/Presentation/SplashScreen/splash_screen.dart';
import 'package:wefix/Data/Functions/token_refresh.dart';
import 'package:wefix/Data/Functions/token_utils.dart';
import 'package:wefix/Data/Functions/permissions_helper.dart';
import 'Data/model/user_model.dart';
import 'l10n/app_localizations.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // await Firebase.initializeApp();
  log('Handling a background message: ${message.messageId}');
  log('Message data: ${message.data}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();

  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });
  
  // Request notification permission FIRST - before anything else
  // This ensures the native iOS dialog shows immediately
  await PermissionsHelper.requestNotificationPermissionOnLaunch();
  
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

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

// All permissions are now requested in main() function, so this is no longer needed

// Notification permission is now handled by PermissionsHelper
// This function is kept for backward compatibility but uses PermissionsHelper
Future<void> requestNotificationPermission(BuildContext context) async {
  var status = await Permission.notification.status;
  if (status.isDenied) {
    var result = await Permission.notification.request();
    if (result.isGranted) {
      log('Notifications enabled.');
    } else if (result.isDenied) {
      log('Notifications denied.');
    } else if (result.isPermanentlyDenied) {
      log('Notifications permanently denied. Please enable in settings.');
    }
  } else if (status.isGranted) {
    log('Notifications already enabled.');
  }
  if (!context.mounted) return;
  await PermissionsHelper.requestNotificationPermission(context);
}

class MyApp extends StatefulWidget {
  final UserModel? userModel;
  final String? token;
  const MyApp({Key? key, this.userModel, this.token}) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool isWeb = kIsWeb;
  AppLifecycleState? _lastLifecycleState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Notification permission is already requested in main() via PermissionsHelper
    // No need to request again here

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
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // When app returns to foreground (resumed), check and refresh token if needed
    if (state == AppLifecycleState.resumed && _lastLifecycleState != AppLifecycleState.resumed) {
      _handleAppResumed();
    }
    
    _lastLifecycleState = state;
  }

  /// Handle app returning to foreground - check and refresh token if needed
  Future<void> _handleAppResumed() async {
    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      
      // Only check token for company personnel (MMS users)
      if (appProvider.userModel != null && 
          appProvider.accessToken != null && 
          appProvider.refreshToken != null) {
        
        // Check if token needs refresh or is expired
        final tokenExpiresAt = appProvider.tokenExpiresAt;
        
        if (tokenExpiresAt != null) {
          // If token is expired or about to expire, try to refresh it
          if (!isTokenValid(tokenExpiresAt) || shouldRefreshToken(tokenExpiresAt)) {
            log('App resumed: Token expired or needs refresh, attempting refresh...');
            final refreshed = await ensureValidToken(appProvider, context);
            if (!refreshed) {
              log('App resumed: Token refresh failed, user will be logged out on next API call');
            } else {
              log('App resumed: Token refreshed successfully');
            }
          }
        } else if (appProvider.refreshToken != null && appProvider.refreshToken!.isNotEmpty) {
          // If we have refresh token but no expiration date, try to refresh
          log('App resumed: No expiration date, attempting token refresh...');
          final refreshed = await ensureValidToken(appProvider, context);
          if (!refreshed) {
            log('App resumed: Token refresh failed');
          } else {
            log('App resumed: Token refreshed successfully');
          }
        }
      }
    } catch (e) {
      log('Error handling app resumed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    AppProvider language = Provider.of<AppProvider>(context);
    LanguageProvider languageProvider = Provider.of<LanguageProvider>(context, listen: true);
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
              textScaler: TextScaler.linear(MediaQuery.of(context).textScaleFactor.clamp(.7, 1)),
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
        AppLocalizations.delegate,
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
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
