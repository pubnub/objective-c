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
                
                errorDescription = @"Incomplete PubNub client configuration. Make sure you set the configuration correctly.";
                break;
            case kPNClientTriedConnectWhileConnectedError:
                
                errorDescription = @"PubNub client already connected to origin";
                break;
            case kPNClientConnectionFailedOnInternetFailureError:
            case kPNClientConnectionClosedOnSSLNegotiationFailureError:
                
                errorDescription = @"PubNub client connection failed";
                break;
            case kPNClientConnectionClosedOnInternetFailureError:

                errorDescription = @"PubNub client connection lost connection";
                break;
            case kPNRequestExecutionFailedOnInternetFailureError:
            case kPNRequestExecutionFailedClientNotReadyError:
                
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
                
                errorDescription = @"Wrong buffer size";
                break;
            case kPNCryptoInsufficentMemoryError:
                
                errorDescription = @"Insufficient memory";
                break;
            case kPNCryptoAligmentInputDataError:
                
                errorDescription = @"Input data error";
                break;
            case kPNCryptoInputDataProcessingError:
                
                errorDescription = @"Input data processing error";
                break;
            case kPNCryptoUnavailableFeatureError:
                
                errorDescription = @"Not implemented";
                break;
            default:

                errorDescription = @"Unknown error.";
                break;
        }
    }
    
    
    return errorDescription;
}

- (NSString *)localizedFailureReason {
    
    NSString *failureReason = nil;
    
    switch (self.code) {
            
        case kPNClientConfigurationError:
            
            failureReason = @"One of required configuration field is empty:\n- publish key\n- subscribe key\n- secret key";
            break;
        case kPNClientTriedConnectWhileConnectedError:
            
            failureReason = @"Looks like client tried to connecte to remote PubNub service while already has connection";
            break;
        case kPNClientConnectionFailedOnInternetFailureError:
            
            failureReason = @"Looks like client lost connection while trying to connect to remote PubNub service";
            break;
        case kPNClientConnectionClosedOnSSLNegotiationFailureError:

            failureReason = @"Looks like client was unable to connect to remote PubNub services becuase of security issues (SSL)";
            break;
        case kPNRequestExecutionFailedOnInternetFailureError:
        case kPNClientConnectionClosedOnInternetFailureError:
            
            failureReason = @"Looks like client lost connection";
            break;
        case kPNRequestExecutionFailedByTimeoutError:

            failureReason = @"Looks like there is some packets lost because of which request failed by timeout";
            break;
        case kPNConnectionErrorOnSetup:
            
            failureReason = @"Connection can't be opened becuase of errors in configuration";
            break;
        case kPNRequestExecutionFailedClientNotReadyError:

            failureReason = @"Looks like client is not connected to PubNub service";
            break;
        case kPNPresenceAPINotAvailableError:

            failureReason = @"Looks like presence API access not enabled";
            break;
        case kPNInvalidJSONError:

            failureReason = @"Looks like one of requests tried to send malformed JSON or message hase been changed after signature was generated";
            break;
        case kPNInvalidSubscribeOrPublishKeyError:

            failureReason = @"Looks like one of subscribe or publish key is wrong";
            break;
        case kPNRestrictedCharacterInChannelNameError:

            failureReason = @"Looks like one of reqests used restricted characters in channel name";
            break;
        case kPNAPIUnauthorizedAccessError:

            failureReason = @"Looks like API required 'auth' key";
            break;
        case kPNAPIAccessForbiddenError:

            failureReason = @"Looks like specified wrong 'auth' key or you don't have permissions";
            break;
        case kPNMessageHasNoContentError:

            failureReason = @"Looks like message has empty body or doesnt have it at all";
            break;
        case kPNMessageHasNoChannelError:

            failureReason = @"Looks like target channel for message not specified";
            break;
        case kPNMessageObjectError:

            failureReason = @"Looks like there is no message object has been passed";
            break;
        case kPNTooLongMessageError:

            failureReason = @"Looks like message is too large and can't be processed";
            break;
        case kPNPushNotificationsNotEnabledError:

            failureReason = @"Looks like push notifications wasn't enabled for current subscribe key on PubNub admin console";
            break;
        case kPNDevicePushTokenIsEmptyError:
            
            failureReason = @"Looks like device push notification is nil";
            break;
        case kPNResponseEncodingError:

            failureReason = @"Looks like remote service send message with encoding which is other than UTF8";
            break;
        case kPNResponseMalformedJSONError:

            failureReason = @"Looks like remote service send response with malformed JSON in it (maybe truncated)";
            break;
        case kPNCryptoEmptyCipherKeyError:
            
            failureReason = @"Looks like there is no cipher key in configuration instance which was used for client configuration";
            break;
        case kPNCryptoIllegalInitializationParametersError:
            
            failureReason = @"Looks like some illegal parameter values has been used during cryptor initialization";
            break;
        case kPNCryptoInsufficentBufferSizeError:
            
            failureReason = @"Looks like output buffer with insufficient type has been specified";
            break;
        case kPNCryptoInsufficentMemoryError:
            
            failureReason = @"Looks like there is not enough memory for Crypto helper operation completion";
            break;
        case kPNCryptoAligmentInputDataError:
            
            failureReason = @"Looks like input data not aligned properly";
            break;
        case kPNCryptoInputDataProcessingError:
            
            failureReason = @"Crypto helper failed to process input data because of unknown error";
            break;
        case kPNCryptoUnavailableFeatureError:
            
            failureReason = @"Looks like someone tried to use feature which is not available for specified algorythm";
            break;
        default:

            failureReason = @"Unknown error reason.";
            break;
    }
    
    
    return failureReason;
}

- (NSString *)localizedRecoverySuggestion {
    
    NSString *fixSuggestion = nil;
    
    switch (self.code) {
            
        case kPNClientConfigurationError:
            
            fixSuggestion = @"Ensure that you specified all required keys while creating PNConfiguration instance or all values specified in PNDefaultConfiguration.h. You can always visit https://admin.pubnub.comto get all required keys for PubNub client";
            break;
        case kPNClientTriedConnectWhileConnectedError:
            
            fixSuggestion = @"If it is required to reconnect PubNub client, close connection first and then try connect again";
            break;
        case kPNClientConnectionFailedOnInternetFailureError:
        case kPNRequestExecutionFailedOnInternetFailureError:
            
            fixSuggestion = @"Ensure that all network configuration (including proxy if there is) is correct and try again";
            break;
        case kPNClientConnectionClosedOnSSLNegotiationFailureError:

            fixSuggestion = @"Ensure that all network configuration (including proxy if there is) is correct and try again. If this issue still persist, please contact with support team at support@pubnub.com to ask them investigate issue with SSL certificates on servers.";
            break;
        case kPNConnectionErrorOnSetup:
            
            fixSuggestion = @"Check whether client was configured to use secure connection and whether remote origin has valid certificate.\nIf remote origin doesn't provide correct SSL certificate, you can set kPNShouldReduceSecurityLevelOnError to YES in PNDefaultConfiguration.h or provide YES when initializing PNConfiguration instance.";
            break;
        case kPNRequestExecutionFailedClientNotReadyError:

            fixSuggestion = @"Ensure that PubNub client connected to the PubNub service and try again.";
            break;
        case kPNRequestExecutionFailedByTimeoutError:

            fixSuggestion = @"Try send request again later.";
            break;
        case kPNPresenceAPINotAvailableError:

            fixSuggestion = @"Please visit https://admin.pubnub.com and enable presence API feature and try again.";
            break;
        case kPNInvalidJSONError:

            fixSuggestion = @"Review all JSON request which is sent for processing to the PubNub services. Ensure that you don't try to change message while request is prepared.";
            break;
        case kPNInvalidSubscribeOrPublishKeyError:

            fixSuggestion = @"Review request and ensure that correct publish or(and) subscribe key was specified in it";
            break;
        case kPNRestrictedCharacterInChannelNameError:

            fixSuggestion = @"Ensure that you don't use in channel name next characters: ','";
            break;
        case kPNAPIUnauthorizedAccessError:

            fixSuggestion = @"Specify 'authorizationKey' for configuration instance used to setup PubNub client";
            break;
        case kPNAPIAccessForbiddenError:

            fixSuggestion = @"Ensure that you specified correct 'authorizationKey'. If key is correct, than access denied with ULS.";
            break;
        case kPNMessageHasNoContentError:

            fixSuggestion = @"Ensure that you are not sending empty message (maybe there only spaces in it).";
            break;
        case kPNMessageHasNoChannelError:

            fixSuggestion = @"Ensure that you specified valid channel as message target";
            break;
        case kPNTooLongMessageError:

            fixSuggestion = @"Please visit https://admin.pubnub.com and change maximum message size.";
            break;
        case kPNPushNotificationsNotEnabledError:

            fixSuggestion = @"Please visit https://admin.pubnub.com and enable push notifications feature.";
            break;
        case kPNDevicePushTokenIsEmptyError:
            
            fixSuggestion = @"Ensure that you provided correct non nil device push token";
            break;
        case kPNMessageObjectError:

            fixSuggestion = @"Ensure that you provide correct message object to be used for sending request";
            break;
        case kPNResponseEncodingError:

            fixSuggestion = @"Ensure that you use UTF8 character table to send messages to the PubNub service";
            break;
        case kPNResponseMalformedJSONError:

            fixSuggestion = @"Try resend request which caused this error";
            break;
        case kPNCryptoEmptyCipherKeyError:
            
            fixSuggestion = @"Please check client configuration instance and ensure that key is specified or don't try to initialize helper if there is no key supplied.";
            break;
        case kPNCryptoIllegalInitializationParametersError:
            
            fixSuggestion = @"Ensure that correct parameters has been passed to cryptor creation functions.";
            break;
        case kPNCryptoInsufficentBufferSizeError:
            
            fixSuggestion = @"Ensure that buffer with correct amount of space has been specified and provided for cryptor";
            break;
        case kPNCryptoInsufficentMemoryError:
            
            fixSuggestion = @"Looks like cryptor is run out of memory during his last operation. Try to separate input data in chunks and process them one by one if possible.";
            break;
        case kPNCryptoAligmentInputDataError:
            
            fixSuggestion = @"Ensure that input data is alligned according to PKCS5/7 padding.";
            break;
        case kPNCryptoInputDataProcessingError:
            
            fixSuggestion = @"Cryptor stumbled on unknown error during input data processing.";
            break;
        case kPNCryptoUnavailableFeatureError:
            
            fixSuggestion = @"Looks like you tried to perform some operation which is not supported by cryptor with specified algorythm.";
            break;
        default:

            fixSuggestion = @"There is no known solutions.";
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
