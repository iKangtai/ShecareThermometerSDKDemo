# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'
# 忽略引入库的所有警告
inhibit_all_warnings!

target 'ShecareThermometerSDKDemo' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ShecareThermometerSDKDemo
  pod 'Masonry'
  pod 'AFNetworking', '~> 4.0'
  pod 'CRToast', :git => 'https://github.com/qq345386817/CRToast.git'

  target 'ShecareThermometerSDKDemoTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'ShecareThermometerSDKDemoUITests' do
    # Pods for testing
  end

end

post_install do |installer|
    installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
                config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
            end
        end
    end
end
