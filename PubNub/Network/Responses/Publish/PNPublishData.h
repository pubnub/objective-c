#import <PubNub/PNBaseOperationData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface implementation

/// Data publish request response.
@interface PNPublishData : PNBaseOperationData


#pragma mark - Properties

/// High-precision **PubNub** time token of published data.
@property(strong, nonatomic, readonly) NSNumber *timetoken;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
