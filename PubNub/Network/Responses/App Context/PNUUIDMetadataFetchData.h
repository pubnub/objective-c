#import <PubNub/PNBaseOperationData.h>
#import <PubNub/PNUUIDMetadata.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interfaces declaration

/// `Fetch UUID metadata` request response.
@interface PNUUIDMetadataFetchData : PNBaseOperationData


#pragma mark - Properties

/// Requested `UUID metadata` object.
@property(strong, nullable, nonatomic, readonly) PNUUIDMetadata *metadata;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
