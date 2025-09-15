#import <PubNub/PNNetworkResponseLogEntry.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// Network response log entry representation object private extension.
@interface PNNetworkResponseLogEntry ()


#pragma mark - Initialization and Configuration

/// Create `network response` log entry.
///
/// - Parameter message: `PNTransportResponse` for log entry.
/// - Returns: Ready-to-use log entry object.
///
+ (instancetype)entryWithMessage:(id<PNTransportResponse>)message;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
