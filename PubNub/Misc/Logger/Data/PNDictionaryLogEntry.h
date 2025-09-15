#import <PubNub/PNTransportResponse.h>
#import <PubNub/PNLogEntry.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Dictionary log entry representation object.
@interface PNDictionaryLogEntry : PNLogEntry<NSDictionary *>


#pragma mark - Initialization and Configuration

/// Create `dictionary` log entry.
///
/// - Parameters:
///   - message: `NSDictionary` for log entry.
///   - details: Additional details which describe data in a provided object.
/// - Returns: Ready-to-use log entry object.
///
+ (instancetype)entryWithMessage:(NSDictionary *)message details:(nullable NSString *)details;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
