#import <PubNub/PubNub+Core.h>

// Request
#import <PubNub/PNChannelGroupManageRequest.h>
#import <PubNub/PNChannelGroupFetchRequest.h>

// Response
#import <PubNub/PNChannelGroupChannelsResult.h>
#import <PubNub/PNChannelGroupsResult.h>

// Deprecated
#import <PubNub/PNStreamModificationAPICallBuilder.h>
#import <PubNub/PNStreamAuditAPICallBuilder.h>
#import <PubNub/PNStreamAPICallBuilder.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// **PubNub** `Channel Group` APIs.
///
/// A set of APIs which allow accessing and managing channel groups and channels inside of them.
@interface PubNub (ChannelGroup)


#pragma mark - Channel group API builder interface (deprecated)

/// Stream API access builder.
@property (nonatomic, readonly, strong) PNStreamAPICallBuilder * (^stream)(void)
    DEPRECATED_MSG_ATTRIBUTE("Builder-based interface deprecated. Please use corresponding request-based interfaces.");


#pragma mark - Channel group audition

/// Fetch list of the channel group channels.
///
/// #### Example:
/// ```objc
/// PNChannelGroupListFetchRequest *request = [PNChannelGroupListFetchRequest requestWithChannelGroup:@"pubnub"];
///
/// [self.client fetchChannelsForChannelGroupWithRequest:request
///                                           completion:^(PNChannelGroupChannelsResult *result, PNErrorStatus *status){
///     if (!status.isError) {
///         // Handle list of channels using: `response.data.channels`.
///     } else {
///         // Handle channels for group audition error. Check `category` property to find out possible issue because of
///         // which request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - request: Request with information required to retrieve channel groups or channel group channels.
///   - block: Channel groups / channels retrieve request completion block.
- (void)fetchChannelsForChannelGroupWithRequest:(PNChannelGroupFetchRequest *)request
                                     completion:(PNGroupChannelsAuditCompletionBlock)block
    NS_SWIFT_NAME(fetchChannelsForChannelGroupWithRequest(_:completion:));

/// Fetch list of channels which is registered in specified `group`.
///
/// #### Example:
/// ```objc
/// [self.client channelsForGroup:@"pubnub"
///                withCompletion:^(PNChannelGroupChannelsResult *result, PNErrorStatus *status) {
///     if (!status.isError) {
///         // Handle downloaded list of channels using: `result.data.channels`.
///     } else {
///         // Handle channels for group audition error. Check `category` property to find out possible issue because of
///         // which request did fail.
///         //
///         // Request can be resent using: `[status retry];`.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - group: Name of the group from which channels should be fetched.
///   - block: Channels audition completion block.
- (void)channelsForGroup:(NSString *)group withCompletion:(PNGroupChannelsAuditCompletionBlock)block
    NS_SWIFT_NAME(channelsForGroup(_:withCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-fetchChannelsForChannelGroupWithRequest:completion:' method instead.");


#pragma mark - Channel group content manipulation

/// Modify channel group.
///
/// Depending from used request it is possible to change list of channels in group or remove whole channel group.
///
/// > Important: The group becomes invalid and can't be used in the subscribe process anymore if all channels or group
/// itself are removed.
///
/// #### Examples:
/// ##### Add channels to channel group:
/// ```objc
/// NSArray<NSString *> *channels = @[@"channel-a", @"channel-b"];
/// PNManageChannelGroupRequest *request = [PNManageChannelGroupRequest requestToAddChannels:channels
///                                                                           toChannelGroup:@"test-channel-group"];
///
/// [self.client manageChannelGroupWithRequest:request completion:^(PNAcknowledgmentStatus *status) {
///     if (!status.isError) {
///         // Handle successful channels list modification for group.
///     } else {
///         // Handle channels list modification for group error. Check `category` property to find out possible issue
///         // because of which request did fail.
///     }
/// }];
/// ```
///
/// ##### Remove channels from channel group:
/// ```objc
/// NSArray<NSString *> *channels = @[@"channel-a", @"channel-b"];
/// PNManageChannelGroupRequest *request = [PNManageChannelGroupRequest requestToRemoveChannels:channels
///                                                                            fromChannelGroup:@"test-channel-group"];
///
/// [self.client manageChannelGroupWithRequest:request completion:^(PNAcknowledgmentStatus *status) {
///     if (!status.isError) {
///        // Handle successful channels list modification for group.
///     } else {
///        // Handle channels list modification for group error. Check 'category' property to find
///        // out possible issue because of which request did fail.
///     }
/// }];
/// ```
///
/// ##### Remove channel group:
/// ```objc
/// PNManageChannelGroupRequest *request = [PNManageChannelGroupRequest requestToRemoveChannelGroup:@"test-channel-group"];
///
/// [self.client manageChannelGroupWithRequest:request completion:^(PNAcknowledgmentStatus *status) {
///     if (!status.isError) {
///         // Handle successful channel group removal.
///     } else {
///         // Handle channel group removal error. Check `category` property to find out possible issue because of which
///         // request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - request: Request with information required to manage channel group channels.
///   - block: Channel group channels list modification request completion block.
- (void)manageChannelGroupWithRequest:(PNChannelGroupManageRequest *)request
                           completion:(PNChannelGroupChangeCompletionBlock)block
    NS_SWIFT_NAME(manageChannelGroupWithRequest(_:completion:));

/// Add new channels to the `group`.
///
/// After addition channels to group it can be used in subscribe request to subscribe on remote data objects live feed
/// with single group name.
///
/// #### Example:
/// ```objc
/// [self.client addChannels:@[@"ios", @"macos"] toGroup:@"os" withCompletion:^(PNAcknowledgmentStatus *status) {
///     if (!status.isError) {
///         // Handle successful channels list modification for group.
///     } else {
///         // Handle channels list modification for group error. Check `category` property to find out possible issue
///         // because of which request did fail.
///         //
///         // Request can be resent using: `[status retry];`.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - channels: List of channel names which should be added to the `group`.
///   - group: Name of the group into which channels should be added.
///   - block: Channels addition completion block.
- (void)addChannels:(NSArray<NSString *> *)channels
            toGroup:(NSString *)group
     withCompletion:(nullable PNChannelGroupChangeCompletionBlock)block
    NS_SWIFT_NAME(addChannels(_:toGroup:withCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-manageChannelGroupWithRequest:completion:' method instead.");


/// Remove specified `channels` from `group`.
///
/// > Important: The group becomes invalid and can't be used in the subscribe process anymore if all channels or group
/// itself are removed.
///
/// #### Example:
/// ```objc
/// [self.client removeChannels:@[@"ios", @"macos"] fromGroup:@"os" withCompletion:^(PNAcknowledgmentStatus *status) {
///     if (!status.isError) {
///         // Handle successful channels list modification for group.
///     } else {
///         // Handle channels list modification for group error. Check `category` property to find out possible issue
///         // because of which request did fail.
///         //
///         // Request can be resent using: `[status retry];`.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - channels: List of channel names which should be removed from `group`.
///   - group: Name of the group from which channels should be removed.
///   - block: Channels removal completion block.
- (void)removeChannels:(NSArray<NSString *> *)channels
             fromGroup:(NSString *)group
        withCompletion:(nullable PNChannelGroupChangeCompletionBlock)block
    NS_SWIFT_NAME(removeChannels(_:fromGroup:withCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-manageChannelGroupWithRequest:completion:' method instead.");

/// Remove all channels from `group`.
///
/// > Important: The group becomes invalid and can't be used in the subscribe process anymore if all channels or group
/// itself are removed.
///
/// #### Example:
/// ```objc
/// [self.client removeChannelsFromGroup:@"os" withCompletion:^(PNAcknowledgmentStatus *status) {
///     if (!status.isError) {
///        // Handle successful channel group removal.
///     } else {
///        // Handle channel group removal error. Check 'category' property to find out possible
///        // issue because of which request did fail.
///        //
///        // Request can be resent using: [status retry];
///     }
/// }];
/// ```
///
/// - Parameters:
///   - group: Name of the group from which all channels should be removed.
///   - block: Channel group removal completion block.
- (void)removeChannelsFromGroup:(NSString *)group withCompletion:(nullable PNChannelGroupChangeCompletionBlock)block
    NS_SWIFT_NAME(removeChannelsFromGroup(_:withCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-manageChannelGroupWithRequest:completion:' method instead.");

#pragma mark -


@end

NS_ASSUME_NONNULL_END
