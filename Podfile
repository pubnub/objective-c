source 'https://github.com/CocoaPods/Specs.git'
workspace 'PubNub.xcworkspace'
xcodeproj 'Example/PubNub Example.xcodeproj'

target 'PubNub_Example', :exclusive => true do
  platform :ios, '8.0'
  xcodeproj 'Example/PubNub Example.xcodeproj'
  pod "PubNub", :path => "."
end

target 'PubNub Mac Example', :exclusive => true do
  platform :osx, '10.9'
  xcodeproj 'Example/PubNub Example.xcodeproj'
  pod "PubNub", :path => "."
end

target 'iOS ObjC Tests', :exclusive => true do
  platform :ios, "8.0"
  xcodeproj 'Tests/PubNub Tests.xcodeproj'
  begin  
    gem 'slather'
  rescue Gem::LoadError
    puts 'install slather for code coverage ("sudo gem install slather")'
  else
    plugin 'slather'
  end
  pod 'BlocksKit', '~> 2.2.5'
  pod "JSZVCR", :git => 'https://github.com/jzucker2/JSZVCR.git', :branch => 'mac-osx'
  pod "PubNub", :path => "."
end

target 'iOS Swift Tests', :exclusive => true do
    platform :ios, "8.0"
    xcodeproj 'Tests/PubNub Tests.xcodeproj'
    pod "JSZVCR", :git => 'https://github.com/jzucker2/JSZVCR.git', :branch => 'mac-osx'
    pod "PubNub", :path => "."
end

target 'watchOS ObjC Tests', :exclusive => true do
    platform :watchos, "2.0"
    xcodeproj 'Tests/PubNub Tests.xcodeproj'
    begin
        gem 'slather'
        rescue Gem::LoadError
        puts 'install slather for code coverage ("sudo gem install slather")'
        else
        plugin 'slather'
    end
    pod 'BlocksKit', '~> 2.2.5'
    pod "JSZVCR", :git => 'https://github.com/jzucker2/JSZVCR.git', :branch => 'mac-osx'
    pod "PubNub", :path => "."
end

target 'tvOS ObjC Tests', :exclusive => true do
    platform :tvos, "9.0"
    xcodeproj 'Tests/PubNub Tests.xcodeproj'
    begin
        gem 'slather'
        rescue Gem::LoadError
        puts 'install slather for code coverage ("sudo gem install slather")'
        else
        plugin 'slather'
    end
    pod 'BlocksKit', '~> 2.2.5'
    pod "JSZVCR", :git => 'https://github.com/jzucker2/JSZVCR.git', :branch => 'mac-osx'
    pod "PubNub", :path => "."
end

target 'OSX ObjC Tests', :exclusive => true do
  platform :osx, '10.9'
  xcodeproj 'Tests/PubNub Tests.xcodeproj'
  begin  
    gem 'slather'
  rescue Gem::LoadError
    puts 'install slather for code coverage ("sudo gem install slather")'
  else
    plugin 'slather'
  end
  pod 'BlocksKit', '~> 2.2.5'
  pod "JSZVCR", :git => 'https://github.com/jzucker2/JSZVCR.git', :branch => 'mac-osx'
  pod "PubNub", :path => "."
end

post_install do |installer_representation|
    installer_representation.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['GCC_INSTRUMENT_PROGRAM_FLOW_ARCS'] = 'NO'
            config.build_settings['GCC_GENERATE_TEST_COVERAGE_FILES'] = 'NO'
            if target.name == "CocoaLumberjack"
              config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = 'YES'
            end
            if target.name == "OHHTTPStubs"
              config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = 'YES'
            end
        end
    end
end
