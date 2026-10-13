workspace 'PubNub.xcworkspace'
install! 'cocoapods', :lock_pod_sources => false
use_frameworks!

target 'PubNub_Example' do
  platform :ios, '17.6'
  project 'Example/PubNub Example'
  pod "PubNub", :path => "."
end

target 'PubNub Mac Example' do
  platform :osx, '14.6'
  project 'Example/PubNub Example'
  pod "PubNub", :path => "."
end
