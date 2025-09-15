#import <PubNub/PNLogEntry.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// String log entry representation object.
@interface PNStringLogEntry : PNLogEntry<NSString *>


#pragma mark - Initialization and Configuration

/// Create `text` log entry.
///
/// - Parameter message: `NSString` for log entry.
/// - Returns: Ready-to-use log entry object.
///
+ (instancetype)entryWithMessage:(NSString *)message;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
