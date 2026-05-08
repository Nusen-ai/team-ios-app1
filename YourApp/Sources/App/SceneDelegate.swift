import UIKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        // 创建窗口
        window = UIWindow(windowScene: windowScene)

        // 创建根视图控制器
        let homeViewController = HomeViewController()
        let navigationController = UINavigationController(rootViewController: homeViewController)

        // 设置为根视图
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        // 处理URL上下文
        if let urlContext = connectionOptions.urlContexts.first {
            handleURL(urlContext.url)
        }

        // 处理通知响应
        if let notification = connectionOptions.notificationResponse {
            handleNotificationResponse(notification)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        Logger.info("场景断开连接")
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        Logger.info("场景变为活跃")
    }

    func sceneWillResignActive(_ scene: UIScene) {
        Logger.info("场景即将变为非活跃")
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        Logger.info("场景即将进入前台")
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        Logger.info("场景已进入后台")
    }

    // MARK: - URL Handling

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        handleURL(url)
    }

    private func handleURL(_ url: URL) {
        Logger.info("收到URL: \(url.absoluteString)")

        // 解析URL并导航
        FlutterEngineManager.shared.handleDeepLink(url: url)

        // 处理自定义Scheme
        if url.scheme == "flutterapp" {
            if let host = url.host {
                switch host {
                case "login":
                    if let rootVC = window?.rootViewController {
                        FlutterNavigator.shared.navigateToLogin(from: rootVC)
                    }
                case "shop":
                    if let rootVC = window?.rootViewController {
                        FlutterNavigator.shared.navigateToShop(from: rootVC)
                    }
                case "survey":
                    if let rootVC = window?.rootViewController {
                        FlutterNavigator.shared.navigateToSurvey(from: rootVC)
                    }
                default:
                    break
                }
            }
        }
    }

    // MARK: - Notification Handling

    private func handleNotificationResponse(_ response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo
        Logger.info("收到通知响应: \(userInfo)")
    }
}
