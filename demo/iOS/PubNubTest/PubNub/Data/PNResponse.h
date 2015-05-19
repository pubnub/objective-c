#import <Foundation/Foundation.h>


/**
 @brief      Transitional request processing results storage.
 @discussion This class used to wrap all data passed by NSURL loading system as result of request
             processing. Instance stored within \b PNRequest object and allow further object usage
             during result and response composition stages.

 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface PNResponse : NSObject


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Stores reference on HTTP request which has been used to communicate with \b PubNub service.

 @since 4.0
*/
@property (nonatomic, readonly, copy) NSURLRequest *clientRequest;

/**
 @brief  Stores reference on HTTP response received by NSURL loading system.

 @since 4.0
*/
@property (nonatomic, readonly, copy) NSHTTPURLResponse *response;

/**
 @brief  Stores reference on body which has been received from \b PubNub service and pre-processed.

 @since 4.0
*/
@property (nonatomic, readonly, copy) id data;

/**
 @brief  Stores reference request processing error.

 @since 4.0
*/
@property (nonatomic, readonly, copy) NSError *error;

#pragma mark -


@end
