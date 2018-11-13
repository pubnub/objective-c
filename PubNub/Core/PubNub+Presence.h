#import <Foundation/Foundation.h>
#import "PNPresenceChannelGroupHereNowAPICallBuilder.h"
#import "PNPresenceChannelHereNowAPICallBuilder.h"
#import "PNPresenceHeartbeatAPICallBuilder.h"
#import "PNPresenceWhereNowAPICallBuilder.h"
#import "PNPresenceHereNowAPICallBuilder.h"
#import "PNPresenceAPICallBuilder.h"
#import "PubNub+Core.h"


#pragma mark Class forward

@class PNPresenceChannelGroupHereNowResult, PNPresenceChannelHereNowResult,
       PNPresenceGlobalHereNowResult, PNPresenceWhereNowResult, PNErrorStatus;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - API group interface
/**
 * @brief \b PubNub client core class extension to provide access to 'presence' API group.
 *
 * @discussion Set of API which allow to retrieve information about subscriber(s) on remote data
 * object live feeds and perform heartbeat requests to let \b PubNub service know what client still
 * interested in updates from feed.
 *
 * @author Serhii Mamontov
 * @since 4.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface PubNub (Presence)


#pragma mark - API builder support

/**
 * @brief Presence API access builder.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNPresenceAPICallBuilder * (^presence)(void);


#pragma mark - Global here now

/**
 * @brief Request information about subscribers on all remote data objects live feeds.
 *
 * @discussion This is application wide request for all remote data objects which is registered
 * under publish and subscribe keys used for client configuration.
 *
 * @note This API will retrieve only list of UUIDs along with their state for each remote data
 * object and number of subscribers in total for objects and overall.
 *
 * @code
 * [self.client hereNowWithCompletion:^(PNPresenceGlobalHereNowResult *result,
 *                                      PNErrorStatus *status) {
 *
 *     if (!status.isError) {
 *        // Handle downloaded presence information using:
 *        //   result.data.channels - dictionary with active channels and presence information on
 *        //                          each. Each channel will have next fields: "uuids" - list of
 *        //                          subscribers; occupancy - number of active subscribers.
 *        //                          Each uuids entry has next fields: "uuid" - identifier and
 *        //                          "state" if it has been provided.
 *        //   result.data.totalChannels - total number of active channels.
 *        //   result.data.totalOccupancy - total number of active subscribers.
 *     } else {
 *        // Handle presence audit error. Check 'category' property to find out possible issue
 *        // because of which request did fail.
 *        //
 *        // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param block Here now fetch completion block.
 *
 * @since 4.0
 */
- (void)hereNowWithCompletion:(PNGlobalHereNowCompletionBlock)block
    NS_SWIFT_NAME(hereNowWithCompletion(_:));

/**
 * @brief Request information about subscribers on all remote data objects live feeds.
 *
 * @discussion This is application wide request for all remote data objects which is registered
 * under publish and subscribe keys used for client configuration.
 *
 * @code
 * [self.client hereNowWithVerbosity:PNHereNowState
 *                      completion:^(PNPresenceGlobalHereNowResult *result, PNErrorStatus *status) {
 *
 *     if (!status.isError) {
 *        // Handle downloaded presence information using:
 *        //   result.data.channels - dictionary with active channels and presence information on
 *        //                          each. Each channel will have next fields: "uuids" - list of
 *        //                          subscribers; "occupancy" - number of active subscribers.
 *        //                          Each uuids entry has next fields: "uuid" - identifier and
 *        //                          "state" if it has been provided.
 *        //   result.data.totalChannels - total number of active channels.
 *        //   result.data.totalOccupancy - total number of active subscribers.
 *     } else {
 *        // Handle presence audit error. Check 'category' property to find out possible issue
 *        // because of which request did fail.
 *        //
 *        // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param level One of \b PNHereNowVerbosityLevel fields to instruct what exactly data it expected
 *     in response.
 * @param block Here now fetch completion block.
 *
 * @since 4.0
 */
- (void)hereNowWithVerbosity:(PNHereNowVerbosityLevel)level
                  completion:(PNGlobalHereNowCompletionBlock)block
    NS_SWIFT_NAME(hereNowWithVerbosity(_:completion:));


#pragma mark - Channel here now

/**
 * @brief Request information about subscribers on specific channel live feeds.
 *
 * @note This API will retrieve only list of UUIDs along with their state for each remote data
 * object and number of subscribers in total for objects and overall.
 *
 * @code
 * [self.client hereNowForChannel:@"pubnub"
 *                 withCompletion:^(PNPresenceChannelHereNowResult *result, PNErrorStatus *status) {
 *
 *     if (!status.isError) {
 *        // Handle downloaded presence information using:
 *        //   result.data.uuids - dictionary with active subscriber. Each entry will have next
 *        //                       fields: "uuid" - identifier and "state" if it has been provided.
 *        //   result.data.occupancy - total number of active subscribers.
 *     } else {
 *        // Handle presence audit error. Check 'category' property to find out possible issue
 *        // because of which request did fail.
 *        //
 *        // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param channel Channel for which here now information should be received.
 * @param block Here now fetch completion block.
 *
 * @since 4.0
 */
- (void)hereNowForChannel:(NSString *)channel withCompletion:(PNHereNowCompletionBlock)block
    NS_SWIFT_NAME(hereNowForChannel(_:withCompletion:));

/**
 * @brief Request information about subscribers on specific channel live feeds.
 *
 * @code
 * [self.client hereNowForChannel:@"pubnub" withVerbosity:PNHereNowState
 *                     completion:^(PNPresenceChannelHereNowResult *result, PNErrorStatus *status) {
 *
 *     if (!status.isError) {
 *        // Handle downloaded presence information using:
 *        //   result.data.uuids - dictionary with active subscriber. Each entry will have next
 *        //                       fields: "uuid" - identifier and "state" if it has been provided.
 *        //   result.data.occupancy - total number of active subscribers.
 *     } else {
 *        // Handle presence audit error. Check 'category' property to find out possible issue
 *        // because of which request did fail.
 *        //
 *        // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param channel Channel for which here now information should be received.
 * @param level One of \b PNHereNowVerbosityLevel fields to instruct what exactly data it expected
 *     in response.
 * @param block Here now fetch completion block.
 *
 * @since 4.0
 */
- (void)hereNowForChannel:(NSString *)channel
            withVerbosity:(PNHereNowVerbosityLevel)level
               completion:(PNHereNowCompletionBlock)block
    NS_SWIFT_NAME(hereNowForChannel(_:withVerbosity:completion:));


#pragma mark - Channel group here now

/**
 * @brief Request information about subscribers on specific channel group live feeds.
 *
 * @note This API will retrieve only list of UUIDs along with their state for each remote data
 * object and number of subscribers in total for objects and overall.
 *
 * @code
 * [self.client hereNowForChannelGroup:@"developers"
 *            withCompletion:^(PNPresenceChannelGroupHereNowResult *result, PNErrorStatus *status) {
 *
 *     if (!status.isError) {
 *        // Handle downloaded presence information using:
 *        //   result.data.channels - dictionary with active channels and presence information on
 *        //                          each. Each channel will have next fields: "uuids" - list of
 *        //                          subscribers; occupancy - number of active subscribers.
 *        //                          Each uuids entry has next fields: "uuid" - identifier and
 *        //                          "state" if it has been provided.
 *        //   result.data.totalChannels - total number of active channels.
 *        //   result.data.totalOccupancy - total number of active subscribers.
 *     } else {
 *        // Handle presence audit error. Check 'category' property to find out possible issue
 *        // because of which request did fail.
 *        //
 *        // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param group Channel group name for which here now information should be received.
 * @param block Here now fetch completion block.
 *
 * @since 4.0
 */
- (void)hereNowForChannelGroup:(NSString *)group
                withCompletion:(PNChannelGroupHereNowCompletionBlock)block
    NS_SWIFT_NAME(hereNowForChannelGroup(_:withCompletion:));

/**
 * @brief Request information about subscribers on specific channel group live feeds.
 *
 * @code
 * [self.client hereNowForChannelGroup:@"developers" withVerbosity:PNHereNowState
 *                completion:^(PNPresenceChannelGroupHereNowResult *result, PNErrorStatus *status) {
 *
 *     if (!status.isError) {
 *        // Handle downloaded presence information using:
 *        //   result.data.channels - dictionary with active channels and presence information on
 *        //                          each. Each channel will have next fields: "uuids" - list of
 *        //                          subscribers; occupancy - number of active subscribers.
 *        //                          Each uuids entry has next fields: "uuid" - identifier and
 *        //                          "state" if it has been provided.
 *        //   result.data.totalChannels - total number of active channels.
 *        //   result.data.totalOccupancy - total number of active subscribers.
 *     } else {
 *        // Handle presence audit error. Check 'category' property to find out possible issue
 *        // because of which request did fail.
 *        //
 *        // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param group Channel group for which here now information should be received.
 * @param level One of \b PNHereNowVerbosityLevel fields to instruct what exactly data it expected
 *     in response.
 * @param block Here now fetch completion block.
 *
 * @since 4.0
 */
- (void)hereNowForChannelGroup:(NSString *)group
                 withVerbosity:(PNHereNowVerbosityLevel)level
                    completion:(PNChannelGroupHereNowCompletionBlock)block
    NS_SWIFT_NAME(hereNowForChannelGroup(_:withVerbosity:completion:));


#pragma mark - Client where now

/**
 * @brief Request information about remote data object live feeds on which client with specified
 * UUID subscribed at this moment.
 *
 * @code
 * [self.client whereNowUUID:@"Steve"
 *            withCompletion:^(PNPresenceWhereNowResult *result, PNErrorStatus *status) {
 *
 *     if (!status.isError) {
 *        // Handle downloaded presence 'where now' information using: result.data.channels
 *     } else {
 *        // Handle presence audit error. Check 'category' property to find out possible issue
 *        // because of which request did fail.
 *        //
 *        // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param uuid UUID for which request should be performed.
 * @param block Where now fetch completion block.
 *
 * @since 4.0
 */
- (void)whereNowUUID:(NSString *)uuid withCompletion:(PNWhereNowCompletionBlock)block
    NS_SWIFT_NAME(whereNowUUID(_:withCompletion:));

#pragma mark -


@end

NS_ASSUME_NONNULL_END
