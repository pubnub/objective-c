#import <PubNub/PubNub.h>
#import <AFHTTPSessionManager.h>


#pragma mark Class forward

@class PNRequest;


/**
 @brief      \b PubNub client core extension which expose private fields and methods to support 
             other extensions.
 @discussion Core class manage client configuration as well as access to networking layer through 
             which passed request will be sent to \b PubNub service.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface PubNub ()


///------------------------------------------------
/// @name Properties
///------------------------------------------------

/**
 @brief      Stores reference on dispatch queue which is used to synchronize access to \b PubNub 
             client configuration.
 @discussion Client provide ability to change any of it's configuration fields on run-time. Changes
             may happen on different threads in relation to thread on which client may need to read
             them.

 @since 4.0
*/
@property (nonatomic, strong) dispatch_queue_t configurationAccessQueue;

/**
 @brief      Stores reference on dispatch queue which is used to synchronize access to resources 
             related to subscription process.
 @discussion Subscribe and leave requests issued on this queue because their order should be 
             strictly serialized.
 
 @since 4.0
 */
@property (nonatomic, strong) dispatch_queue_t subscribeQueue;

/**
 @brief      Stores reference on dispatch queue which is used by non-subscription APIs.
 @discussion Queue is used to issue non-subscription API request to \b PubNub service like message
             posting, history, presence and other.
 
 @since 4.0
 */
@property (nonatomic, strong) dispatch_queue_t serviceQueue;

/**
 @brief Stores reference on
 
 @since <#version number#>
 */
@property (nonatomic, strong) AFHTTPSessionManager *subscriptionSession;
@property (nonatomic, strong) AFHTTPSessionManager *serviceSession;


///------------------------------------------------
/// @name Operation processing
///------------------------------------------------

- (void)processRequest:(PNRequest *)request;

#pragma mark -


@end
