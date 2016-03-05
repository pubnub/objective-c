#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PubNub;


NS_ASSUME_NONNULL_BEGIN

/**
 @brief      \b PubNub network reachability / ping utility.
 @discussion This class used by \b PubNub client to check whether current \b PubNub network state
             allow to send any requests to it or not.
             Mostly this method used after unexpected disconnection (on network failure) to start
             remote service ping process (at least ping once).
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
@interface PNReachability : NSObject


///------------------------------------------------
/// @name Initialization and Configuration
///------------------------------------------------

/**
 @brief  Construct reachability helper which will allow to identify current \b PubNub network state.
 
 @param client Reference on \b PubNub client for which this helper has been created.
 @param block  Reference on block which is called by helper to inform about current ping round
               results.
 
 @return Constructed and ready to use reachability helper instance.
 
 @since 4.0
 */
+ (instancetype)reachabilityForClient:(PubNub *)client withPingStatus:(void(^)(BOOL pingSuccessful))block;


///------------------------------------------------
/// @name Service ping
///------------------------------------------------

/**
 @brief      Launch process with remote service pinging.
 @discussion Ping process involves process with reachability state correlation to \b time API call
             response. In case if \b time API will return valid response - mean what \b PubNub 
             network service ready to process requests.
 @note       Ping process will remain active till \c -stopServicePing method will be called.
 
 @since 4.0
 */
- (void)startServicePing;

/**
 @brief  Stop any active reachability check timers and requests.
 
 @since 4.0
 */
- (void)stopServicePing;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
