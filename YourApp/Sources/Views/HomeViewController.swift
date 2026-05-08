import UIKit
import Flutter

/// iOS原生页面控制器示例
/// 展示如何在iOS原生页面中与Flutter进行交互
class HomeViewController: UIViewController {

    // MARK: - UI Elements
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "iOS App 1 - 原生首页"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "点击下方按钮跳转到Flutter页面"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var loginButton: UIButton = {
        let button = createButton(title: "登录页面", color: .systemBlue)
        button.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        return button
    }()

    private lazy var shopButton: UIButton = {
        let button = createButton(title: "商城页面", color: .systemGreen)
        button.addTarget(self, action: #selector(shopTapped), for: .touchUpInside)
        return button
    }()

    private lazy var surveyButton: UIButton = {
        let button = createButton(title: "问卷页面", color: .systemOrange)
        button.addTarget(self, action: #selector(surveyTapped), for: .touchUpInside)
        return button
    }()

    private lazy var deviceInfoButton: UIButton = {
        let button = createButton(title: "获取设备信息", color: .systemPurple)
        button.addTarget(self, action: #selector(getDeviceInfoTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNotifications()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "iOS App 1"

        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(stackView)

        stackView.addArrangedSubview(loginButton)
        stackView.addArrangedSubview(shopButton)
        stackView.addArrangedSubview(surveyButton)
        stackView.addArrangedSubview(deviceInfoButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),

            loginButton.heightAnchor.constraint(equalToConstant: 50),
            shopButton.heightAnchor.constraint(equalToConstant: 50),
            surveyButton.heightAnchor.constraint(equalToConstant: 50),
            deviceInfoButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLoginSuccess(_:)),
            name: .flutterLoginSuccess,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePageNavigation(_:)),
            name: .flutterPageNavigation,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleError(_:)),
            name: .flutterError,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDeviceInfoReceived(_:)),
            name: .flutterDeviceInfoReceived,
            object: nil
        )
    }

    private func createButton(title: String, color: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = color
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        return button
    }

    // MARK: - Actions
    @objc private func loginTapped() {
        navigateToFlutterLogin(with: ["source": "ios_app_1", "action": "login"])
    }

    @objc private func shopTapped() {
        navigateToFlutterShop(with: ["source": "ios_app_1", "action": "shop"])
    }

    @objc private func surveyTapped() {
        navigateToFlutterSurvey(with: ["source": "ios_app_1", "action": "survey"])
    }

    @objc private func getDeviceInfoTapped() {
        // 先跳转到商城页面，然后触发设备信息获取
        FlutterNavigator.shared.navigateToShop(from: self, arguments: [
            "source": "ios_app_1",
            "action": "getDeviceInfo"
        ])
    }

    // MARK: - Notification Handlers
    @objc private func handleLoginSuccess(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            print("收到登录成功事件: \(userInfo)")
            showAlert(title: "登录成功", message: "UserID: \(userInfo["userId"] ?? "N/A")")
        }
    }

    @objc private func handlePageNavigation(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let page = userInfo["page"] as? String {
            print("Flutter页面导航到: \(page)")
        }
    }

    @objc private func handleError(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let message = userInfo["message"] as? String {
            showAlert(title: "错误", message: message)
        }
    }

    @objc private func handleDeviceInfoReceived(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            print("收到设备信息: \(userInfo)")
            showAlert(title: "设备信息", message: "\(userInfo)")
        }
    }

    // MARK: - Helpers
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}
