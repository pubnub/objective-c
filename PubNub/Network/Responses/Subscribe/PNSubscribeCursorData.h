#import "PNBaseOperationData.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Subscribe request time cursor response.
///
/// Object used to represent subscription cursor information.
@interface PNSubscribeCursorData : PNBaseOperationData


#pragma mark - Properties

/// High-precision **PubNub** time token of published data.
@property(strong, nonatomic, readonly) NSNumber *timetoken;

/// Data center region for which `timetoken` has been generated.
@property(strong, nonatomic, readonly) NSNumber *region;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
