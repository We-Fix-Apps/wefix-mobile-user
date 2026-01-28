// import FirebaseCore
// import FirebaseMessaging
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
    // FirebaseApp.configure()
    GMSServices.provideAPIKey("AIzaSyB_gK5Q70PoYdlP08CH8NfTyWsePdvS9e0")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // =========================================
  // تسجيل الجهاز لتلقي إشعارات الدفع (Push Notifications)
  // =========================================
  // override func application(
  //   _ application: UIApplication,
  //   didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  // ) {
  //   // ربط APNs مع Firebase Messaging لإرسال واستقبال الإشعارات
  //   Messaging.messaging().apnsToken = deviceToken
  //   // استدعاء التنفيذ الافتراضي للأب
  //   super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  // }

  // =========================================
  // استقبال الإشعارات أثناء الخلفية أو عند الإغلاق
  // =========================================
  // override func application(
  //   _ application: UIApplication,
  //   didReceiveRemoteNotification userInfo: [AnyHashable: Any],
  //   fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  // ) {
  //   super.application(
  //     application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler
  //   )
  // }

}
