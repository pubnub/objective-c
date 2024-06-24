#import <PubNub/PNOperationResult.h>
#import <PubNub/PNChannelMembersFetchData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Fetch channel members` request processing result.
@interface PNFetchChannelMembersResult : PNOperationResult


#pragma mark - Properties

/// `Fetch channel members` request processed information.
@property (nonatomic, readonly, strong) PNChannelMembersFetchData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
