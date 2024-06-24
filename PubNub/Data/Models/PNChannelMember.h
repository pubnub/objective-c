#import <PubNub/PNBaseAppContextObject.h>
#import <PubNub/PNUUIDMetadata.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Channel member` object.
@interface PNChannelMember : PNBaseAppContextObject


#pragma mark - Properties

/// Metadata associated with `UUID` which is listed in `channel`'s members list.
///
/// > Note: This property will be set only if **PNChannelMemberUUIDField** has been added to `includeFields` list during
/// request.
@property(strong, nonatomic, nullable, readonly) PNUUIDMetadata *metadata;

/// Identifier which is listed in `channel`'s members list.
@property(copy, nonatomic, readonly) NSString *uuid;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
