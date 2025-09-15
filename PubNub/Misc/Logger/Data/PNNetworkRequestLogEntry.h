#import <PubNub/PNTransportRequest.h>
#import <PubNub/PNLogEntry.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Network request log entry representation object.
@interface PNNetworkRequestLogEntry : PNLogEntry<PNTransportRequest *>


#pragma mark - Properties

/// Whether the request has been canceled or not.
@property(assign, atomic, readonly, getter = isCanceled) BOOL canceled;

/// Whether the request processing failed or not.
@property(assign, atomic, readonly, getter = isFailed) BOOL failed;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
