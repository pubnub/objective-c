source 'https://github.com/CocoaPods/Specs.git'
workspace 'PubNub.xcworkspace'
xcodeproj 'Example/PubNub.xcodeproj'

target 'PubNub_Example', :exclusive => true do
  platform :ios, '7.0'
  xcodeproj 'Example/PubNub.xcodeproj'
  pod "PubNub", :path => "."
end

target 'iOS Tests', :exclusive => true do
  platform :ios, "7.0"
  xcodeproj 'Tests/PubNub Tests.xcodeproj'
  begin  
    gem 'slather'
  rescue Gem::LoadError
    puts 'install slather for code coverage ("sudo gem install slather")'
  else
    plugin 'slather'
  end
  pod "JSZVCR", "~> 0.5"
  pod "PubNub", :path => "."
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
    	if target.name == 'Pods-iOS Tests-PubNub'
        	target.build_configurations.each do |config|
            	if config.name == 'Debug'
                	config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)', 'DEBUG=1', 'TEST=1']
                end
            end
        end
    end
end
