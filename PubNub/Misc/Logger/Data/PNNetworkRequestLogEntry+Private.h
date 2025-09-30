#import "PNNetworkRequestLogEntry.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// Network request log entry representation object private extension.
@interface PNNetworkRequestLogEntry (Private)


#pragma mark - Initialization and Configuration

/// Create `network request` log entry.
///
/// - Parameters:
///   - message: `PNTransportRequest` for log entry.
///   - details: Additional details which describe data in a provided object.
/// - Returns: Ready-to-use log entry object.
///
+ (instancetype)entryWithMessage:(PNTransportRequest *)message details:(nullable NSString *)details;

/// Create `network request` log entry.
///
/// - Parameters:
///   - message: `PNTransportRequest` for log entry.
///   - details: Additional details which describe data in a provided object.
///   - canceled: Whether the request has been canceled or not.
///   - failed: Whether the request processing failed or not.
/// - Returns: Ready-to-use log entry object.
///
+ (instancetype)entryWithMessage:(PNTransportRequest *)message
                         details:(nullable NSString *)details
                        canceled:(BOOL)canceled
                          failed:(BOOL)failed;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
