#
# Be sure to run `pod lib lint PubNub.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |spec|
    spec.name     = 'PubNub'
    spec.version  = '4.7.7'
    spec.summary  = 'The PubNub Real-Time Network. Build real-time apps quickly and scale them globally.'
    spec.homepage = 'https://github.com/pubnub/objective-c'

    spec.authors = {
        'PubNub, Inc.' => 'support@pubnub.com'
    }
    spec.social_media_url = 'https://twitter.com/pubnub'
    spec.source = {
        :git => 'https://github.com/pubnub/objective-c.git',
        :tag => "v#{spec.version}"
    }

    spec.ios.deployment_target = '7.0'
    spec.watchos.deployment_target = '2.0'
    spec.osx.deployment_target = '10.9'
    spec.tvos.deployment_target = '9.0'
    spec.requires_arc = true

    spec.subspec 'Core' do |core|
        core.source_files = 'PubNub/{Core,Data,Misc,Network}/**/*', 'PubNub/PubNub.h'
        core.private_header_files = [
            'PubNub/**/*Private.h',
            'PubNub/Data/{PNEnvelopeInformation,PNKeychain}.h',
            'PubNub/Data/Managers/**/*.h',
            'PubNub/Misc/{PNConstants,PNPrivateStructures}.h',
            'PubNub/Misc/Helpers/{PNArray,PNChannel,PNData,PNDictionary,PNGZIP,PNHelpers,PNJSON,PNLockSupport,PNNumber,PNString,PNURLRequest}.h',
            'PubNub/Misc/Logger/PNLogMacro.h',
            'PubNub/Misc/Logger/Data/*.h',
            'PubNub/Misc/Protocols/PNParser.h',
            'PubNub/Network/**/*.h',
        ]
        core.exclude_files = 'PubNub/Core/PubNub+FAB.{h,m}'
        core.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'YES' }
    end

    spec.subspec 'Logger' do |logger|
        logger.source_files = 'PubNub/Misc/Logger/{Core,Data}/**/*', 'PubNub/Misc/Helpers/{PNLockSupport,PNDefines}.{h,m}'
        logger.private_header_files = [
            'PubNub/Misc/Logger/Data/*.h',
            'PubNub/Misc/Helpers/{PNLockSupport,PNDefines}.h'
        ]
    end

    spec.subspec 'Fabric' do |fabric|
        fabric.dependency 'PubNub/Core'
        fabric.source_files = 'PubNub/Core/PubNub+FAB.{h,m}', 'Support/Fabric/Headers/*'
        fabric.private_header_files = [ 'Support/Fabric/Headers/{Fabric+FABKits,FABKitProtocol}.h' ]
        fabric.exclude_files = 'Support/Fabric/Headers/PubNub.h'
        fabric.xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'FABRIC_SUPPORT=1' }
        fabric.pod_target_xcconfig = { 
            'APPLICATION_EXTENSION_API_ONLY' => 'YES',
            'GCC_PREPROCESSOR_DEFINITIONS' => 'FABRIC_SUPPORT=1'
        }
    end

    spec.library   = 'z'
    spec.default_subspec = 'Core'

    spec.license = { 
        :type => 'MIT', 
        :text => <<-LICENSE
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
