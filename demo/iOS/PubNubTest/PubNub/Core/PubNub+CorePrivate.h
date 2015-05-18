#import "PubNub+Core.h"
#import <AFNetworkReachabilityManager.h>
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
@interface PubNub (Private)


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
@property (nonatomic, readonly, strong) dispatch_queue_t configurationAccessQueue;

/**
 @brief      Stores reference on dispatch queue which is used to synchronize access to resources 
             related to subscription process.
 @discussion Subscribe and leave requests issued on this queue because their order should be 
             strictly serialized.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) dispatch_queue_t subscribeQueue;

/**
 @brief      Stores reference on dispatch queue which is used by non-subscription APIs.
 @discussion Queue is used to issue non-subscription API request to \b PubNub service like message
             posting, history, presence and other.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) dispatch_queue_t serviceQueue;

/**
 @brief Stores reference on unique device identifier based on bundle identifier used by software
        vendor.
 
 @since 4.0
 */
@property (nonatomic, readonly, copy) NSString *deviceID;

/**
 @brief Stores reference on session with pre-configured options useful for 'subscription' API group
        with long-polling.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) AFHTTPSessionManager *subscriptionSession;

/**
 @brief Stores reference on session with pre-configured options useful for 'non-subscription' API 
        group.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) AFHTTPSessionManager *serviceSession;


///------------------------------------------------
/// @name Operation processing
///------------------------------------------------

/**
 @brief  Complete request configuration and use it to communicate with \b PubNub service.
 
 @param request Reference on request instance which hold base information required to build request
                to get access to remote data objects.
 
 @since 4.0
 */
- (void)processRequest:(PNRequest *)request;

/**
 @brief  Handle successful request task execution with further building of result and status 
         objects which will be distributed to the user.
 
 @param request Reference on original request which has been used to build network request to PubNub
                service.
 @param task    Reference on data download task which hold information about NSURL request used to
                load data and server response information.
 @param data    Reference on data which has been downloaded in response for client request.
 
 @since 4.0
 */
- (void)handleRequestSuccess:(PNRequest *)request withTask:(NSURLSessionDataTask *)task
                     andData:(id)data;

/**
 @brief  Handle request task execution failure with further building of result and status objects 
         which will be distributed to the user.
 
 @param request Reference on original request which has been used to build network request to PubNub
                service.
 @param task    Reference on data download task which hold information about NSURL request used to
                load data and server response information.
 @param error   Reference on error which occurred while request executed.
 
 @since 4.0
 */
- (void)handleRequestFailure:(PNRequest *)request withTask:(NSURLSessionDataTask *)task
                    andError:(NSError *)error;

#pragma mark -


@end
