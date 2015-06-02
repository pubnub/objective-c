#import <Foundation/Foundation.h>
#import "PNStructures.h"


#pragma mark Class forward

@class PNConfiguration;


/**
 @brief      PubNub client core class which is responsible for communication with \b PubNub 
             network and provide responses back to completion block/delegates.
 @discussion Basically used by \b PubNub categories (each for own API group) and manage 
             communication with \b PubNub service and share user-specified configuration.

 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface PubNub : NSObject


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Retrieve UUID which has been used during client initialization.
 
 @return User-provided or generated unique user identifier.
 
 @since 4.0
 */
- (NSString *)uuid;


///------------------------------------------------
/// @name Initialization
///------------------------------------------------

/**
 @brief      Construct new \b PubNub client instance with pre-defined configuration.
 @discussion If all keys will be specified, client will be able to read and modify data on 
             \b PubNub service.
 @note       Client will make configuration deep copy and further changes in \b PNConfiguration 
             after it has been passed to the client won't take any effect on client.
 @note       All completion block and delegate callbacks will be called on main queue.
 @note       All required keys can be found on https://admin.pubnub.com
 
 @code
 @endcode
 \b Example:
 @code
 PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo"
                                                                  subscribeKey:@"demo"];
 PubNub *client = [PubNub clientWithConfiguration:configuration];
 @endcode

 @param configuration Reference on instance which store all user-provided information about how
                      client should operate and handle events.

 @return Configured and ready to use \b PubNub client.

 @since 4.0
*/
+ (instancetype)clientWithConfiguration:(PNConfiguration *)configuration;

/**
 @brief      Construct new \b PubNub client instance with pre-defined configuration.
 @discussion If all keys will be specified, client will be able to read and modify data on 
             \b PubNub service.
 @note       Client will make configuration deep copy and further changes in \b PNConfiguration 
             after it has been passed to the client won't take any effect on client.
 @note       If \c queue is \ nil all completion block and delegate callbacks will be called on main
             queue.
 @note       All required keys can be found on https://admin.pubnub.com
 
 @code
 @endcode
 \b Example:
 @code
 dispatch_queue_t queue = dispatch_queue_create("com.my-app.callback-queue",
                                                DISPATCH_QUEUE_SERIAL);
 PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo"
                                                                  subscribeKey:@"demo"];
 PubNub *client = [PubNub clientWithConfiguration:configuration callbackQueue:queue];
 @endcode

 @param configuration Reference on instance which store all user-provided information about how
                      client should operate and handle events.
 @param callbackQueue Reference on queue which should be used by client fot comletion block and 
                      delegate calls.

 @return Configured and ready to use \b PubNub client.

 @since 4.0
*/
+ (instancetype)clientWithConfiguration:(PNConfiguration *)configuration
                          callbackQueue:(dispatch_queue_t)callbackQueue;

#pragma mark -


@end
