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

// PubNub client find out that it wasn't fully configured and can't process his work
static NSInteger const kPNClientConfigurationError = 100;

// PubNub client tried to connect while it already has opened connection to PubNub services
static NSInteger const kPNClientTriedConnectWhileConnectedError = 101;

// PubNub client failed to connect to PubNub services because internet went down
static NSInteger const kPNClientConnectionFailedOnInternetFailureError = 102;

// PubNub client disconnected because of network issues
static NSInteger const kPNClientConnectionClosedOnInternetFailureError = 103;

// PubNub client disconnected because of SSL issues
static NSInteger const kPNClientConnectionClosedOnSSLNegotiationFailureError = 104;

// PubNub client disconnected because of server request (connection refure/reset)
static NSInteger const kPNClientConnectionClosedOnServerRequestError = 105;

// PubNub client disconnected because system wasn't able to initalize and support connection sockets
static NSInteger const kPNClientConnectionClosedOnSocketsError = 106;

// PubNub client failed to execute request because there is no connection which can be used to reach PubNub services
static NSInteger const kPNRequestExecutionFailedOnInternetFailureError = 107;

// PubNub client failed to execute request because of client not ready
static NSInteger const kPNRequestExecutionFailedClientNotReadyError = 108;

// PubNub client failed to execute request because of client suspended
static NSInteger const kPNRequestExecutionFailedClientSuspendedError = 109;

// PubNub client failed to execute request because of timeout
static NSInteger const kPNRequestExecutionFailedByTimeoutError = 110;

// PubNub client failed to use presence API because it is not enabled in used account
static NSInteger const kPNPresenceAPINotAvailableError = 111;

// PubNub service refuse to process request because it has wrong JSON format
static NSInteger const kPNInvalidJSONError = 112;

// PubNub service refuse to process request because it has wrong subscribe/publish key
static NSInteger const kPNInvalidSubscribeOrPublishKeyError = 113;

// PubNub service refuse to process message sending because it is too long
static NSInteger const kPNTooLongMessageError = 114;

// PubNub service reported that restricted characters has been used in channel name and request can't be processed
static NSInteger const kPNRestrictedCharacterInChannelNameError = 115;

// PubNub service reported that there is no authorization key specified and resource not available w/o it
static NSInteger const kPNAPIUnauthorizedAccessError = 116;

// PubNub service reported that wrong authorization has been used for request
static NSInteger const kPNAPIAccessForbiddenError = 117;


#pragma mark - Cryptography error

// Developer tried to initialize Cryptor helper with configuration which doesn't has cipher key in it
static NSInteger const kPNCryptoEmptyCipherKeyError = 118;

// Error occurred during cryptor initialization because of error in provided parameters
static NSInteger const kPNCryptoIllegalInitializationParametersError = 119;

// Error occurred because buffer with insufficient size was provided for encrypted/decrypted data output
static NSInteger const kPNCryptoInsufficentBufferSizeError = 120;

// Error occurred in case if during cryptor operation there was not enough memory for it's operation
static NSInteger const kPNCryptoInsufficentMemoryError = 121;

// Error occurred because input data wasn't properly aligned
static NSInteger const kPNCryptoAligmentInputDataError = 122;

// Error occurred during input data encode/decode process
static NSInteger const kPNCryptoInputDataProcessingError = 123;

// Error occurred if developer try to use one of features which is not available in specified algorithm
static NSInteger const kPNCryptoUnavailableFeatureError = 124;



#pragma mark - Developers error (caused by developer)

// Developer tries to submit empty (nil) request by passing no message object to PubNub service
static NSInteger const kPNMessageObjectError = 125;

// Developer tried to submit message w/o text to PubNub service
static NSInteger const kPNMessageHasNoContentError = 126;

// Developer tried to submit message w/o target channel to PubNub service
static NSInteger const kPNMessageHasNoChannelError = 127;

// Developer tried to use APNS API w/o enabling push notifications support on admin.punub.com
static NSInteger const kPNPushNotificationsNotEnabledError = 128;

// Developer tried to use empty device push notification to enable push notification on specified channel
static NSInteger const kPNDevicePushTokenIsEmptyError = 129;


#pragma mark - Service error (caused by remote server)

// Server provided response which can't be decoded with UTF8
static NSInteger const kPNResponseEncodingError = 130;

// Server provided response with malformed JSON in it (in such cases library will try to resend request to
// remote origin)
static NSInteger const kPNResponseMalformedJSONError = 131;


#pragma mark - Connection (transport layer) error codes

// Was unable to configure connection because of some errors
static NSInteger const kPNConnectionErrorOnSetup = 132;
