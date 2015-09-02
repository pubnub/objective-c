#
# Be sure to run `pod lib lint PubNub.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "PubNub"
  s.version          = "4.0.4"
  s.summary          = "The PubNub Real-Time Network. Build real-time apps quickly and scale them globally."
  s.homepage         = "https://github.com/pubnub/objective-c"

  s.authors = {
    "PubNub, Inc." => "support@pubnub.com"
  }
  s.source = {
    :git => "https://github.com/pubnub/objective-c.git",
    :tag => "v#{s.version}"
    }
  s.social_media_url = "https://twitter.com/pubnub"

  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.9'
  s.requires_arc = true

  s.source_files = "PubNub/**/*"
  s.private_header_files = [
    "PubNub/Core/*Private.h",
    "PubNub/Data/*Private.h",
    "PubNub/Data/Managers/**/*.h",
    "PubNub/Data/Service Objects/*Private.h",
    "PubNub/Misc/PNConstants.h",
    "PubNub/Misc/PNPrivateStructures.h",
    "PubNub/Misc/Helpers/*.h",
    "PubNub/Misc/Logger/PNLogFileManager.h",
    "PubNub/Misc/Protocols/PNParser.h",
    "PubNub/Network/**/*.h",
  ]

  s.library   = "z"
  s.dependency "CocoaLumberjack", "2.0.0"


s.license = %{ :type => "MIT", :text => <<-LICENSE'
PubNub Real-time Cloud-Hosted Push API and Push Notification Client Frameworks
Copyright (c) 2013 PubNub Inc.
http://www.pubnub.com/
http://www.pubnub.com/terms

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

PubNub Real-time Cloud-Hosted Push API and Push Notification Client Frameworks
Copyright (c) 2014 PubNub Inc.
http://www.pubnub.com/
http://www.pubnub.com/terms
LICENSE
}
  
end
