source 'https://github.com/CocoaPods/Specs.git'
workspace 'PubNub.xcworkspace'
use_frameworks!
install! 'cocoapods', :lock_pod_sources => false

abstract_target 'PubNub Integration' do
  pod "PubNub", :path => "."

  target 'PubNub_Example' do
    platform :ios, '8.0'
    project 'Example/PubNub Example'
  end

  target 'PubNub Mac Example' do
    platform :osx, '10.9'
    project 'Example/PubNub Example'
  end

  abstract_target 'PubNub Tests' do
    pod "BeKindRewind", '~> 1.0.0'
    
    target 'iOS ObjC Tests' do
      platform :ios, "8.0"
      project 'Tests/PubNub Tests'
    end

#    target 'iOS Swift Tests' do
#      platform :ios, "8.0"
#      project 'Tests/PubNub Tests'
#    end

    target 'OSX ObjC Tests' do
      platform :osx, '10.9'
      project 'Tests/PubNub Tests'
    end

    target 'tvOS ObjC Tests' do
      platform :tvos, '9.0'
      project 'Tests/PubNub Tests'
    end
  end
end

# Making all interfaces visible for all targets on explicit import
pre_install do |installer_representation|
    installer_representation.aggregate_targets.each do |aggregate_target|
        aggregate_target.spec_consumers.each do |spec_consumer|
            unless spec_consumer.private_header_files.empty?
                spec_consumer.spec.attributes_hash['private_header_files'].clear
            end 
        end
    end
end

post_install do |installer_representation|
    installer_representation.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['GCC_INSTRUMENT_PROGRAM_FLOW_ARCS'] = 'YES'
            config.build_settings['GCC_GENERATE_TEST_COVERAGE_FILES'] = 'YES'
            config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = 'YES' unless target.name =~ /PubNub/
        end
    end
end
