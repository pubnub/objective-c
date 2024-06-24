#import <PubNub/PNBaseOperationData.h>
#import <PubNub/PNUUIDMetadata.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interfaces declaration

/// `Set UUID metadata` request response.
@interface PNUUIDMetadataSetData : PNBaseOperationData


#pragma mark - Properties

/// Updated `UUID metadata` object.
@property(strong, nullable, nonatomic, readonly) PNUUIDMetadata *metadata;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
