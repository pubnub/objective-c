#import <PubNub/PNPagedAppContextData.h>
#import <PubNub/PNChannelMember.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Channel members manage` request response.
@interface PNChannelMembersManageData : PNPagedAppContextData


#pragma mark - Properties

/// List of existing `members`.
@property(strong, nonatomic, readonly) NSArray<PNChannelMember *> *members;

/// Total number of existing objects.
///
/// > Note: Value will be `0` in case if ``PNChannelMemberFields/PNChannelMembersTotalCountField`` not added to
/// `includeFields` of: ``PubNub/PNSetChannelMembersRequest``, ``PubNub/PNRemoveChannelMembersRequest``,
/// ``PubNub/PNManageChannelMembersRequest`` or ``PNFetchChannelMembersRequest``.
@property(assign, nonatomic, readonly) NSUInteger totalCount;


#pragma mark -

@end

NS_ASSUME_NONNULL_END
