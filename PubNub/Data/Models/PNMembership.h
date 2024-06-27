#import <PubNub/PNBaseAppContextObject.h>
#import <PubNub/PNChannelMetadata.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `UUID membership` object.
@interface PNMembership : PNBaseAppContextObject


#pragma mark - Properties

/// `Metadata` associated with `channel` which is listed in `UUID`'s memberships list.
///
/// > Note: This property will be set only if **PNMembershipChannelField** has been added to `includeFields` list during
/// request.
@property(strong, nullable, nonatomic, readonly) PNChannelMetadata *metadata;

/// UUID's for which membership has been created / removed.
@property(copy, nonatomic, nullable, readonly) NSString *uuid;

/// Name of channel which is listed in `UUID`'s memberships list.
@property (nonatomic, readonly, copy) NSString *channel;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
