import UIKit

/// 应用配置管理器
class AppConfig {

    /// 单例
    static let shared = AppConfig()

    /// 当前应用名称
    var appName: String {
        return Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "iOS App 1"
    }

    /// 当前应用版本
    var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    /// 构建号
    var buildNumber: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    /// Flutter模块配置
    struct Flutter {
        /// MethodChannel名称
        static let methodChannelName = "com.shared.components/native_to_flutter"

        /// EventChannel名称
        static let eventChannelName = "com.shared.components/event_channel"

        /// Flutter引擎名称
        static let engineName = "FlutterSharedComponents"
    }

    /// 路由配置
    struct Routes {
        static let login = "/login"
        static let shop = "/shop"
        static let survey = "/survey"

        /// 所有可用路由
        static let all: [String] = [login, shop, survey]

        /// 根据名称获取路由
        static func route(for name: String) -> String? {
            switch name.lowercased() {
            case "login": return login
            case "shop": return shop
            case "survey": return survey
            default: return nil
            }
        }
    }

    private init() {}
}

/// 日志工具
struct Logger {

    enum Level: String {
        case debug = "🔍 DEBUG"
        case info = "ℹ️ INFO"
        case warning = "⚠️ WARNING"
        case error = "❌ ERROR"
    }

    static func log(_ message: String, level: Level = .debug, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        let timestamp = DateFormatter.logFormatter.string(from: Date())
        print("\(timestamp) \(level.rawValue) [\(fileName):\(line)] \(function): \(message)")
        #endif
    }

    static func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, file: file, function: function, line: line)
    }

    static func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, file: file, function: function, line: line)
    }

    static func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, file: file, function: function, line: line)
    }

    static func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .error, file: file, function: function, line: line)
    }
}

extension DateFormatter {
    static let logFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
}

/// 设备信息工具
struct DeviceInfo {

    /// 获取完整设备信息
    static func getDeviceInfo() -> [String: Any] {
        let device = UIDevice.current
        return [
            "name": device.name,
            "systemName": device.systemName,
            "systemVersion": device.systemVersion,
            "model": device.model,
            "localizedModel": device.localizedModel,
            "identifierForVendor": device.identifierForVendor?.uuidString ?? "Unknown",
            "isSimulator": isSimulator()
        ]
    }

    /// 判断是否运行在模拟器上
    static func isSimulator() -> Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
}
