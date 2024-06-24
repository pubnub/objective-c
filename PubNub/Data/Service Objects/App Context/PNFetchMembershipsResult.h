#import <PubNub/PNOperationResult.h>
#import <PubNub/PNMembershipsFetchData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Fetch user meberships` request processing result.
@interface PNFetchMembershipsResult : PNOperationResult


#pragma mark - Properties

/// `Fetch memberships` request processed information.
@property(strong, nonatomic, readonly) PNMembershipsFetchData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
