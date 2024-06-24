#import <PubNub/PNPagedAppContextData.h>
#import <PubNub/PNChannelMember.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Fetch all users` request response.
@interface PNUUIDMetadataFetchAllData : PNPagedAppContextData


#pragma mark - Properties

/// List of `UUIDs metadata` objects created for current subscribe key.
@property(strong, nonatomic, readonly) NSArray<PNUUIDMetadata *> *metadata;

/// Total number of objects created for current subscribe key.
///
/// > Note: Value will be `0` in case if ``PNUUIDFields/PNUUIDTotalCountField`` not added to `includeFields` of
///  ``PubNub/PNFetchAllUUIDMetadataRequest``.
@property (nonatomic, readonly, assign) NSUInteger totalCount;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
