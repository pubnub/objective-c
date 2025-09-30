#import <PubNub/PNLogEntry.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Error log entry representation object.
@interface PNErrorLogEntry : PNLogEntry<NSError *>


#pragma mark - Initialization and Configuration

/// Create `error` log entry.
///
/// - Parameter message: `NSError` for log entry.
/// - Returns: Ready-to-use log entry object.
///
+ (instancetype)entryWithMessage:(NSError *)message;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
