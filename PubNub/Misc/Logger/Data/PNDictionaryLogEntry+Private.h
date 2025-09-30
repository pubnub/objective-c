#import "PNDictionaryLogEntry.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// Dictionary log entry representation object private extension.
@interface PNDictionaryLogEntry ()


#pragma mark - Initialization and Configuration

/// Create `dictionary` log entry.
///
/// - Parameters:
///   - message: `NSDictionary` for log entry.
///   - details: Additional details which describe data in a provided object.
///   - operation: Operation for which ``message`` has been created.
/// - Returns: Ready-to-use log entry object.
///
+ (instancetype)entryWithMessage:(NSDictionary *)message
                         details:(nullable NSString *)details
                       operation:(PNLogMessageOperation)operation;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
