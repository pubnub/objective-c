#import <PubNub/PNTransportResponse.h>
#import <PubNub/PNLogEntry.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Network response log entry representation object.
@interface PNNetworkResponseLogEntry : PNLogEntry<id<PNTransportResponse>>


#pragma mark -


@end

NS_ASSUME_NONNULL_END
