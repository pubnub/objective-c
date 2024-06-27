#import <PubNub/PNAcknowledgmentStatus.h>
#import <PubNub/PNUUIDMetadataSetData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Set UUID metadata` request processing status.
@interface PNSetUUIDMetadataStatus : PNAcknowledgmentStatus


#pragma mark - Properties

/// `Set UUID metadata` request processed information.
@property (nonatomic, readonly, strong) PNUUIDMetadataSetData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
