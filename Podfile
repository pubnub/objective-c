workspace 'PubNub.xcworkspace'
install! 'cocoapods', :lock_pod_sources => false
use_frameworks!

target 'PubNub_Example' do
  platform :ios, '14.0'
  project 'Example/PubNub Example'
  pod "PubNub", :path => "."
end

target 'PubNub Mac Example' do
  platform :osx, '11.00'
  project 'Example/PubNub Example'
  pod "PubNub", :path => "."
end
