#import <PubNub/PNAcknowledgmentStatus.h>
#import <PubNub/PNMembershipsManageData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Manage memberships` request processing status.
@interface PNManageMembershipsStatus : PNAcknowledgmentStatus


#pragma mark - Properties

/// `Memberships` `set` / `remove` / `manage` request processed information.
@property(strong, nonatomic, readonly) PNMembershipsManageData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
