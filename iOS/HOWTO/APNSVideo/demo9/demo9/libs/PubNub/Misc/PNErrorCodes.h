//
//  PNErrorCodes.h
//  pubnub
//
//  Describes all available error codes
//
//
//  Created by Sergey Mamontov on 12/5/12.
//
//


#pragma mark - Client error codes

// Unknown error
static NSInteger const kPNUnknownError = -1;

// PubNub client find out that it wasn't fully
// configured and can't process his work
static NSInteger const kPNClientConfigurationError = 100;

// PubNub client tried to connect while it already
// has opened connection to PubNub services
static NSInteger const kPNClientTriedConnectWhileConnectedError = 101;

// PubNub client failed to connect to PubNub services
// because internet went down
static NSInteger const kPNClientConnectionFailedOnInternetFailureError = 102;

// PubNub client disconnected because of network issues
static NSInteger const kPNClientConnectionClosedOnInternetFailureError = 103;

// PubNub client failed to execute request because there is
// no connection which can be used to reach PubNub services
static NSInteger const kPNRequestExecutionFailedOnInternetFailureError = 104;

// PubNub client failed to execute request because of client
// not ready
static NSInteger const kPNRequestExecutionFailedClientNotReadyError = 105;

// PubNub client failed to execute request because of timeout
static NSInteger const kPNRequestExecutionFailedByTimeoutError = 106;

// PubNub client failed to use presence API because it
// is not enabled in used account
static NSInteger const kPNPresenceAPINotAvailableError = 107;

// PubNub service refuse to process request because it has
// wrong JSON format
static NSInteger const kPNInvalidJSONError = 108;

// PubNub service refuse to process request because it has
// wrong subscribe/publish key
static NSInteger const kPNInvalidSubscribeOrPublishKeyError = 109;

// PubNub service refuse to process message sending because
// it is too long
static NSInteger const kPNTooLongMessageError = 110;

// PubNub service reported that restricted characters has been
// used in channel name and request can't be processed
static NSInteger const kPNRestrictedCharacterInChannelNameError = 111;

// PubNub service reported that there is no authorization key specified
// and resource not available w/o it
static NSInteger const kPNAPIUnauthorizedAccessError = 112;

// PubNub service reported that wrong authorization has been
// used for request
static NSInteger const kPNAPIAccessForbiddenError = 113;


#pragma mark - Cryptography error

// Developer tried to initalize Cryptor helper with configuraiton
// which doesn't has cipher key in it
static NSInteger const kPNCryptoEmptyCipherKeyError = 114;

// Error occured during cryptor initialization because of error
// in provided paramteres
static NSInteger const kPNCryptoIllegalInitializationParametersError = 115;

// Error occured because buffer with insufficient size was
// provided for encrypted/decrypted data output
static NSInteger const kPNCryptoInsufficentBufferSizeError = 116;

// Error occure in case if during cryptor operation there was not enough
// memory for it's operation
static NSInteger const kPNCryptoInsufficentMemoryError = 117;

// Error occured because input data wasn't properly alligned
static NSInteger const kPNCryptoAligmentInputDataError = 118;

// Error occured during input data encode/decode process
static NSInteger const kPNCryptoInputDataProcessingError = 119;

// Error occure if developer try to use one of features which is not
// available in specified algorithm
static NSInteger const kPNCryptoUnavailableFeatureError = 120;



#pragma mark - Developers error (caused by developer)

// Developer tries to submit empty (nil) request by passing
// no message object to PubNub service
static NSInteger const kPNMessageObjectError = 121;

// Developer tried to submit message w/o text to PubNub service
static NSInteger const kPNMessageHasNoContentError = 122;

// Developer tried to submit message w/o target channel to
// PubNub service
static NSInteger const kPNMessageHasNoChannelError = 123;

// Developer tried to use APNS API w/o enabling push notifications
// support on admin.punub.com
static NSInteger const kPNPushNotificationsNotEnabledError = 124;


#pragma mark - Service error (caused by remote server)

// Server provided response which can't be decoded with UTF8
static NSInteger const kPNResponseEncodingError = 125;

// Server provided response with malformed JSON in it
// (in such casses library will try to resend request to
// remote origin)
static NSInteger const kPNResponseMalformedJSONError = 126;


#pragma mark - Connection (transport layer) error codes

// Was unable to configure connection because of some
// errors
static NSInteger const kPNConnectionErrorOnSetup = 127;