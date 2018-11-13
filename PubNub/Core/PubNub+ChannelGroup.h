#import <Foundation/Foundation.h>
#import "PNStreamModificationAPICallBuilder.h"
#import "PNStreamAuditAPICallBuilder.h"
#import "PNStreamAPICallBuilder.h"
#import "PubNub+Core.h"


#pragma mark Class forward

@class PNChannelGroupChannelsResult, PNAcknowledgmentStatus, PNChannelGroupsResult, PNErrorStatus;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - API group interface

/**
 * @brief \b PubNub client core class extension to provide access to 'stream controller' API group.
 *
 * @discussion Set of API which allow to manage channels collections and manipulate list of channels
 * in collection.
 *
 * @author Serhii Mamontov
 * @since 4.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface PubNub (ChannelGroup)


#pragma mark - API builder support

/**
 * @brief Stream API access builder.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNStreamAPICallBuilder * (^stream)(void);


#pragma mark - Channel group audition

/**
 * @brief Fetch list of channels which is registered in specified \c group.
 *
 * @code
 * [self.client channelsForGroup:@"pubnub"
 *                withCompletion:^(PNChannelGroupChannelsResult *result, PNErrorStatus *status) {
 *
 *     if (!status.isError) {
 *        // Handle downloaded list of channels using: result.data.channels
 *     } else {
 *        // Handle channels for group audition error. Check 'category' property to find out
 *        // possible issue because of which request did fail.
 *        //
 *        // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param group Name of the group from which channels should be fetched.
 * @param block Channels audition completion block.
 *
 * @since 4.0
 */
- (void)channelsForGroup:(NSString *)group withCompletion:(PNGroupChannelsAuditCompletionBlock)block
    NS_SWIFT_NAME(channelsForGroup(_:withCompletion:));


#pragma mark - Channel group content manipulation

/**
 * @brief Add new channels to the \c group.
 *
 * @discussion After addition channels to group it can be used in subscribe request to subscribe on
 * remote data objects live feed with single group name.
 *
 * @code
 * [self.client addChannels:@[@"ios", @"macos", @"Win"] toGroup:@"os"
 *           withCompletion:^(PNAcknowledgmentStatus *status) {
 *
 *     if (!status.isError) {
 *        // Handle successful channels list modification for group.
 *     } else {
 *        // Handle channels list modification for group error. Check 'category' property to find
 *        // out possible issue because of which request did fail.
 *        //
 *        // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param channels List of channel names which should be added to the \c group.
 * @param group Name of the group into which channels should be added.
 * @param block Channels addition completion block.
 
 @since 4.0
 */
- (void)addChannels:(NSArray<NSString *> *)channels
            toGroup:(NSString *)group
     withCompletion:(nullable PNChannelGroupChangeCompletionBlock)block
    NS_SWIFT_NAME(addChannels(_:toGroup:withCompletion:));

/**
 * @brief Remove specified \c channels from \c group.
 *
 * @discussion After specified channels will be removed, events from those channel's live feed won't
 * be delivered to the client which is subscribed at specified channel group.
 *
 * @code
 * [self.client removeChannels:@[@"ios", @"macos", @"Win"] fromGroup:@"os"
 *              withCompletion:^(PNAcknowledgmentStatus *status) {
 *
 *     if (!status.isError) {
 *        // Handle successful channels list modification for group.
 *     } else {
 *        // Handle channels list modification for group error. Check 'category' property to find
 *        // out possible issue because of which request did fail.
 *        //
 *        // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param channels List of channel names which should be removed from \c group.
 * @param group Name of the group from which channels should be removed.
 * @param block Channels removal completion block.
 *
 * @since 4.0
 */
- (void)removeChannels:(NSArray<NSString *> *)channels
             fromGroup:(NSString *)group
        withCompletion:(nullable PNChannelGroupChangeCompletionBlock)block
    NS_SWIFT_NAME(removeChannels(_:fromGroup:withCompletion:));

/**
 * @brief Remove all channels from \c group.
 *
 * @discussion After all channels removed from \c group it become invalid and can't be used in
 * subscribe process anymore.
 *
 * @code
 * [self.client removeChannelsFromGroup:@"os" withCompletion:^(PNAcknowledgmentStatus *status) {
 *     if (!status.isError) {
 *        // Handle successful channel group removal.
 *     } else {
 *        // Handle channel group removal error. Check 'category' property to find out possible
 *        // issue because of which request did fail.
 *        //
 *        // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param group Name of the group from which all channels should be removed.
 * @param block Channel group removal completion block.
 *
 * @since 4.0
 */ 
- (void)removeChannelsFromGroup:(NSString *)group
                 withCompletion:(nullable PNChannelGroupChangeCompletionBlock)block
    NS_SWIFT_NAME(removeChannelsFromGroup(_:withCompletion:));

#pragma mark -


@end

NS_ASSUME_NONNULL_END
