import FirebaseCore
import FirebaseMessaging
import Flutter
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {

  // =========================================
  // تطبيق يبدأ التشغيل
  // =========================================
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // تهيئة Firebase عند بدء التطبيق
    FirebaseApp.configure()
    
    GMSServices.provideAPIKey("AIzaSyB_gK5Q70PoYdlP08CH8NfTyWsePdvS9e0")
    GeneratedPluginRegistrant.register(with: self)
    
    // طلب إذن الإشعارات
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { _, _ in }
      )
    } else {
      let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      application.registerUserNotificationSettings(settings)
    }
    
    application.registerForRemoteNotifications()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // =========================================
  // تسجيل الجهاز لتلقي إشعارات الدفع (Push Notifications)
  // =========================================
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    // ربط APNs مع Firebase Messaging لإرسال واستقبال الإشعارات
    Messaging.messaging().apnsToken = deviceToken
    // استدعاء التنفيذ الافتراضي للأب
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  // =========================================
  // استقبال الإشعارات أثناء الخلفية أو عند الإغلاق
  // =========================================
  override func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable: Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) {
    super.application(
      application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler
    )
  }

}