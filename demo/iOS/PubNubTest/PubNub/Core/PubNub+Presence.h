#import <Foundation/Foundation.h>
#import "PubNub+Core.h"


/**
 @brief      \b PubNub client core class extension to provide access to 'presence' API group.
 @discussion Set of API which allow to retrieve information about subscriber(s) on remote data 
             object live feeds and perform heartbeat requests to let \b PubNub service know what
             client still interested in updates from feed.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface PubNub (Presence)


///------------------------------------------------
/// @name Global here now
///------------------------------------------------

/**
 @brief      Request information about subscribers on all remote data objects live feeds.
 @discussion This is application wide request for all remote data objects which is registered under
             publish and subscribe keys used for client configuration.
 @note       This API will retrieve only list of UUIDs for each remote data object and number of 
             subscribers in total for objects and overall.
 
 @param block Here now processing completion block which pass two arguments: \c result - in case of
              successful request processing \c data field will contain results of here now 
              operation; \c status - in case if error occurred during request processing.
 
 @since 4.0
 */
- (void)hereNowWithCompletion:(PNCompletionBlock)block;


/**
 @brief      Request information about subscribers on all remote data objects live feeds.
 @discussion This is application wide request for all remote data objects which is registered under
             publish and subscribe keys used for client configuration.
 @note       This API will retrieve only list of UUIDs for each remote data object and number of 
             subscribers in total for objects and overall.

 @code
 @endcode
 Extension to \c -hereNowWithCompletion: and allow to specify here now data which should be returned
 by \b PubNub service.
 
 @param type  Reference on one of \b PNHereNowDataType fields to instruct what exactly data it 
              expected in response.
 @param block Here now processing completion block which pass two arguments: \c result - in case of 
              successful request processing \c data field will contain results of here now
              operation; \c status - in case if error occurred during request processing.
 
 @since 4.0
 */
- (void)hereNowData:(PNHereNowDataType)type withCompletion:(PNCompletionBlock)block;


///------------------------------------------------
/// @name Channel here now
///------------------------------------------------

/**
 @brief  Request information about subscribers on specific channel live feeds.
 @note   This API will retrieve only list of UUIDs for specified channel and number of subscribers 
         on it.
 
 @param channel Reference on channel for which here now information should be received.
 @param block   Here now processing completion block which pass two arguments: \c result - in case 
                of successful request processing \c data field will contain results of here now 
                operation; \c status - in case if error occurred during request processing.
 
 @since 4.0
 */
- (void)hereNowForChannel:(NSString *)channel withCompletion:(PNCompletionBlock)block;

/**
 @brief  Request information about subscribers on specific channel live feeds.
 @note   This API will retrieve only list of UUIDs for specifiedchannel and number of subscribers on
         it.

 @code
 @endcode
 Extension to \c -hereNowForChannel:withCompletion: and allow to specify here now data which should
 be returned by \b PubNub service.
 
 @param type    Reference on one of \b PNHereNowDataType fields to instruct what exactly data it
                expected in response.
 @param channel Reference on channel for which here now information should be received.
 @param block   Here now processing completion block which pass two arguments: \c result - in case 
                of successful request processing \c data field will contain results of here now 
                operation; \c status - in case if error occurred during request processing.
 
 @since 4.0
 */
- (void)hereNowData:(PNHereNowDataType)type forChannel:(NSString *)channel
     withCompletion:(PNCompletionBlock)block;


///------------------------------------------------
/// @name Channel group here now
///------------------------------------------------

/**
 @brief  Request information about subscribers on specific channel group live feeds.
 @note   This API will retrieve only list of UUIDs for specified channel group and number of
         subscribers on it.
 
 @param group Reference on channel group for which here now information should be received.
 @param block Here now processing completion block which pass two arguments: \c result - in case of 
              successful request processing \c data field will contain results of here now 
              operation; \c status - in case if error occurred during request processing.
 
 @since 4.0
 */
- (void)hereNowForChannelGroup:(NSString *)group withCompletion:(PNCompletionBlock)block;

/**
 @brief  Request information about subscribers on specific channel group live feeds.
 @note   This API will retrieve only list of UUIDs for specified channel group and number of
         subscribers on it.

 @code
 @endcode
 Extension to \c -hereNowForChannel:withCompletion: and allow to specify here now data which should
 be returned by \b PubNub service.
 
 @param type  Reference on one of \b PNHereNowDataType fields to instruct what exactly data it
              expected in response.
 @param group Reference on channel group for which here now information should be received.
 @param block Here now processing completion block which pass two arguments: \c result - in case of 
              successful request processing \c data field will contain results of here now 
              operation; \c status - in case if error occurred during request processing.
 
 @since 4.0
 */
- (void)hereNowData:(PNHereNowDataType)type forChannelGroup:(NSString *)group
     withCompletion:(PNCompletionBlock)block;


///------------------------------------------------
/// @name Client where now
///------------------------------------------------

/**
 @brief  Request information about remote data object live feeds on which client with specified UUID
         subscribed at this moment.
 
 @param uuid  Reference on UUID for which request should be performed.
 @param block Where now processing completion block which pass two arguments: \c result - in case of
              successful request processing \c data field will contain results of where now
              operation; \c status - in case if error occurred during request processing.
 
 @since 4.0
 */
- (void)whereNowUUID:(NSString *)uuid withCompletion:(PNCompletionBlock)block;

#pragma mark -


@end
