#import <Foundation/Foundation.h>


#ifndef PNErrorConstants_h
#define PNErrorConstants_h

#pragma mark Error domains

/// Transport error domain.
///
/// This domain dedicated to the errors which happen when transport implementation handles transport request and error.
///
/// > Note: Error instances may include additional information in `userInfo` for ``PNTransportRequestKey`` and
/// ``PNTransportResponseKey`` data keys.
static NSString * const PNTransportErrorDomain = @"PNTransportErrorDomain";

/// API error domain.
///
/// This domain dedicated to the errors which happen during interaction with the public **PubNub** client interface.
static NSString * const PNAPIErrorDomain = @"PNAPIErrorDomain";

/// API error domain.
///
/// This domain dedicated to the errors which happen during interaction with the public **PubNub** client interface.
static NSString * const kPNAPIErrorDomain
    DEPRECATED_MSG_ATTRIBUTE("Please use 'PNAPIErrorDomain' instead") = PNAPIErrorDomain;

/// Auth error domain.
///
/// This domain dedicated to the errors which happen during access token processing.
static NSString * const PNAuthErrorDomain = @"PNAuthErrorDomain";

/// Auth error domain.
///
/// This domain dedicated to the errors which happen during access token processing.
static NSString * const kPNAuthErrorDomain
    DEPRECATED_MSG_ATTRIBUTE("Please use 'PNAuthErrorDomain' instead") = PNAuthErrorDomain;

/// Crypto module error domain.
///
/// This domain dedicated to the errors which happen during data encryption / decryption.
static NSString * const PNCryptorErrorDomain = @"PNCryptorErrorDomain";

/// Crypto module error domain.
///
/// This domain dedicated to the errors which happen during data encryption / decryption.
static NSString * const kPNAESErrorDomain
    DEPRECATED_MSG_ATTRIBUTE("Please use 'PNCryptorErrorDomain' instead") = PNCryptorErrorDomain;

/// Crypto module error domain.
///
/// This domain dedicated to the errors which happen during data encryption / decryption.
static NSString * const kPNCryptorErrorDomain
    DEPRECATED_MSG_ATTRIBUTE("Please use 'PNCryptorErrorDomain' instead") = PNCryptorErrorDomain;

/// File sharing error domain.
///
/// This domain dedicated to the errors which happen during interaction with external files storage.
static NSString * const PNStorageErrorDomain = @"PNStorageErrorDomain";

/// File sharing error domain.
///
/// This domain dedicated to the errors which happen during interaction with external files storage.
static NSString * const kPNStorageErrorDomain
    DEPRECATED_MSG_ATTRIBUTE("Please use 'PNStorageErrorDomain' instead") = PNStorageErrorDomain;

/// CBOR module error domain.
///
/// This domain dedicated to the errors which happen during access token parsing.
static NSString * const PNCBORErrorDomain = @"PNCBORErrorDomain";

/// CBOR module error domain.
///
/// This domain dedicated to the errors which happen during access token parsing.
static NSString * const kPNCBORErrorDomain
    DEPRECATED_MSG_ATTRIBUTE("Please use 'PNCBORErrorDomain' instead") = PNCBORErrorDomain;

/// JSON serializer error domain.
///
/// This domain dedicated to errors signalled by ``PubNub/PNJSONSerialization``.
static NSString * const PNJSONSerializationErrorDomain = @"PNJSONSerializationErrorDomain";

/// Object encoder error domain.
///
/// This domain dedicated to errors signalled by `PNJSONEncoder`.
static NSString * const PNJSONEncoderErrorDomain = @"PNJSONEncoderErrorDomain";

/// Object decoder error domain.
///
/// This domain dedicated to errors signalled by `PNJSONDecoder`.
static NSString * const PNJSONDecoderErrorDomain = @"PNJSONDecoderErrorDomain";


#pragma mark - Error codes

/// Not categorized error.
///
/// **PubNub** client wasn't able to categorize the error, or it wasn't identified at the client release time.
static NSInteger const PNErrorUnknown = -1;

/// Not categorized error.
///
/// **PubNub** client wasn't able to categorize the error, or it wasn't identified at the client release time.
static NSInteger const kPNUnknownErrorCode
    DEPRECATED_MSG_ATTRIBUTE("Please use 'PNErrorUnknown' instead") = PNErrorUnknown;


#pragma mark - Transport error codes

/// Request sending failed because of time out.
///
/// Very slow connection when request doesn't have enough time to complete processing (send request body and receive
/// server response).
static NSInteger const PNTransportErrorRequestTimeout = 1000;

/// Request has been cancelled before receiving response.
///
/// Cancellation possible only for connection based operations (subscribe / leave).
static NSInteger const PNTransportErrorRequestCancelled = 1001;

/// Request can't be processed because of network issues.
///
/// Reasons could be:
/// - unable to connect to the remote origin
/// - DNS lookup issues
/// - TLS handshake issues
///
/// > Note: Localized error reason description should provide more information about exact reason.
static NSInteger const PNTransportErrorNetworkIssues = 1002;


#pragma mark - API error codes

/// Incomplete or unacceptable set of parameters.
///
/// Unable to call endpoint because of incomplete or unacceptable parameters.
static NSInteger const PNAPIErrorUnacceptableParameters = 1100;

/// Incomplete or unacceptable set of parameters.
///
/// Unable to call endpoint because of incomplete or unacceptable parameters.
static NSInteger const kPNAPIUnacceptableParameters
    DEPRECATED_MSG_ATTRIBUTE("Please use 'PNAPIErrorUnacceptableParameters' instead") = PNAPIErrorUnacceptableParameters;

/// API not enabled.
///
/// Unable to access remote resource because feature not enabled.
static NSInteger const PNAPIErrorFeatureNotEnabled = 1101;

/// Access denied to the remote resource.
///
/// Remote resource may require additional request configuration to pass permissions' validation.
static NSInteger const PNAPIErrorAccessDenied = 1102;

/// Remote origin unable to process request.
///
/// Verify request arguments and payload content.
static NSInteger const PNAPIErrorBadRequest = 1103;

/// Unable to send request because path is too long.
static NSInteger const PNAPIErrorRequestURITooLong = 1104;

/// Malformed service response.
///
/// Received unexpected service response.
static NSInteger const PNAPIErrorMalformedServiceResponse = 1105;

/// Malformed subscribe filter expression.
static NSInteger const PNAPIErrorMalformedFilterExpression = 1106;


#pragma mark - Storage error codes

/// Shared file storage access issue.
static NSInteger const PNStorageErrorAccess = 1200;



#pragma mark - Auth error codes

/// Auth token expired.
static NSInteger const PNAuthErrorPAMTokenExpired = 1300;

/// Auth token expired.
static NSInteger const kPNAuthPAMTokenExpiredError
    DEPRECATED_MSG_ATTRIBUTE("Please use 'PNAuthErrorPAMTokenExpired' instead") = PNAuthErrorPAMTokenExpired;

/// Auth token's UUID doesn't match `uuid` used by **PubNub** instance.
static NSInteger const PNAuthErrorPAMTokenWrongUUID = 1301;

/// Auth token's UUID doesn't match `uuid` used by **PubNub** instance.
static NSInteger const kPNAuthPAMTokenWrongUUIDError
    DEPRECATED_MSG_ATTRIBUTE("Please use 'PNAuthErrorPAMTokenWrongUUID' instead") = PNAuthErrorPAMTokenWrongUUID;


#pragma mark -  Publish error codes

/// Attempt to publish empty message.
static NSInteger const kPNEmptyMessageError
    DEPRECATED_MSG_ATTRIBUTE("Please use 'PNAPIErrorUnacceptableParameters' instead") = PNAPIErrorUnacceptableParameters;


#pragma mark - Crypto module error codes

static NSInteger const kPNAESEmptyObjectError
    DEPRECATED_MSG_ATTRIBUTE("Please use 'CryptoModule' instead") = 1400;

/// Underlying cryptor module configuration error.
static NSInteger const PNCryptorErrorConfiguration = 1401;

/// Underlying cryptor module configuration error.
static NSInteger const kPNAESConfigurationError
    DEPRECATED_MSG_ATTRIBUTE("Please use 'PNCryptorErrorConfiguration' instead") = PNCryptorErrorConfiguration;

/// Underlying cryptor module configuration error.
static NSInteger const kPNCryptorConfigurationError
    DEPRECATED_MSG_ATTRIBUTE("Please use 'PNCryptorErrorConfiguration' instead") = PNCryptorErrorConfiguration;

/// Not enough memory to complete cryptor operation.
static NSInteger const PNCryptorErrorInsufficientMemory = 1402;

/// Not enough memory to complete cryptor operation.
static NSInteger const kPNAESInsufficientMemoryError
    DEPRECATED_MSG_ATTRIBUTE("Please use 'PNCryptorErrorInsufficientMemory' instead") = PNCryptorErrorInsufficientMemory;

/// Not enough memory to complete cryptor operation.
static NSInteger const kPNCryptorInsufficientMemoryError
    DEPRECATED_MSG_ATTRIBUTE("Please use 'PNCryptorErrorInsufficientMemory' instead") = PNCryptorErrorInsufficientMemory;

/// There were an error during data encryption process.
static NSInteger const PNCryptorErrorEncryption = 1403;

/// There were an error during data encryption process.
static NSInteger const kPNAESEncryptionError
    DEPRECATED_MSG_ATTRIBUTE("Please use 'PNCryptorErrorEncryption' instead") = PNCryptorErrorEncryption;

/// There were an error during data encryption process.
static NSInteger const kPNCryptorEncryptionError
    DEPRECATED_MSG_ATTRIBUTE("Please use 'PNCryptorErrorEncryption' instead") = PNCryptorErrorEncryption;

/// There were an error during data decryption process.
static NSInteger const PNCryptorErrorDecryption = 1404;

/// There were an error during data decryption process.
static NSInteger const kPNAESDecryptionError
    DEPRECATED_MSG_ATTRIBUTE("Please use 'PNCryptorErrorDecryption' instead") = PNCryptorErrorDecryption;

/// There were an error during data decryption process.
static NSInteger const kPNCryptorDecryptionError
    DEPRECATED_MSG_ATTRIBUTE("Please use 'PNCryptorErrorDecryption' instead") = PNCryptorErrorDecryption;

/// Unknown cryptor identifier error.
static NSInteger const PNCryptorErrorUnknownCryptor = 1405;

/// Unknown cryptor identifier error.
static NSInteger const kPNCryptorUnknownCryptorError
    DEPRECATED_MSG_ATTRIBUTE("Please use 'PNCryptorErrorUnknownCryptor' instead") = PNCryptorErrorUnknownCryptor;


#pragma mark - CBOR module error codes

/// Unexpected data type detected in CBOR data.
static NSInteger const PNCBORErrorUnexpectedDataType = 1500;

/// Unexpected data type detected in CBOR data.
static NSInteger const kPNCBORUnexpectedDataTypeError
    DEPRECATED_MSG_ATTRIBUTE("Please use 'PNCBORErrorUnexpectedDataType' instead") = PNCBORErrorUnexpectedDataType;

/// CBOR structure is malformed.
static NSInteger const PNCBORErrorMalformedData = 1501;

/// CBOR structure is malformed.
static NSInteger const kPNCBORMalformedDataError
    DEPRECATED_MSG_ATTRIBUTE("Please use 'PNCBORErrorMalformedData' instead") = PNCBORErrorMalformedData;

/// CBOR structure is malformed.
static NSInteger const PNCBORErrorDataItemNotWellFormed = 1502;

/// CBOR structure is malformed.
static NSInteger const kPNCBORDataItemNotWellFormedError
    DEPRECATED_MSG_ATTRIBUTE("Please use 'PNCBORErrorDataItemNotWellFormed' instead") = PNCBORErrorDataItemNotWellFormed;

/// Expected data item is missing from CBOR.
static NSInteger const PNCBORErrorMissingDataItem = 1503;

/// Expected data item is missing from CBOR.
static NSInteger const kPNCBORMissingDataItemError
    DEPRECATED_MSG_ATTRIBUTE("Please use 'PNCBORErrorMissingDataItem' instead") = PNCBORErrorMissingDataItem;


#pragma mark - JSON serializer error codes

/// Unable to serialize object of unsupported data type.
static NSInteger const PNJSONSerializationErrorType = 1600;

/// Unable to de-serialize object because of malformed JSON.
static NSInteger const PNJSONSerializationErrorMalformedJSON = 1601;


#pragma mark - JSON encoder / decoder error codes

/// Unable to encode object because ``PNCodable/codingKeys`` map has property not from instance property list.
static NSInteger const PNJSONEncodingErrorPropertyNotFound = 1700;

/// Unable encode object, because one of fields has unsupported data type.
static NSInteger const PNJSONEncodingErrorType = 1701;

/// No associated data exception.
///
/// The decoder tried to decode data for provided string `key`, but there was no data associated with it.
static NSInteger const PNJSONDecodingErrorKeyNotFound = 1702;

/// Associated data is `nil`.
///
/// The decoder tried to decode data for provided string `key`, but `nil` associated with it.
static NSInteger const PNJSONDecodingErrorValueNotFound = 1803;

/// Unable to decode data as requested type.
///
/// The decoder tries to decode data as specified type, but encoded data can't be restored to specified type.
static NSInteger const PNJSONDecodingErrorTypeMismatch = 1804;

/// Requested decoding operation is invalid.
///
/// Requested decoding operation is not valid in current context.
static NSInteger const PNJSONDecodingErrorInvalid = 1805;

/// `nil` or empty `NSData` instance passed to decoder.
static NSInteger const PNJSONDecodingErrorEmptyData = 1806;

/// Unable to decode object because of malformed or incomplete JSON data.
static NSInteger const PNJSONDecodingErrorMalformedJSONData = 1807;

/// Unable to decode object because without data object (de-serialized JSON).
static NSInteger const PNJSONDecodingErrorMissingData = 1808;


#pragma mark - Data keys

/// Response for failed `PNTransportRequest`.
///
/// Key is used to store object which implements `PNTransportResponse` protocol and contain error details.
static NSString * const PNTransportResponseKey = @"PNTransportResponseKey";

/// Failed `PNTransportRequest`.
///
/// Key is used to store `PNTransportRequest` object for which transport layer or remote origin returned error.
static NSString * const PNTransportRequestKey = @"PNTransportRequestKey";
#endif // PNErrorConstants_h


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Interface declaration

/// Information about **PubNub** client error.
///
/// **PubNub** client modules can signal an error by returning an `PNError` object by reference. Object will provide 
/// additional information about the kind of error and underlying cause.
@interface PNError : NSError


#pragma mark -


@end

NS_ASSUME_NONNULL_END
