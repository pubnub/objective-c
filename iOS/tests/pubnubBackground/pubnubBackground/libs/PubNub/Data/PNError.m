//
//  PNError.m
//  pubnub
//
//  Class which will be used to describe internal
//  PubNub client errors.
//
//
//  Created by Sergey Mamontov on 12/5/12.
//
//

#import <Foundation/Foundation.h>
#import "PNError+Protected.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub error must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark - Private interface methods

@interface PNError ()


#pragma mark - Properties

@property (nonatomic, copy) NSString *errorMessage;

// Stores reference on associated object with which
// error is occurred
@property (nonatomic, strong) id associatedObject;


#pragma mark - Instance methods

/**
 * Returns error domain which will be based on 
 * error code
 */
- (NSString *)domainForError:(NSInteger)errorCode;

@end


#pragma mark - Public interface methods

@implementation PNError


#pragma mark - Class methods

+ (PNError *)errorWithCode:(NSInteger)errorCode {

    return [self errorWithMessage:nil code:errorCode];
}

+ (PNError *)errorWithHTTPStatusCode:(NSInteger)statusCode {

    NSInteger errorCode = kPNAPIUnauthorizedAccessError;

    if (statusCode  == 403) {

        errorCode = kPNAPIAccessForbiddenError;
    }


    return [self errorWithCode:errorCode];;
}

+ (PNError *)errorWithResponseErrorMessage:(NSString *)errorMessage {

    NSInteger errorCode = kPNUnknownError;

    // Check whether error message tell something about presence
    // (this mean that PubNub client tried to use presence API
    // which is not enabled on https://admin.pubnub.com
    if ([errorMessage rangeOfString:@"Presence"].location != NSNotFound) {

        errorCode = kPNPresenceAPINotAvailableError;
    }
    // Check whether error caused by malformed data sent to the PubNub service
    else if ([errorMessage rangeOfString:@"Invalid"].location != NSNotFound) {

        // Check whether server reported that wrong JSON format has been sent
        // to it
        if ([errorMessage rangeOfString:@"JSON"].location != NSNotFound) {

            errorCode = kPNInvalidJSONError;
        }
        // Check whether restricted characters has been used in request
        else if ([errorMessage rangeOfString:@"Character"].location != NSNotFound) {

            // Check whether restricted characters has been used in channel names
            if ([errorMessage rangeOfString:@"Channel"].location != NSNotFound) {

                errorCode = kPNRestrictedCharacterInChannelNameError;
            }
        }
        // Check whether wrong key was specified for request
        else if([errorMessage rangeOfString:@"Key"].location != NSNotFound) {

            errorCode = kPNInvalidSubscribeOrPublishKeyError;
        }
    }
    // Check whether error caused by message content or not
    else if ([errorMessage rangeOfString:@"Message"].location != NSNotFound) {

        // Check whether message is too long or not
        if ([errorMessage rangeOfString:@"Too Large"].location != NSNotFound) {

            errorCode = kPNTooLongMessageError;
        }
    }
    // Check whether error by issue with push notifications feature on server
    else if ([errorMessage rangeOfString:@"Push"].location != NSNotFound){

        // Check whether push notifications is not enabled
        if ([errorMessage rangeOfString:@"not enabled"].location != NSNotFound) {

            errorCode = kPNPushNotificationsNotEnabledError;
        }
    }

    PNError *error = nil;
    if (errorCode == kPNUnknownError) {

        error = [PNError errorWithMessage:errorMessage code:errorCode];
    }
    else {

        error = [self errorWithCode:errorCode];
    }


    return error;
}

+ (PNError *)errorWithMessage:(NSString *)errorMessage code:(NSInteger)errorCode {
    
    return [[[self class] alloc] initWithMessage:errorMessage code:errorCode];
}


#pragma mark - Instance methods

- (id)initWithMessage:(NSString *)errorMessage code:(NSInteger)errorCode {

    // Check whether initialization successful or not
    if((self = [super initWithDomain:[self domainForError:errorCode] code:errorCode userInfo:nil])) {

        self.errorMessage = errorMessage;
    }


    return self;
}

- (void)setAssociatedObject:(id)associatedObject {

    // Prevent ability to change associated object if it was set before
    if (_associatedObject == nil) {

        _associatedObject = associatedObject;
    }
}

- (NSString *)localizedDescription {
    
    NSString *errorDescription = self.errorMessage;
    
    // Check whether error message was specified or not
    if (errorDescription == nil) {
        
        switch (self.code) {
                
            case kPNClientConfigurationError:
                
                errorDescription = @"Incomplete PubNub client configuration. Make sure you set the configuration "
                                    "correctly.";
                break;
            case kPNClientTriedConnectWhileConnectedError:
                
                errorDescription = @"PubNub client already connected to origin";
                break;
            case kPNClientConnectionFailedOnInternetFailureError:
            case kPNClientConnectionClosedOnSSLNegotiationFailureError:
            case kPNClientConnectionClosedOnServerRequestError:
            case kPNClientConnectionClosedOnSocketsError:
                
                errorDescription = @"PubNub client connection failed";
                break;
            case kPNClientConnectionClosedOnInternetFailureError:

                errorDescription = @"PubNub client connection lost connection";
                break;
            case kPNRequestExecutionFailedOnInternetFailureError:
            case kPNRequestExecutionFailedClientNotReadyError:
            case kPNRequestExecutionFailedClientSuspendedError:

                errorDescription = @"PubNub client can't perform request";
                break;
            case kPNConnectionErrorOnSetup:
                
                errorDescription = @"PubNub client connection can't be opened";
                break;
            case kPNPresenceAPINotAvailableError:

                errorDescription = @"PubNub client can't use presence API";
                break;
            case kPNInvalidJSONError:

                errorDescription = @"PubNub service can't process JSON";
                break;
            case kPNInvalidSubscribeOrPublishKeyError:

                errorDescription = @"PubNub service can't process request";
                break;
            case kPNRestrictedCharacterInChannelNameError:

                errorDescription = @"PubNub service process request for channel";
                break;
            case kPNAPIUnauthorizedAccessError:
            case kPNAPIAccessForbiddenError:

                errorDescription = @"PubNub API access denied";
                break;
            case kPNMessageHasNoContentError:
            case kPNMessageHasNoChannelError:
            case kPNTooLongMessageError:
            case kPNMessageObjectError:

                errorDescription = @"PubNub client can't submit message";
                break;
            case kPNPushNotificationsNotEnabledError:

                errorDescription = @"PubNub client can't work with APNS API";
                break;
            case kPNDevicePushTokenIsEmptyError:
                
                errorDescription = @"PubNub client can't enable push notification";
                break;
            case kPNResponseEncodingError:

                errorDescription = @"PubNub client can't decode response";
                break;
            case kPNResponseMalformedJSONError:
                
                errorDescription = @"PubNub client can't parse response";
                break;
            case kPNCryptoEmptyCipherKeyError:
            case kPNCryptoIllegalInitializationParametersError:
                
                errorDescription = @"Cipher helper initalization error";
                break;
            case kPNCryptoInsufficentBufferSizeError:
                
                errorDescription = @"CRYPTO: Wrong buffer size";
                break;
            case kPNCryptoInsufficentMemoryError:
                
                errorDescription = @"CRYPTO: Insufficient memory";
                break;
            case kPNCryptoAligmentInputDataError:
                
                errorDescription = @"CRYPTO: Input data error";
                break;
            case kPNCryptoInputDataProcessingError:
                
                errorDescription = @"CRYPTO: Input data processing error";
                break;
            case kPNCryptoUnavailableFeatureError:
                
                errorDescription = @"CRYPTO: Not implemented";
                break;
            default:

                errorDescription = @"Unknown error. Please contact support@pubnub.com with complete logs of this issue";
                break;
        }
    }
    
    
    return errorDescription;
}

- (NSString *)localizedFailureReason {
    
    NSString *failureReason = nil;
    
    switch (self.code) {
            
        case kPNClientConfigurationError:
            
            failureReason = @"One of the required configuration fields is empty:\n- publish key\n- subscribe key\n- "
                             "secret key";
            break;
        case kPNClientTriedConnectWhileConnectedError:
            
            failureReason = @"Looks like the client tried to connect to the remote PubNub service while already "
                             "connected";
            break;
        case kPNClientConnectionFailedOnInternetFailureError:
            
            failureReason = @"Looks like the client lost it's net connection while trying to connect to the PubNub "
                             "origin";
            break;
        case kPNClientConnectionClosedOnSSLNegotiationFailureError:

            failureReason = @"Looks like the client was unable to connect to the PubNub origin due to an SSL "
                             "handshake issue";
            break;
        case kPNClientConnectionClosedOnSocketsError:
            
            failureReason = @"Looks like the system was unable to allocate and/or support a native socket connection";
            break;
        case kPNClientConnectionClosedOnServerRequestError:
            
            failureReason = @"Looks like the client was unable to connect to the PubNub origin due to receiving a RST. "
                             "A server, proxy, or gateway refused the connection";
            break;
        case kPNRequestExecutionFailedOnInternetFailureError:
        case kPNClientConnectionClosedOnInternetFailureError:
            
            failureReason = @"Looks like the client lost it's net connection";
            break;
        case kPNRequestExecutionFailedByTimeoutError:

            failureReason = @"Looks like the client timed out while waiting to receive data from the PubNub origin";
            break;
        case kPNConnectionErrorOnSetup:
            
            failureReason = @"The connection can't be opened due to an errors in the connection config";
            break;
        case kPNRequestExecutionFailedClientNotReadyError:

            failureReason = @"Looks like the client is not connected to the PubNub origin";
            break;
        case kPNRequestExecutionFailedClientSuspendedError:

            failureReason = @"Looks like the client suspended";
            break;
        case kPNPresenceAPINotAvailableError:

            failureReason = @"Looks like the Presence feature is not enabled. Be sure to enable it for your keys at "
                             "http://admin.pubnub.com, and try again";
            break;
        case kPNInvalidJSONError:

            failureReason = @"Looks like we sent malformed JSON or the message was changed after the signature was "
                             "generated";
            break;
        case kPNInvalidSubscribeOrPublishKeyError:

            failureReason = @"Looks like either the subscribe or publish key is wrong";
            break;
        case kPNRestrictedCharacterInChannelNameError:

            failureReason = @"Looks like there are invalid characters in one of the channel names";
            break;
        case kPNAPIUnauthorizedAccessError:

            failureReason = @"An 'auth' key must be provided for this request because PAM is enabled and access was "
                             "denied";
            break;
        case kPNAPIAccessForbiddenError:

            failureReason = @"An 'auth' key was provided for this request because PAM is enabled, but access was "
                             "denied because the 'auth' key supplied does not posess the adequate permissions for "
                             "this resource";
            break;
        case kPNMessageHasNoContentError:

            failureReason = @"Looks like message has an empty or non-existant body";
            break;
        case kPNMessageHasNoChannelError:

            failureReason = @"Looks like the target channel for the message has not been specified";
            break;
        case kPNMessageObjectError:

            failureReason = @"Looks like no message object was passed";
            break;
        case kPNTooLongMessageError:

            failureReason = @"Looks like message is too large and can't be processed";
            break;
        case kPNPushNotificationsNotEnabledError:

            failureReason = @"Looks like APNS (push notifications) weren't enabled for this subscribe key. Enable at "
                             "http://admin.pubnub.com and try again";
            break;
        case kPNDevicePushTokenIsEmptyError:
            
            failureReason = @"Looks like device push notification token is nil";
            break;
        case kPNResponseEncodingError:

            failureReason = @"Looks like the PubNub origin sent a response not in UTF8 format";
            break;
        case kPNResponseMalformedJSONError:

            failureReason = @"Looks like the PubNub origin sent a response with malformed JSON in it (maybe truncated)";
            break;
        case kPNCryptoEmptyCipherKeyError:
            
            failureReason = @"Looks like the cipher key is missing in the configuration instance";
            break;
        case kPNCryptoIllegalInitializationParametersError:
            
            failureReason = @"Looks like illegal values were used during crypto initialization";
            break;
        case kPNCryptoInsufficentBufferSizeError:
            
            failureReason = @"Looks like an output buffer with an insufficient type has been specified";
            break;
        case kPNCryptoInsufficentMemoryError:
            
            failureReason = @"Looks like there is not enough memory for the crypto helper operation to complete";
            break;
        case kPNCryptoAligmentInputDataError:
            
            failureReason = @"Looks like the input data is not aligned properly";
            break;
        case kPNCryptoInputDataProcessingError:
            
            failureReason = @"The crypto helper failed to process input data because of an unknown error";
            break;
        case kPNCryptoUnavailableFeatureError:
            
            failureReason = @"Looks like someone tried to use a feature which is not available for the specified "
                             "algorithm";
            break;
        default:

            failureReason = @"Unknown.";
            break;
    }
    
    
    return failureReason;
}

- (NSString *)localizedRecoverySuggestion {
    
    NSString *fixSuggestion = nil;
    
    switch (self.code) {
            
        case kPNClientConfigurationError:
            
            fixSuggestion = @"Ensure that you specified all required keys while creating the PNConfiguration instance "
                             "or all values specified in PNDefaultConfiguration.h. You can always visit "
                             "https://admin.pubnub.com to verify your correct keys.";
            break;
        case kPNClientTriedConnectWhileConnectedError:
            
            fixSuggestion = @"If you wish to reconnect the PubNub client, close the connection first, then try to "
                             "connect again.";
            break;
        case kPNClientConnectionFailedOnInternetFailureError:
        case kPNRequestExecutionFailedOnInternetFailureError:
            
            fixSuggestion = @"Ensure that all network configuration (including any proxy) is correct, and try again.";
            break;
        case kPNClientConnectionClosedOnSSLNegotiationFailureError:

            fixSuggestion = @"Ensure that all network configuration (including any proxy) is correct and try again. "
                             "If this issue persists, please contact support at support@pubnub.com and reference error "
                             "kPNClientConnectionClosedOnSSLNegotiationFailureError.";
            break;
        case kPNClientConnectionClosedOnServerRequestError:
            
            fixSuggestion = @"Ensure that all network configuration (including any proxy) is correct and try again. "
                             "If this issue persists, please contact support at support@pubnub.com and reference error "
                             "kPNClientConnectionClosedOnServerRequestError.";
            break;
        case kPNClientConnectionClosedOnSocketsError:
            
            fixSuggestion = @"There was a network socket error. Try to repeat this request later.";
            break;
        case kPNConnectionErrorOnSetup:
            
            fixSuggestion = @"Check whether the client has been configured to use a secure connection, and whether the "
                             "PubNub origin has a valid certificate.\nIf you continue to receive this error, you can "
                             "set kPNShouldReduceSecurityLevelOnError to YES in PNDefaultConfiguration.h or provide "
                             "YES when initializing PNConfiguration instance.";
            break;
        case kPNRequestExecutionFailedClientNotReadyError:

            fixSuggestion = @"Ensure that the PubNub has proper connectivity to the PubNub origin and try again.";
            break;
        case kPNRequestExecutionFailedClientSuspendedError:

            fixSuggestion = @"Make sure that your application is configured to run persistently in background or check "
                             "whether client is connected before issue any requests.";
            break;
        case kPNRequestExecutionFailedByTimeoutError:

            fixSuggestion = @"There was a timeout. Try send the request again later.";
            break;
        case kPNPresenceAPINotAvailableError:

            fixSuggestion = @"Please visit https://admin.pubnub.com, enable Presence, and try again.";
            break;
        case kPNInvalidJSONError:

            fixSuggestion = @"There was an error sending the data to the origin. Be sure you didn't try to send "
                             "non-object or non-JSON data.";
            break;
        case kPNInvalidSubscribeOrPublishKeyError:

            fixSuggestion = @"Review the request and ensure that the correct keys are referenced.";
            break;
        case kPNRestrictedCharacterInChannelNameError:

            fixSuggestion = @"Ensure that you don't use the comma char (,) in your channel names.";
            break;
        case kPNAPIUnauthorizedAccessError:

            fixSuggestion = @"Specify an 'authorizationKey' for the configuration instance used to setup the "
                             "PubNub client.";
            break;
        case kPNAPIAccessForbiddenError:

            fixSuggestion = @"Ensure that you specified a valid 'authorizationKey'. If the key is correct, then "
                             "access is currently denied for this key.";
            break;
        case kPNMessageHasNoContentError:

            fixSuggestion = @"Ensure that you are not sending an empty message (maybe there are only spaces in it?).";
            break;
        case kPNMessageHasNoChannelError:

            fixSuggestion = @"Ensure that you specified a valid channel for this message.";
            break;
        case kPNTooLongMessageError:

            fixSuggestion = @"Please visit https://admin.pubnub.com to enable Elastic Message Size if you wish to "
                             "send larger-sized messages.";
            break;
        case kPNPushNotificationsNotEnabledError:

            fixSuggestion = @"Please visit https://admin.pubnub.com to enable the push notification (APNS) feature.";
            break;
        case kPNDevicePushTokenIsEmptyError:
            
            fixSuggestion = @"Ensure that you provided the correct non-nil device push token.";
            break;
        case kPNMessageObjectError:

            fixSuggestion = @"Ensure that you provided the correct message object to be used for this request.";
            break;
        case kPNResponseEncodingError:

            fixSuggestion = @"Ensure that you are using the UTF8 character table to send messages to the PubNub "
                             "service.";
            break;
        case kPNResponseMalformedJSONError:

            fixSuggestion = @"Try to resend the request which caused this error.";
            break;
        case kPNCryptoEmptyCipherKeyError:
            
            fixSuggestion = @"Please check the client configuration instance, and ensure that the cipher key is "
                             "specified, or simply don't try to initialize the helper if there is no key supplied.";
            break;
        case kPNCryptoIllegalInitializationParametersError:
            
            fixSuggestion = @"Ensure that correct parameters has been passed to crypto functions.";
            break;
        case kPNCryptoInsufficentBufferSizeError:
            
            fixSuggestion = @"Ensure that a buffer with the correct amount of space has been specified and provided "
                             "for the cryptor";
            break;
        case kPNCryptoInsufficentMemoryError:
            
            fixSuggestion = @"Looks like the cryptor has run out of memory during this last operation. Try to separate "
                             "the input data in chunks and process them one by one if possible.";
            break;
        case kPNCryptoAligmentInputDataError:
            
            fixSuggestion = @"Ensure that the input data is aligned according to the PKCS5/7 padding standard.";
            break;
        case kPNCryptoInputDataProcessingError:
            
            fixSuggestion = @"The cryptor stumbled on an unknown error during input data processing.";
            break;
        case kPNCryptoUnavailableFeatureError:
            
            fixSuggestion = @"Looks like you tried to perform some operations which are not supported by the crypto "
                             "lib with the specified algorithm.";
            break;
        default:

            fixSuggestion = @"There are no known solutions.";
            break;
    }
    
    
    return fixSuggestion;
}

- (NSString *)description {

    return [NSString stringWithFormat:@"Domain=%@; Code=%ld; Description=\"%@\"; Reason=\"%@\"; Fix suggestion=\"%@\";"
                                              " Associated object=%@",
                                      self.domain,
                                      (long)self.code,
                                      [self localizedDescription],
                                      [self localizedFailureReason],
                                      [self localizedRecoverySuggestion],
                                      self.associatedObject];
}

- (NSString *)domainForError:(NSInteger)errorCode {
    
    NSString *domain = kPNDefaultErrorDomain;

    switch (errorCode) {

        case kPNPresenceAPINotAvailableError:
        case kPNInvalidJSONError:
        case kPNRestrictedCharacterInChannelNameError:

                domain = kPNServiceErrorDomain;
            break;
        default:
            break;
    }
    
    return domain;
}

#pragma mark -


@end
