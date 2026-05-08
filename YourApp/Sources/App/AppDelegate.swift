import UIKit
import Flutter

@main
class AppDelegate: FlutterAppDelegate {

    /// Flutter引擎单例
    private var flutterEngine: FlutterEngine?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // 预初始化Flutter引擎以加快首次加载速度
        if let flutterEngine = FlutterEngineManager.shared.engine {
            self.flutterEngine = flutterEngine
            NSLog("Flutter引擎已预初始化")
        }

        // 配置Firebase推送（如果使用）
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    /// 处理推送通知
    override func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        NSLog("设备Token: \(token)")

        // 将Token传递给Flutter
        FlutterEngineManager.shared.sendMessageToFlutter(
            method: "onDeviceTokenReceived",
            arguments: ["token": token]
        )

        super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }

    /// 处理推送注册失败
    override func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        NSLog("推送注册失败: \(error.localizedDescription)")
        super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }

    /// 处理URL Scheme
    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        // 处理来自Flutter的URL回调
        if url.scheme == "flutterapp" {
            FlutterEngineManager.shared.handleDeepLink(url: url)
            return true
        }
        return super.application(app, open: url, options: options)
    }
}
