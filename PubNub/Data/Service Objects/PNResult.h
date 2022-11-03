#import <Foundation/Foundation.h>
#import "PNStructures.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Class which is used to describe server response.
 *
 * @discussion This object contains response itself and also set of data which has been used to communicate with
 *     \b PubNub service to get this response.
 *
 * @author Sergey Mamontov
 * @version 5.2.0
 * @since 4.0.0
 * @copyright © 2010-2022 PubNub, Inc.
 */
@interface PNResult: NSObject


#pragma mark Information

/**
 * @brief Stores HTTP status code with which \c request completed processing with \b PubNub service.
 */
@property (nonatomic, readonly, assign) NSInteger statusCode;

/**
 * @brief Represent type of operation which has been issued to \b PubNub service and received response stored in
 *        \c response and processed response in \c data.
 */
@property (nonatomic, readonly, assign) PNOperationType operation;

/**
 * @brief Stores whether secured connection has been used to send request or not.
 */
@property (nonatomic, readonly, assign, getter = isTLSEnabled) BOOL TLSEnabled;

/**
 * @brief The unique identifier to be used as a device identifier.
 */
@property (nonatomic, readonly, copy) NSString *uuid DEPRECATED_MSG_ATTRIBUTE("use 'userId' instead.");

/**
 * @brief The unique identifier to be used as a device identifier.
 *
 * @since 5.2.0
 */
@property (nonatomic, readonly, copy) NSString *userId;

/**
 * @brief Authorization key / token which is used to get access to protected remote resources.
 *
 * @discussion Some resources can be protected by \b PAM functionality and access done using this authorization
 *             key.
 */
@property (nonatomic, nullable, readonly, copy) NSString *authKey;

/**
 * @brief Stores reference on \b PubNub service host name or IP address against which \c request has been
 *        called.
 */
@property (nonatomic, readonly, copy) NSString *origin;

/**
 * @brief Stores reference on copy of original request which has been used to fetch or push data to \b PubNub
 *        service.
 */
@property (nonatomic, nullable, readonly, copy) NSURLRequest *clientRequest;

/**
 * @brief Stringified \c operation value.
 *
 * @return Stringified representation for \c operation property which store value from \b PNOperationType.
 */
- (NSString *)stringifiedOperation;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
