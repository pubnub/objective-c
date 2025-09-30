#import "PNErrorLogEntry.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Error log entry representation object.
@interface PNErrorLogEntry ()


#pragma mark - Initialization and Configuration

/// Create `error` log entry.
///
/// - Parameters:
///   - message: `NSError` for log entry.
///   - operation: Operation for which ``message`` has been created.
/// - Returns: Ready-to-use log entry object.
///
+ (instancetype)entryWithMessage:(NSError *)message operation:(PNLogMessageOperation)operation;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
