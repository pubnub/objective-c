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

target 'iOS Tests-Swift', :exclusive => true do
    platform :ios, "7.0"
    xcodeproj 'Tests/PubNub Tests.xcodeproj'
    pod "JSZVCR", "~> 0.5"
    pod "PubNub", :path => "."
end
