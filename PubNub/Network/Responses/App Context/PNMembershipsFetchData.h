#import <PubNub/PNPagedAppContextData.h>
#import <PubNub/PNMembership.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Fetch user membership` request response.
@interface PNMembershipsFetchData : PNPagedAppContextData


#pragma mark - Properties

/// List of fetched `memberships`.
@property(strong, nonatomic, readonly) NSArray<PNMembership *> *memberships;

/// Total number of `memberships` in which `UUID` participate.
///
/// > Note: Value will be `0` in case if `includeCount` of ``PubNub/PNFetchMembershipsRequest`` is set to `NO`.
@property(assign, nonatomic, readonly) NSUInteger totalCount;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
