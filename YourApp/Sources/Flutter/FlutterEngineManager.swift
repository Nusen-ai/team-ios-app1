import Flutter
import UIKit

class FlutterEngineManager {

    static let shared = FlutterEngineManager()

    private(set) var engine: FlutterEngine?
    private(set) var currentFlutterViewController: FlutterViewController?

    private var methodChannel: FlutterMethodChannel?
    private var eventChannel: FlutterEventChannel?
    private var closeChannel: FlutterMethodChannel?

    struct Routes {
        static let login = "/login"
        static let shop = "/shop"
        static let survey = "/survey"
    }

    private init() {}

    @discardableResult
    func initializeEngine() -> FlutterViewController {

        if let existingEngine = engine {
            let flutterViewController = FlutterViewController(
                engine: existingEngine,
                nibName: nil,
                bundle: nil
            )
            setupMethodChannel(on: flutterViewController)
            setupEventChannel(on: flutterViewController)
            setupCloseChannel(on: flutterViewController)
            return flutterViewController
        }

        // 使用 FlutterEngineGroup 创建引擎
        let flutterEngine = FlutterEngineGroup(name: "FlutterSharedComponents", project: nil)

        // 创建引擎实例
        engine = FlutterEngine(
            project: nil,
            dartEntrypointArguments: ["arg1", "arg2"]
        )

        guard let engine = engine else {
            fatalError("Flutter引擎初始化失败")
        }

        // 初始化引擎并等待完成
        let semaphore = DispatchSemaphore(value: 0)

        engine.run { [weak self] success in
            if success {
                NSLog("Flutter引擎运行成功")
            } else {
                NSLog("Flutter引擎运行失败")
            }
            semaphore.signal()
        }

        // 等待引擎启动完成（最多5秒）
        _ = semaphore.wait(timeout: .now() + 5)

        // 创建 FlutterViewController
        let flutterViewController = FlutterViewController(
            engine: engine,
            nibName: nil,
            bundle: nil
        )

        // 设置初始路由
        engine.defaultRouteName = Routes.login

        setupMethodChannel(on: flutterViewController)
        setupEventChannel(on: flutterViewController)
        setupCloseChannel(on: flutterViewController)

        NSLog("Flutter引擎初始化完成")

        return flutterViewController
    }

    private func setupMethodChannel(on viewController: FlutterViewController) {
        guard let engine = viewController.engine else { return }

        methodChannel = FlutterMethodChannel(
            name: "com.shared.components/native_to_flutter",
            binaryMessenger: engine.binaryMessenger
        )

        methodChannel?.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call: call, result: result)
        }
    }

    private func setupEventChannel(on viewController: FlutterViewController) {
        guard let engine = viewController.engine else { return }

        eventChannel = FlutterEventChannel(
            name: "com.shared.components/event_channel",
            binaryMessenger: engine.binaryMessenger
        )

        eventChannel?.setStreamHandler(FlutterEventStreamHandler())
    }

    private func setupCloseChannel(on viewController: FlutterViewController) {
        guard let engine = viewController.engine else { return }

        closeChannel = FlutterMethodChannel(
            name: "com.shared.components/close_flutter",
            binaryMessenger: engine.binaryMessenger
        )

        closeChannel?.setMethodCallHandler { [weak self] call, result in
            self?.handleCloseMethodCall(call: call, result: result)
        }
    }

    private func handleMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getDeviceInfo":
            result([
                "platform": "iOS",
                "version": UIDevice.current.systemVersion,
                "model": UIDevice.current.model,
                "name": UIDevice.current.name
            ])

        case "onLoginSuccess":
            if let args = call.arguments as? [String: Any] {
                NotificationCenter.default.post(
                    name: .flutterLoginSuccess,
                    object: nil,
                    userInfo: args
                )
            }
            result(true)

        case "onPageNavigation":
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
            if let args = call.arguments as? [String: Any] {
                NotificationCenter.default.post(
                    name: .flutterBluetoothData,
                    object: nil,
                    userInfo: args
                )
            }
            result(true)

        case "onError":
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
            if let args = call.arguments as? [String: Any] {
                NotificationCenter.default.post(
                    name: .flutterSurveySubmitted,
                    object: nil,
                    userInfo: args
                )
            }
            result(true)

        case "onDeviceInfoReceived":
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

    func sendMessageToFlutter(method: String, arguments: [String: Any]? = nil) {
        methodChannel?.invokeMethod(method, arguments: arguments)
    }

    func navigateToFlutter(
        route: String,
        arguments: [String: Any]? = nil,
        from viewController: UIViewController
    ) {
        let flutterViewController = initializeEngine()
        currentFlutterViewController = flutterViewController

        // 设置初始路由
        if let engine = flutterViewController.engine {
            engine.defaultRouteName = route
        }

        // 设置全屏显示
        flutterViewController.modalPresentationStyle = .fullScreen

        // 设置关闭回调
        flutterViewController.onDismiss = { [weak self] in
            self?.currentFlutterViewController = nil
            NotificationCenter.default.post(name: .flutterPageClosed, object: nil)
        }

        viewController.present(flutterViewController, animated: true)
    }

    /// 关闭当前 Flutter 页面，返回到 iOS 原生页面
    func closeFlutterPage() {
        if let flutterVC = currentFlutterViewController {
            flutterVC.dismiss(animated: true) { [weak self] in
                self?.currentFlutterViewController = nil
                NotificationCenter.default.post(name: .flutterPageClosed, object: nil)
            }
        }
    }

    /// 处理关闭页面的 MethodCall
    private func handleCloseMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "closeFlutterPage":
            closeFlutterPage()
            result(true)
        case "onPageNavigated":
            if let args = call.arguments as? [String: Any],
               let page = args["page"] as? String {
                NotificationCenter.default.post(
                    name: .flutterPageNavigated,
                    object: nil,
                    userInfo: ["page": page]
                )
            }
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func handleDeepLink(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let host = components.host else {
            return
        }

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

    func resetEngine() {
        engine?.reset()
        engine = nil
        currentFlutterViewController = nil
        methodChannel = nil
        eventChannel = nil
        closeChannel = nil
    }
}

extension Notification.Name {
    static let flutterLoginSuccess = Notification.Name("FlutterLoginSuccess")
    static let flutterPageNavigation = Notification.Name("FlutterPageNavigation")
    static let flutterScanResult = Notification.Name("FlutterScanResult")
    static let flutterBluetoothData = Notification.Name("FlutterBluetoothData")
    static let flutterError = Notification.Name("FlutterError")
    static let flutterSurveySubmitted = Notification.Name("FlutterSurveySubmitted")
    static let flutterDeviceInfoReceived = Notification.Name("FlutterDeviceInfoReceived")
    static let flutterPageClosed = Notification.Name("FlutterPageClosed")
    static let flutterPageNavigated = Notification.Name("FlutterPageNavigated")
    static let shouldNavigateToLogin = Notification.Name("ShouldNavigateToLogin")
    static let shouldNavigateToShop = Notification.Name("ShouldNavigateToShop")
    static let shouldNavigateToSurvey = Notification.Name("ShouldNavigateToSurvey")
}

class FlutterEventStreamHandler: NSObject, FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }
}
