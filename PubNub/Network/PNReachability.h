#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PubNub;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b PubNub network reachability / ping utility.
 *
 * @discussion This class used by \b PubNub client to check whether current \b PubNub network state
 * allow to send any requests to it or not.
 * Mostly this method used after unexpected disconnection (on network failure) to start remote
 * service ping process (at least ping once).
 *
 * @author Serhii Mamontov
 * @since 4.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNReachability : NSObject


#pragma mark - Initialization and Configuration

/**
 * @brief Construct reachability helper which will allow to identify current \b PubNub network
 * state.
 *
 * @param client \b PubNub client for which this helper has been created.
 * @param block  Block which is called by helper to inform about current ping round results.
 *
 * @return Constructed and ready to use reachability helper instance.
 */
+ (instancetype)reachabilityForClient:(PubNub *)client
                       withPingStatus:(void(^)(BOOL pingSuccessful))block;


#pragma mark - Service ping

/**
 * @brief Launch process with remote service pinging.
 *
 * @discussion Ping process involves process with reachability state correlation to \b time API call
 * response. In case if \b time API will return valid response - mean what \b PubNub network service
 * ready to process requests.
 *
 * @note Ping process will remain active till \c -stopServicePing method will be called.
 */
- (void)startServicePing;

/**
 * @brief Stop any active reachability check timers and requests.
 */
- (void)stopServicePing;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
