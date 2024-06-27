#import <PubNub/PNAcknowledgmentStatus.h>
#import <PubNub/PNChannelMetadataSetData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Set channel metadata` request processing status.
@interface PNSetChannelMetadataStatus : PNAcknowledgmentStatus


#pragma mark - Properties

/// `Set channel metadata` request processed information.
@property(strong, nonatomic, readonly) PNChannelMetadataSetData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
