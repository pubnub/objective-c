#import "PNLoggerManager.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// Loggers manager module private extension.
@interface PNLoggerManager (Private)


#pragma mark - Initialization and Configuration

/// Create loggers' manager.
///
/// - Parameters:
///   - clientIdentifier: Unique **PubNub** client identifier.
///   - minimumLogLevel: Minimum log entries level to be logged.
///   - loggers: List of additional loggers that should be used along with user-provided custom loggers.
/// - Returns: Ready-to-use loggers' manager.
///
+ (instancetype)managerWithClientIdentifier:(NSString *)clientIdentifier
                                   logLevel:(PNLogLevel)minimumLogLevel
                                 andLoggers:(NSArray<id<PNLogger>> *)loggers;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
