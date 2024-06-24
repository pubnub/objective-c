#import <PubNub/PNAcknowledgmentStatus.h>
#import <PubNub/PNSignalData.h>


NS_ASSUME_NONNULL_BEGIN

/// Signal request processing status.
@interface PNSignalStatus : PNAcknowledgmentStatus


#pragma mark - Properties

/// Signal request response from remote service.
@property(strong, nonatomic, readonly) PNSignalData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
