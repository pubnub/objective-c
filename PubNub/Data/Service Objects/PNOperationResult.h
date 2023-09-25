#import <Foundation/Foundation.h>
#import <PubNub/PNStructures.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Server response representation object.
///
/// This object contains response itself and also set of data which has been used to communicate with **PubNub** service
/// to get this response.
///
/// - Since: 4.0.0
/// - Copyright: 2010-2023 PubNub, Inc.
@interface PNOperationResult: NSObject


#pragma mark - Information

/// HTTP status code with which `request` completed processing with **PubNub** service.
@property (nonatomic, readonly, assign) NSInteger statusCode;

/// Represent type of operation which has been issued to **PubNub** service and received response stored in `response`
/// and processed response in `data`.
@property (nonatomic, readonly, assign) PNOperationType operation;

/// Whether secured connection has been used to send request or not.
@property (nonatomic, readonly, assign, getter = isTLSEnabled) BOOL TLSEnabled;

/// UUID which is currently used by client to identify user in **PubNub** network.
@property (nonatomic, readonly, copy) NSString *uuid
    DEPRECATED_MSG_ATTRIBUTE("This property deprecated and will be removed with next major update. Please use `userID` "
                             "instead.");

/// UUID which is currently used by client to identify user in **PubNub** network.
@property (nonatomic, readonly, copy) NSString *userID;

/// Authorisation key / token which is used to get access to protected remote resources.
///
/// Some resources can be protected by **PAM** functionality and access done using this authorisation key.
@property (nonatomic, nullable, readonly, copy) NSString *authKey;

/// **PubNub** network host name or IP address against which `request` has been called.
@property (nonatomic, readonly, copy) NSString *origin;

/// Copy of the original request which has been used to fetch or push data to **PubNub** network.
@property (nonatomic, nullable, readonly, copy) NSURLRequest *clientRequest;

/// Stringify operation value.
///
/// - Returns: Stringified representation for `operation` property which store value from the `PNOperationType` enum.
- (NSString *)stringifiedOperation;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
