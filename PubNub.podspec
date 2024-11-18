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
    spec.version  = '5.7.0'
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
    
    spec.resource_bundles = { "PubNub" => ["Framework/PubNub/PrivacyInfo.xcprivacy"]}

    spec.subspec 'Core' do |core|
        core.source_files = 'PubNub/{Core,Data,Modules,Misc,Network,Protocols}/**/*', 'PubNub/PubNub.h'
        core.private_header_files = [
            'PubNub/**/*Private.h',
            'PubNub/PubNub+Deprecated.h',
            'PubNub/Data/PNEnvelopeInformation.h',
            'PubNub/Data/Managers/**/*.h',
            'PubNub/Data/Models/PNXML.h',
            'PubNub/Data/Service Objects/File Sharing/PNGenerateFileUploadURLStatus.h',
            'PubNub/Data/Transport/{PNTransportMiddleware.h,PNTransportMiddlewareConfiguration.h}',
            'PubNub/Misc/{PNConstants,PNPrivateStructures}.h',
            'PubNub/Misc/Helpers/{PNArray,PNChannel,PNData,PNDate,PNDictionary,PNGZIP,PNHelpers,PNJSON,PNLockSupport,PNNumber,PNString,PNURLRequest}.h',
            'PubNub/Misc/Logger/PNLogMacro.h',
            'PubNub/Misc/Logger/Data/*.h',
            'PubNub/Misc/Protocols/{PNKeyValueStorageProtocol,PNParser}.h',
            "PubNub/Modules/Transport/{PNURLSessionTransportResponse,PNURLSessionTransport}.h",
            "PubNub/Modules/Serializer/Object/{Categories,Models}/*.h",
            "PubNub/Modules/Serializer/Object/{PNJSONDecoder,PNJSONEncoder}.h",
            "PubNub/Modules/Crypto/Cryptors/AES/PNCCCryptorWrapper.h",
            "PubNub/Modules/Crypto/Header/*.h",
            'PubNub/Network/PNReachability.h',
            'PubNub/Network/Requests/Files/PNGenerateFileUploadURLRequest.h',
            'PubNub/Network/Parsers/**/*.h',
            'PubNub/Network/Streams/*.h',
            'PubNub/Protocols/PNRequest.h',
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
    spec.license = { :type => 'PubNub Software Development Kit License', :file => 'LICENSE' }
end
