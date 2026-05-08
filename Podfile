platform :ios, '13.0'

inhibit_all_warnings!

use_frameworks!
use_modular_headers!

target 'YourApp' do
  # 私有Pod - Flutter共享组件
  pod 'FlutterSharedComponent', :path => '../ios_private_pods'

  # Firebase (如果使用)
  # pod 'Firebase/Analytics'
  # pod 'Firebase/Messaging'

  # 其他第三方依赖
  # pod 'SnapKit', '~> 5.6'
  # pod 'Alamofire', '~> 5.8'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      config.build_settings['ENABLE_BITCODE'] = 'NO'

      # Flutter相关设置
      if target.name == 'Flutter'
        config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      end
    end
  end

  # 确保Flutter引擎架构正确
  installer.pods_project.build_configurations.each do |config|
    config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'i386'
  end
end
