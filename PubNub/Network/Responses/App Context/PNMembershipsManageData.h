#import <PubNub/PNPagedAppContextData.h>
#import <PubNub/PNMembership.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `User membership manage` request response.
@interface PNMembershipsManageData : PNPagedAppContextData


#pragma mark - Properties

/// List of existing `memberships`.
@property(strong, nonatomic, readonly) NSArray<PNMembership *> *memberships;

/// Total number of existing objects.
///
/// > Note: Value will be `0` in case if ``PNMembershipFields/PNMembershipsTotalCountField`` not added to
/// `includeFields` of ``PubNub/PNSetMembershipsRequest``, ``PubNub/PNRemoveMembershipsRequest``, 
/// ``PubNub/PNManageMembershipsRequest`` or ``PubNub/PNFetchMembershipsRequest``.
@property(assign, nonatomic, readonly) NSUInteger totalCount;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
