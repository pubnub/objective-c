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
    spec.version  = '5.1.3'
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

    spec.ios.deployment_target = '14.0'
    spec.watchos.deployment_target = '7.0'
    spec.osx.deployment_target = '11.00'
    spec.tvos.deployment_target = '14.0'
    spec.requires_arc = true

    spec.subspec 'Core' do |core|
        core.source_files = 'PubNub/{Core,Data,Modules,Misc,Network}/**/*', 'PubNub/PubNub.h'
        core.private_header_files = [
            'PubNub/**/*Private.h',
            'PubNub/Data/{PNEnvelopeInformation}.h',
            'PubNub/Data/Managers/**/*.h',
            'PubNub/Data/Models/PNXML.h',
            'PubNub/Data/Service Objects/PNGenerateFileUploadURLStatus.h',
            'PubNub/Misc/{PNConstants,PNPrivateStructures}.h',
            'PubNub/Misc/Helpers/{PNArray,PNChannel,PNData,PNDate,PNDictionary,PNGZIP,PNHelpers,PNJSON,PNLockSupport,PNNumber,PNString,PNURLRequest}.h',
            'PubNub/Misc/Logger/PNLogMacro.h',
            'PubNub/Misc/Logger/Data/*.h',
            'PubNub/Misc/Protocols/{PNKeyValueStorageProtocol,PNParser}.h',
            "PubNub/Modules/Crypto/Cryptors/AES/PNCCCryptorWrapper.h",
            "PubNub/Modules/Crypto/Header/*.h",
            'PubNub/Network/{PNNetwork,PNNetworkResponseSerializer,PNReachability,PNRequestParameters,PNURLBuilder}.h',
            'PubNub/Network/Requests/Files/PNGenerateFileUploadURLRequest.h',
            'PubNub/Network/Parsers/**/*.h'
        ]
        core.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'YES' }
    end

    spec.subspec 'Logger' do |logger|
        logger.source_files = 'PubNub/Misc/Logger/{Core,Data}/**/*', 'PubNub/Misc/Helpers/{PNLockSupport,PNDefines}.{h,m}'
        logger.private_header_files = [
            'PubNub/Misc/Logger/Data/*.h',
            'PubNub/Misc/Helpers/{PNLockSupport,PNDefines}.h'
        ]
    end

    spec.library   = 'z'
    spec.default_subspec = 'Core'

    spec.license = { 
        :type => 'MIT', 
        :text => <<-LICENSE
            PubNub Software Development Kit License Agreement
            Copyright © 2023 PubNub Inc. All rights reserved.

            Subject to the terms and conditions of the license, you are hereby granted
            a non-exclusive, worldwide, royalty-free license to (a) copy and modify
            the software in source code or binary form for use with the software services
            and interfaces provided by PubNub, and (b) redistribute unmodified copies
            of the software to third parties. The software may not be incorporated in
            or used to provide any product or service competitive with the products
            and services of PubNub.

            The above copyright notice and this license shall be included
            in or with all copies or substantial portions of the software.

            This license does not grant you permission to use the trade names, trademarks,
            service marks, or product names of PubNub, except as required for reasonable
            and customary use in describing the origin of the software and reproducing
            the content of this license.

            THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF
            ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
            MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO
            EVENT SHALL PUBNUB OR THE AUTHORS OR COPYRIGHT HOLDERS OF THE SOFTWARE BE
            LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
            CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
            SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

            https://www.pubnub.com/
            https://www.pubnub.com/terms
        LICENSE
    }
end
