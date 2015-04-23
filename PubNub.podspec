Pod::Spec.new do |s|
  s.name         = 'PubNub'
  s.version      = '3.7.10.6'
  s.summary      = 'The PubNub Real-Time Network. Build real-time apps quickly and scale them globally.'
  s.authors = {
    'PubNub, Inc.' => 'support@pubnub.com'
  }
  s.source = {
    :git => 'https://github.com/pubnub/objective-c.git',
    :tag => 'v3.7.10.6'
  }

  # A list of file patterns which select the source files that should be
  # added to the Pods project. If the pattern is a directory then the
  # path will automatically have '*.{h,m,mm,c,cpp}' appended.
  #

  s.source_files = 'PubNub/PubNub/PubNub/Misc/Categories',
   'PubNub/PubNub/PubNub/Data',
   'PubNub/PubNub/PubNub/Misc',
   'PubNub/PubNub/PubNub/Misc/Protocols',
   'PubNub/PubNub/PubNub/Core',
   'PubNub/PubNub/PubNub/Data/Channels',
   'PubNub/PubNub/PubNub/Data/Crypto',
   'PubNub/PubNub/PubNub/Network/Packets',
   'PubNub/PubNub/PubNub/Data/Buffers',
   'PubNub/PubNub/PubNub/Network',
   'PubNub/PubNub/PubNub/Network/Transport',
   'PubNub/PubNub/PubNub/Data/Channels/Presence',
   'PubNub/PubNub/PubNub/Data/Parsers'

  s.private_header_files = "PubNub/PubNub/PubNub/Misc/PNPrivateMacro.h"

   s.resource_bundle = { 'PubNub' => 'PubNub/PubNub/PubNub/Resources/*' }

  s.ios.deployment_target = '5.1'
  s.osx.deployment_target = '10.7'

  s.ios.prefix_header_file = 'iOS/iPadDemoApp/pubnub/pubnub-Prefix.pch'

  s.requires_arc = true
  s.frameworks =  'CFNetwork', 'SystemConfiguration'
  s.library   = 'z'
  s.osx.frameworks = 'CoreWLAN'
  s.osx.prefix_header_contents = <<-EOS
#import "PNImports.h"
EOS

  s.homepage = 'http://www.pubnub.com/'
  s.license = %{
    :type => 'MIT',
    :text => <<-LICENSE'
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

