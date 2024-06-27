#import <Foundation/Foundation.h>
#import <PubNub/PNStructures.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// General operation (request or client generated) result object.
///
/// Object contain information about type of operation and its outcome (processed data object).
@interface PNOperationResult: NSObject


#pragma mark - Properties

/// Stringify request operation type.
///
/// Stringify request `operation` field (one of the `PNOperationType` enum).
@property(strong, nonatomic, readonly) NSString *stringifiedOperation;

/// Type of operation for which result object has been created.
@property(assign, nonatomic, readonly) PNOperationType operation;


#pragma mark - Properties (deprecated)

/// Whether secured connection has been used to send request or not.
@property(assign, nonatomic, readonly, getter = isTLSEnabled) BOOL TLSEnabled
    DEPRECATED_MSG_ATTRIBUTE("This property deprecated and will be removed with the next major update. The actual value"
                             " can be retrieved from the client configuration object (`PNConfiguration`).");

/// Copy of the original request which has been used to fetch or push data to **PubNub** network.
///
/// > Important: This information not available anymore because property has been deprecated.
@property (copy, nonatomic, nullable, readonly) NSURLRequest *clientRequest
    DEPRECATED_MSG_ATTRIBUTE("This property deprecated and will be removed with the next major update.");

/// Authorisation key / token which is used to get access to protected remote resources.
///
/// Some resources can be protected by **PAM** functionality and access done using this authorisation key.
@property (copy, nonatomic, nullable, readonly) NSString *authKey
    DEPRECATED_MSG_ATTRIBUTE("This property deprecated and will be removed with the next major update. The actual value"
                             " can be retrieved from the client configuration object (`PNConfiguration`).");

/// **PubNub** network host name or IP address against which `request` has been called.
@property (copy, nullable, nonatomic, readonly) NSString *origin
    DEPRECATED_MSG_ATTRIBUTE("This property deprecated and will be removed with the next major update. The actual value"
                             " can be retrieved from the client configuration object (`PNConfiguration`).");

/// UUID which is currently used by client to identify user in **PubNub** network.
@property(copy, nullable, nonatomic, readonly) NSString *userID
    DEPRECATED_MSG_ATTRIBUTE("This property deprecated and will be removed with the next major update. The actual value"
                             " can be retrieved from the client configuration object (`PNConfiguration`).");

/// UUID which is currently used by client to identify user in **PubNub** network.
@property(copy, nullable, nonatomic, readonly) NSString *uuid
    DEPRECATED_MSG_ATTRIBUTE("This property deprecated and will be removed with the next major update. The actual value"
                             " can be retrieved from the client configuration object (`PNConfiguration`).");

/// HTTP status code with which `request` completed processing with **PubNub** service.
@property(assign, nonatomic, readonly) NSInteger statusCode
    DEPRECATED_MSG_ATTRIBUTE("This property deprecated and will be removed with the next major update. ");

#pragma mark -


@end

NS_ASSUME_NONNULL_END
