#import <PubNub/PNPagedAppContextData.h>
#import <PubNub/PNChannelMember.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Fetch channel members` request response.
@interface PNChannelMembersFetchData : PNPagedAppContextData


#pragma mark - Properties

/// List of fetched `members`.
@property(strong, nonatomic, readonly) NSArray<PNChannelMember *> *members;

/// Total number of `members` in `channel`'s members list.
///
/// > Note: Value will be `0` in case if `includeCount` of ``PubNub/PNFetchChannelMembersRequest`` is set to `NO`.
@property(assign, nonatomic, readonly) NSUInteger totalCount;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
