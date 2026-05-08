import UIKit
import Flutter

/// Flutter页面导航工具类
/// 提供便捷的方法来跳转到Flutter页面
class FlutterNavigator {

    /// 单例
    static let shared = FlutterNavigator()

    private init() {}

    /// 导航到登录页面
    /// - Parameters:
    ///   - viewController: 当前视图控制器
    ///   - completion: 导航完成回调
    func navigateToLogin(
        from viewController: UIViewController,
        arguments: [String: Any]? = nil,
        completion: (() -> Void)? = nil
    ) {
        FlutterEngineManager.shared.navigateToFlutter(
            route: FlutterEngineManager.Routes.login,
            arguments: arguments,
            from: viewController
        )
        completion?()
    }

    /// 导航到商城页面
    /// - Parameters:
    ///   - viewController: 当前视图控制器
    ///   - completion: 导航完成回调
    func navigateToShop(
        from viewController: UIViewController,
        arguments: [String: Any]? = nil,
        completion: (() -> Void)? = nil
    ) {
        FlutterEngineManager.shared.navigateToFlutter(
            route: FlutterEngineManager.Routes.shop,
            arguments: arguments,
            from: viewController
        )
        completion?()
    }

    /// 导航到问卷页面
    /// - Parameters:
    ///   - viewController: 当前视图控制器
    ///   - completion: 导航完成回调
    func navigateToSurvey(
        from viewController: UIViewController,
        arguments: [String: Any]? = nil,
        completion: (() -> Void)? = nil
    ) {
        FlutterEngineManager.shared.navigateToFlutter(
            route: FlutterEngineManager.Routes.survey,
            arguments: arguments,
            from: viewController
        )
        completion?()
    }

    /// 导航到指定路由
    /// - Parameters:
    ///   - route: 路由名称
    ///   - viewController: 当前视图控制器
    ///   - arguments: 传递给Flutter的参数
    func navigateTo(
        route: String,
        from viewController: UIViewController,
        arguments: [String: Any]? = nil
    ) {
        FlutterEngineManager.shared.navigateToFlutter(
            route: route,
            arguments: arguments,
            from: viewController
        )
    }

    /// 发送自定义消息到Flutter
    /// - Parameters:
    ///   - method: 方法名
    ///   - arguments: 参数
    func sendMessage(method: String, arguments: [String: Any]? = nil) {
        FlutterEngineManager.shared.sendMessageToFlutter(
            method: method,
            arguments: arguments
        )
    }

    /// 请求Flutter获取设备信息
    /// - Parameter completion: 回调
    func requestDeviceInfo(completion: @escaping ([String: Any]?) -> Void) {
        FlutterEngineManager.shared.sendMessageToFlutter(
            method: "getDeviceInfo",
            arguments: nil
        )
        // 监听返回结果
        NotificationCenter.default.addObserver(
            forName: .flutterDeviceInfoReceived,
            object: nil,
            queue: .main
        ) { notification in
            completion(notification.userInfo as? [String: Any])
        }
    }
}

// MARK: - UIViewController Extension
extension UIViewController {

    /// 便捷方法：导航到Flutter登录页
    func navigateToFlutterLogin(with arguments: [String: Any]? = nil) {
        FlutterNavigator.shared.navigateToLogin(from: self, arguments: arguments)
    }

    /// 便捷方法：导航到Flutter商城页
    func navigateToFlutterShop(with arguments: [String: Any]? = nil) {
        FlutterNavigator.shared.navigateToShop(from: self, arguments: arguments)
    }

    /// 便捷方法：导航到Flutter问卷页
    func navigateToFlutterSurvey(with arguments: [String: Any]? = nil) {
        FlutterNavigator.shared.navigateToSurvey(from: self, arguments: arguments)
    }

    /// 便捷方法：导航到指定Flutter路由
    func navigateToFlutter(route: String, with arguments: [String: Any]? = nil) {
        FlutterNavigator.shared.navigateTo(route: route, from: self, arguments: arguments)
    }
}
