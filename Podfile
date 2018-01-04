platform :ios, '10.0'

def shared_pods
	use_frameworks!
	pod 'Hue'
	pod 'Kingfisher'
	pod 'MarqueeLabel/Swift'
	pod 'OAuthSwift', '~> 1.2.0'
	pod 'RealmSwift'
	pod 'SwiftyBeaver'
	pod 'SwiftyJSON'
end

target 'Kiptrak' do
	shared_pods
	pod 'CustomizableActionSheet'
	pod 'KDCircularProgress'
	pod 'LGAlertView'
	pod 'Hero'
	pod 'RxKeyboard'
	pod 'SwipeCellKit'
end

target 'Currently Watching Widget' do
	shared_pods
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == "OAuthSwift"
            puts "Updating #{target.name} OTHER_SWIFT_FLAGS"
            target.build_configurations.each do |config|
              config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['$(inherited)']
              if !config.build_settings['OTHER_SWIFT_FLAGS'].include? " \"-D\" \"OAUTH_APP_EXTENSIONS\""
                config.build_settings['OTHER_SWIFT_FLAGS'] << " \"-D\" \"OAUTH_APP_EXTENSIONS\""
              end
            end
        end
  end
end
