#import <PubNub/PNAcknowledgmentStatus.h>
#import <PubNub/PNChannelMembersManageData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Manage members` request processing status.
@interface PNManageChannelMembersStatus : PNAcknowledgmentStatus


#pragma mark - Properties

/// `Members` `set` / `remove` / `manage` request processed information.
@property(strong, nonatomic, readonly) PNChannelMembersManageData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
