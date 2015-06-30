source 'https://github.com/CocoaPods/Specs.git'
workspace 'PubNub.xcworkspace'
xcodeproj 'Example/PubNub.xcodeproj'
use_frameworks!

plugin 'slather'

target 'PubNub_Example', :exclusive => true do
  platform :ios, '7.0'
  xcodeproj 'Example/PubNub.xcodeproj'
  pod "PubNub", :path => "."
end

target 'iOS Tests', :exclusive => true do
  platform :ios, "7.0"
  xcodeproj 'Tests/PubNub Tests.xcodeproj'
  #pod "JSZVCR", "~> 0.5"
  pod "JSZVCR", :git => "https://github.com/jzucker2/JSZVCR.git", :branch => "fix_concurrency"
  pod "PubNub", :path => "."
end


post_install do |installer_representation|
    installer_representation.project.targets.each do |target|
    	if target.name == 'Pods-iOS Tests-PubNub'
        	target.build_configurations.each do |config|
            	if config.name == 'Debug'
                	config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)', 'DEBUG=1', 'TEST=1']
                end
            end
        end
    end
end
