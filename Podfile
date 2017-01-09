# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

def shared_pods
	use_frameworks!
	pod 'OAuthSwift', '~> 1.1.0'
	pod 'RealmSwift'
	pod 'SwiftyJSON'
end

target 'Kiptrak' do
	shared_pods
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
