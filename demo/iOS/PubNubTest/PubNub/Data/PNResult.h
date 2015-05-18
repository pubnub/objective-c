#import <Foundation/Foundation.h>
#import "PNRequest.h"


/**
 @brief      Class which is used to describe server response.
 @discussion This object contains response itself and also set of data which has been used to 
             communicate with \b PubNub service to get this response.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface PNResult : NSObject


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief Represent type of operation which has been issued to \b PubNub service and received
        response stored in \c response and processed response in \c data.

 @since 4.0
 */
@property (nonatomic, readonly) PNOperationType operation;

/**
 @brief Stores reference on copy of original request which has been used to fetch or push data
        to \b PubNub service.
 
 @since 4.0
 */
@property (nonatomic, readonly, copy) NSURLRequest *request;

/**
 @brief Stores reference on original response body which hasn't been transformed yet.

 @since 4.0
 */
@property (nonatomic, readonly, copy) NSString *response;

/**
 @brief Stores reference on \b PubNub service host name or IP address against which \c request
 has been called.
 
 @since 4.0
 */
@property (nonatomic, readonly, copy) NSString *origin;

/**
 @brief Stores HTTP status code with which \c request completed processing with \b PubNub
        service.
 
 @since 4.0
 */
@property (nonatomic, readonly) NSInteger statusCode;

/**
 @brief      Stores reference on processed \c response which is ready to use by user.
 @discussion Content and format for this property different for API. Each method has description
             about expected fields and data stored inside.
 
 @since 4.0
 */
@property (nonatomic, readonly, copy) id data;

#pragma mark -


@end
