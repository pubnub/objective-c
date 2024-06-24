#import <PubNub/PNBaseOperationData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Fetch time request response data.
@interface PNTimeData : PNBaseOperationData


#pragma mark - Properties

/// High-precision **PubNub** time token.
@property(strong, nonatomic, readonly) NSNumber *timetoken;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
