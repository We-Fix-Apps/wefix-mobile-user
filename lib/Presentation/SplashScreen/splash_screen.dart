// ignore_for_file: void_checks

import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import 'package:wefix/Business/AppProvider/app_provider.dart';
import 'package:wefix/Business/Category/category_apis.dart';
import 'package:wefix/Business/language/language_api.dart';

import 'package:wefix/Data/Functions/app_size.dart';
import 'package:wefix/Data/Functions/navigation.dart';
import 'package:wefix/Data/Functions/token_utils.dart';
import 'package:wefix/Data/Helper/cache_helper.dart';

import 'package:wefix/Data/model/user_model.dart';
import 'package:wefix/Presentation/auth/login_screen.dart';
import 'package:wefix/layout_screen.dart';
import 'package:wefix/Data/services/version_check_service.dart';
import 'package:wefix/Presentation/VersionCheck/version_check_screen.dart';
import 'package:wefix/Data/Notification/fcm_setup.dart';
import 'package:wefix/Data/Notification/awesome_notification.service.dart';

class SplashScreen extends StatefulWidget {
  final UserModel? userModel;

  const SplashScreen({Key? key, this.userModel}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  VideoPlayerController? _controller;
  bool _isVideoInitialized = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();

    _initializeVideo();

    // Skip the video after 3 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        checkVersionAndNavigate();
      }
    });

    getAppLanguage();
  }
  
  /// Stop video immediately and completely
  void _stopVideoImmediately() {
    if (_controller != null && _controller!.value.isInitialized) {
      try {
        _controller!.pause();
        _controller!.setVolume(0.0); // Mute volume immediately
        developer.log('🛑 [Splash] Video paused and muted');
        print('🛑 [Splash] Video paused and muted');
      } catch (e) {
        developer.log('⚠️ [Splash] Error stopping video: $e');
        print('⚠️ [Splash] Error stopping video: $e');
      }
    }
  }
  
  void _onSplashExit() {
    // Stop video immediately and completely to prevent background sound
    _stopVideoImmediately();
    
    developer.log('✅ [Splash] Splash screen exit - will process notification after delay');
    print('✅ [Splash] Splash screen exit - will process notification after delay');
    
    // Mark splash as done and process pending notification once the next root screen is active.
    // Use longer delay to ensure HomeLayout/LoginScreen is fully built and splash is completely gone
    Future.delayed(const Duration(milliseconds: 2000), () {
      FcmHelper.markSplashScreenCompleted();
      developer.log('✅ [Splash] Splash marked as completed');
      print('✅ [Splash] Splash marked as completed');
      Future.delayed(const Duration(milliseconds: 1000), () {
        developer.log('🚀 [Splash] Calling navigateFromPendingNotification');
        print('🚀 [Splash] Calling navigateFromPendingNotification');
        FcmHelper.navigateFromPendingNotification();
        NotificationsController.interceptInitialCallActionRequest();
      });
    });
  }

  Future<void> _initializeVideo() async {
    if (_isDisposed) return;
    
    _controller = VideoPlayerController.asset("assets/video/wefix_logo_motion.mp4");
    
    try {
      await _controller!.initialize();
      if (mounted && !_isDisposed && _controller != null) {
        setState(() {
          _isVideoInitialized = true;
        });
        _controller!.play();
      }
    } catch (error) {
      if (mounted && !_isDisposed) {
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    
    // Store reference and clear immediately
    final controller = _controller;
    _controller = null;
    
    // Dispose asynchronously to avoid blocking
    if (controller != null) {
      Future.microtask(() async {
        try {
          // Stop video immediately
          if (controller.value.isInitialized) {
            await controller.pause();
            controller.setVolume(0.0); // Mute before disposing
          }
          
          // Wait a bit for any pending operations
          await Future.delayed(const Duration(milliseconds: 50));
          
          controller.dispose();
          developer.log('🗑️ [Splash] Video controller disposed');
          print('🗑️ [Splash] Video controller disposed');
        } catch (e) {
          developer.log('⚠️ [Splash] Error disposing video: $e');
          print('⚠️ [Splash] Error disposing video: $e');
        }
      });
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isVideoInitialized && _controller != null && !_isDisposed
            ? Center(
                child: SizedBox(
                  width: double.infinity,
                  height: AppSize(context).height,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller!.value.size.width,
                      height: _controller!.value.size.height,
                      child: VideoPlayer(_controller!),
                    ),
                  ),
                ),
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  checkVersionAndNavigate() async {
    developer.log('🔍 [Splash] Checking version...');
    print('🔍 [Splash] Checking version...');
    // Check for app update
    final needsUpdate = await VersionCheckService.checkForUpdate();
    developer.log('🔍 [Splash] Version check completed: needsUpdate=$needsUpdate');
    print('🔍 [Splash] Version check completed: needsUpdate=$needsUpdate');
    
    if (needsUpdate && mounted) {
      developer.log('📱 [Splash] Update needed, navigating to VersionCheckScreen');
      print('📱 [Splash] Update needed, navigating to VersionCheckScreen');
      // Stop video BEFORE navigation to prevent background sound
      _stopVideoImmediately();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const VersionCheckScreen(),
        ),
      );
      _onSplashExit();
      return;
    }
    
    // If no update needed, proceed with normal navigation
    developer.log('✅ [Splash] No update needed, proceeding to navigatorToFirstPage');
    print('✅ [Splash] No update needed, proceeding to navigatorToFirstPage');
    navigatorToFirstPage();
  }

  navigatorToFirstPage() async {
    developer.log('🚀 [Splash] navigatorToFirstPage called');
    print('🚀 [Splash] navigatorToFirstPage called');
    
    AppProvider appProvider = Provider.of<AppProvider>(context, listen: false);
    
    // Check if user manually logged out
    final isLoggedOut = CacheHelper.getData(key: CacheHelper.isLoggedOut);
    developer.log('🔍 [Splash] isLoggedOut: $isLoggedOut, userModel: ${widget.userModel != null}');
    print('🔍 [Splash] isLoggedOut: $isLoggedOut, userModel: ${widget.userModel != null}');
    
    // If user logged out manually, always go to login screen (even if user data exists for biometric)
    if (isLoggedOut == true) {
      developer.log('📱 [Splash] User logged out, navigating to LoginScreen');
      print('📱 [Splash] User logged out, navigating to LoginScreen');
      getAppLanguage().whenComplete(() {
        developer.log('✅ [Splash] Language loaded, navigating to LoginScreen');
        print('✅ [Splash] Language loaded, navigating to LoginScreen');
        // Stop video BEFORE navigation to prevent background sound
        _stopVideoImmediately();
        Navigator.pushReplacement(
          context,
          downToTop(const LoginScreen()),
        );
        _onSplashExit();
      });
      return;
    }
    
    if (widget.userModel != null) {
      developer.log('👤 [Splash] User model found, processing user data');
      print('👤 [Splash] User model found, processing user data');
      appProvider.addUser(user: widget.userModel);
      // Load tokens from cache when restoring user data
      appProvider.loadTokensFromCache();
      
      // Check if token is expired after loading from cache
      // Only check for MMS users (company personnel with roleId == 2)
      if (appProvider.userModel?.customer.roleId == 2) {
        final tokenExpiresAt = appProvider.tokenExpiresAt;
        if (tokenExpiresAt != null && !isTokenValid(tokenExpiresAt)) {
          // Token is expired - force logout
          appProvider.clearUser();
          appProvider.clearTokens();
        getAppLanguage().whenComplete(() {
          // Stop video BEFORE navigation to prevent background sound
          _stopVideoImmediately();
          Navigator.pushReplacement(
            context,
            downToTop(const LoginScreen()),
          );
          _onSplashExit();
        });
          return;
        }
      }
      
      developer.log('📱 [Splash] Navigating to HomeLayout');
      print('📱 [Splash] Navigating to HomeLayout');
      getAppLanguage().whenComplete(() {
        developer.log('✅ [Splash] Language loaded, navigating to HomeLayout');
        print('✅ [Splash] Language loaded, navigating to HomeLayout');
        // Stop video BEFORE navigation to prevent background sound
        _stopVideoImmediately();
        Navigator.pushReplacement(
          context,
          downToTop(const HomeLayout()),
        );
        _onSplashExit();
      });
    } else {
      developer.log('📱 [Splash] No user model, navigating to LoginScreen');
      print('📱 [Splash] No user model, navigating to LoginScreen');
      getAppLanguage().whenComplete(() {
        developer.log('✅ [Splash] Language loaded, navigating to LoginScreen');
        print('✅ [Splash] Language loaded, navigating to LoginScreen');
        // Stop video BEFORE navigation to prevent background sound
        _stopVideoImmediately();
        Navigator.pushReplacement(
          context,
          downToTop(const LoginScreen()),
        );
        _onSplashExit();
      });
    }
  }

  Future getAppLanguage() async {
    developer.log('🌐 [Splash] getAppLanguage called');
    print('🌐 [Splash] getAppLanguage called');
    AppProvider languageProvider =
        Provider.of<AppProvider>(context, listen: false);
    try {
      await LanguageApis.getAppLang(lang: 'ar').then((value) {
        developer.log('✅ [Splash] Language API response received: ${value.isNotEmpty}');
        print('✅ [Splash] Language API response received: ${value.isNotEmpty}');
        if (value.isNotEmpty) {
          List<String> allGlobal = [];
          languageProvider.addLang(value);
          for (var element in languageProvider.allLanguage) {
            if (!allGlobal.contains(element.key)) {
              allGlobal.add(element.key ?? '');
            }
          }
          languageProvider.addGlobal(allGlobal);
          developer.log('✅ [Splash] Language data processed');
          print('✅ [Splash] Language data processed');
        }
      });
    } catch (e) {
      developer.log('❌ [Splash] Error loading language: $e');
      print('❌ [Splash] Error loading language: $e');
    }
  }

  Future getColors() async {
    try {
      AppProvider appProvider =
          Provider.of<AppProvider>(context, listen: false);
      await CategoryApis.getColor(token: appProvider.userModel?.token ?? '')
          .then((value) {
        appProvider.addColor(value);
        navigatorToFirstPage();
      });
    } catch (e) {
      if (mounted) setState(() {});
    }
  }
}
