#import <Foundation/Foundation.h>
#import "PNStructures.h"


NS_ASSUME_NONNULL_BEGIN

/**
 @brief      Class which is used to describe server response.
 @discussion This object contains response itself and also set of data which has been used to communicate with
             \b PubNub service to get this response.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
@interface PNResult: NSObject


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief Stores HTTP status code with which \c request completed processing with \b PubNub service.
 
 @since 4.0
 */
@property (nonatomic, readonly, assign) NSInteger statusCode;

/**
 @brief Represent type of operation which has been issued to \b PubNub service and received response stored in
        \c response and processed response in \c data.

 @since 4.0
 */
@property (nonatomic, readonly, assign) PNOperationType operation;

/**
 @brief  Stores whether secured connection has been used to send request or not.
 
 @since 4.0
 */
@property (nonatomic, readonly, assign, getter = isTLSEnabled) BOOL TLSEnabled;

/**
 @brief  UUID which is currently used by client to identify user on \b PubNub service.
 
 @since 4.0
 */
@property (nonatomic, readonly, copy) NSString *uuid;

/**
 @brief      Authorization which is used to get access to protected remote resources.
 @discussion Some resources can be protected by \b PAM functionality and access done using this authorization 
             key.
 
 @since 4.0
 */
@property (nonatomic, nullable, readonly, copy) NSString *authKey;

/**
 @brief Stores reference on \b PubNub service host name or IP address against which \c request has been 
        called.
 
 @since 4.0
 */
@property (nonatomic, readonly, copy) NSString *origin;

/**
 @brief Stores reference on copy of original request which has been used to fetch or push data to \b PubNub 
        service.
 
 @since 4.0
 */
@property (nonatomic, nullable, readonly, copy) NSURLRequest *clientRequest;

/**
 @brief  Stringified \c operation value.
 
 @return Stringified representation for \c operation property which store value from \b PNOperationType.
 */
- (NSString *)stringifiedOperation;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
