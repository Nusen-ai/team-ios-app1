import Flutter
import UIKit

/// Flutter引擎全局管理器
/// 负责Flutter引擎的创建、初始化和生命周期管理
class FlutterEngineManager {

    /// 单例实例
    static let shared = FlutterEngineManager()

    /// Flutter引擎实例
    private(set) var engine: FlutterEngine?

    /// MethodChannel用于双向通信
    private var methodChannel: FlutterMethodChannel?

    /// EventChannel用于事件流
    private var eventChannel: FlutterEventChannel?

    /// 事件流处理器
    private var eventSink: FlutterEventSink?

    /// Flutter路由名称
    struct Routes {
        static let login = "/login"
        static let shop = "/shop"
        static let survey = "/survey"
    }

    private init() {
        // 私有初始化器，确保单例
    }

    /// 初始化Flutter引擎
    /// - Parameter viewController: 展示Flutter View的UIViewController
    /// - Returns: 初始化的FlutterViewController
    @discardableResult
    func initializeEngine() -> FlutterViewController {

        // 如果引擎已存在，直接返回现有viewController
        if let existingEngine = engine {
            let flutterViewController = FlutterViewController(
                engine: existingEngine,
                nibName: nil,
                bundleIdentifier: nil
            )
            setupMethodChannel(on: flutterViewController)
            return flutterViewController
        }

        // 创建新的Flutter引擎
        let flutterEngine = FlutterEngine(name: "FlutterSharedComponents")

        // 配置引擎选项
        let options = FlutterEngineGroupOptions(
            entranceLibraryKey: "FlutterSharedComponents"
        )

        // 使用引擎组创建引擎（iOS 13+）
        if #available(iOS 13.0, *) {
            let engineGroup = FlutterEngineGroup(
                name: "FlutterSharedComponents",
                options: options ?? FlutterEngineGroupOptions()
            )
            engine = engineGroup.makeEngine(with: flutterEngine)
        } else {
            engine = flutterEngine
        }

        // 设置Flutter资源路径
        guard let engine = engine else {
            fatalError("Flutter引擎初始化失败")
        }

        // 设置默认路由
        engine.defaultRouteName = Routes.login

        // 预热引擎
        engine.run()

        // 如果需要预加载特定路由，可以在这里处理
        // engine.run(withRoute: Routes.login)

        // 创建FlutterViewController
        let flutterViewController = FlutterViewController(
            engine: engine,
            nibName: nil,
            bundleIdentifier: nil
        )

        // 设置MethodChannel
        setupMethodChannel(on: flutterViewController)

        // 设置EventChannel
        setupEventChannel(on: flutterViewController)

        NSLog("Flutter引擎初始化完成")

        return flutterViewController
    }

    /// 设置MethodChannel用于方法调用
    private func setupMethodChannel(on viewController: FlutterViewController) {
        guard let engine = viewController.engine else { return }

        // 创建从Native到Flutter的MethodChannel
        methodChannel = FlutterMethodChannel(
            name: "com.shared.components/native_to_flutter",
            binaryMessenger: engine.binaryMessenger
        )

        // 处理来自Flutter的方法调用
        methodChannel?.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call: call, result: result)
        }
    }

    /// 设置EventChannel用于事件流
    private func setupEventChannel(on viewController: FlutterViewController) {
        guard let engine = viewController.engine else { return }

        eventChannel = FlutterEventChannel(
            name: "com.shared.components/event_channel",
            binaryMessenger: engine.binaryMessenger
        )

        eventChannel?.setStreamHandler(FlutterEventStreamHandler())
    }

    /// 处理来自Flutter的方法调用
    private func handleMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getDeviceInfo":
            // 获取设备信息并返回给Flutter
            result([
                "platform": "iOS",
                "version": UIDevice.current.systemVersion,
                "model": UIDevice.current.model,
                "name": UIDevice.current.name
            ])

        case "onLoginSuccess":
            // 处理登录成功事件
            if let args = call.arguments as? [String: Any] {
                NotificationCenter.default.post(
                    name: .flutterLoginSuccess,
                    object: nil,
                    userInfo: args
                )
            }
            result(true)

        case "onPageNavigation":
            // 处理页面导航事件
            if let args = call.arguments as? [String: Any],
               let page = args["page"] as? String {
                NotificationCenter.default.post(
                    name: .flutterPageNavigation,
                    object: nil,
                    userInfo: ["page": page]
                )
            }
            result(true)

        case "onScanResult":
            // 处理扫码结果
            if let args = call.arguments as? [String: Any],
               let scanResult = args["scanResult"] as? String {
                NotificationCenter.default.post(
                    name: .flutterScanResult,
                    object: nil,
                    userInfo: ["result": scanResult]
                )
            }
            result(true)

        case "onBluetoothData":
            // 处理蓝牙数据
            if let args = call.arguments as? [String: Any] {
                NotificationCenter.default.post(
                    name: .flutterBluetoothData,
                    object: nil,
                    userInfo: args
                )
            }
            result(true)

        case "onError":
            // 处理错误
            if let args = call.arguments as? [String: Any],
               let message = args["message"] as? String {
                NotificationCenter.default.post(
                    name: .flutterError,
                    object: nil,
                    userInfo: ["message": message]
                )
            }
            result(true)

        case "onSurveySubmitted":
            // 处理问卷提交
            if let args = call.arguments as? [String: Any] {
                NotificationCenter.default.post(
                    name: .flutterSurveySubmitted,
                    object: nil,
                    userInfo: args
                )
            }
            result(true)

        case "onDeviceInfoReceived":
            // 处理设备信息接收
            if let args = call.arguments as? [String: Any] {
                NotificationCenter.default.post(
                    name: .flutterDeviceInfoReceived,
                    object: nil,
                    userInfo: args
                )
            }
            result(true)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    /// 发送消息到Flutter
    /// - Parameters:
    ///   - method: 方法名
    ///   - arguments: 参数
    func sendMessageToFlutter(method: String, arguments: [String: Any]? = nil) {
        methodChannel?.invokeMethod(method, arguments: arguments)
    }

    /// 导航到Flutter页面
    /// - Parameters:
    ///   - route: 路由名称
    ///   - arguments: 传递给Flutter的参数
    func navigateToFlutter(
        route: String,
        arguments: [String: Any]? = nil,
        from viewController: UIViewController
    ) {
        // 初始化或获取Flutter引擎
        let flutterViewController = initializeEngine()

        // 设置路由和参数
        if let engine = flutterViewController.engine {
            engine.setInitialRoute(route)

            if let args = arguments {
                // 通过MethodChannel传递参数
                engine.binaryMessenger.makeBackgroundUploadMessenger().send(
                    onChannel: "com.shared.components/native_params",
                    message: try? JSONEncoder().encode(args)
                )
            }
        }

        // 切换到Flutter页面
        viewController.present(flutterViewController, animated: true)
    }

    /// 处理深度链接
    func handleDeepLink(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let host = components.host else {
            return
        }

        // 解析路由
        switch host {
        case "login":
            NotificationCenter.default.post(name: .shouldNavigateToLogin, object: nil)
        case "shop":
            NotificationCenter.default.post(name: .shouldNavigateToShop, object: nil)
        case "survey":
            NotificationCenter.default.post(name: .shouldNavigateToSurvey, object: nil)
        default:
            break
        }
    }

    /// 重置Flutter引擎
    func resetEngine() {
        engine?.reset()
        engine = nil
        methodChannel = nil
        eventChannel = nil
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let flutterLoginSuccess = Notification.Name("FlutterLoginSuccess")
    static let flutterPageNavigation = Notification.Name("FlutterPageNavigation")
    static let flutterScanResult = Notification.Name("FlutterScanResult")
    static let flutterBluetoothData = Notification.Name("FlutterBluetoothData")
    static let flutterError = Notification.Name("FlutterError")
    static let flutterSurveySubmitted = Notification.Name("FlutterSurveySubmitted")
    static let flutterDeviceInfoReceived = Notification.Name("FlutterDeviceInfoReceived")
    static let shouldNavigateToLogin = Notification.Name("ShouldNavigateToLogin")
    static let shouldNavigateToShop = Notification.Name("ShouldNavigateToShop")
    static let shouldNavigateToSurvey = Notification.Name("ShouldNavigateToSurvey")
}

// MARK: - Event Stream Handler
class FlutterEventStreamHandler: NSObject, FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        // 保存事件接收器
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }
}
