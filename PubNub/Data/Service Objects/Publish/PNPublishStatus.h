#import <PubNub/PNAcknowledgmentStatus.h>
#import <PubNub/PNPublishData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Publish request processing status.
@interface PNPublishStatus : PNAcknowledgmentStatus


#pragma mark - Properties

/// Publish request response from remote service.
@property(strong, nonatomic, readonly) PNPublishData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
