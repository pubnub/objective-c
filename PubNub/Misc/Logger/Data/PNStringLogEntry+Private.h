#import "PNStringLogEntry.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// String log entry representation object private extension.
@interface PNStringLogEntry ()


#pragma mark - Initialization and Configuration

/// Create `text` log entry.
///
/// - Parameters:
///   - message: `NSString` for log entry.
///   - operation: Operation for which ``message`` has been created.
/// - Returns: Ready-to-use log entry object.
///
+ (instancetype)entryWithMessage:(NSString *)message operation:(PNLogMessageOperation)operation;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
