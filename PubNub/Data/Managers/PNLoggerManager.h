#import <Foundation/Foundation.h>
#import <PubNub/PNLogEntry.h>
#import <PubNub/PNLogger.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Loggers manager module.
@interface PNLoggerManager : NSObject


#pragma mark - Properties

/// Configured minimum log entries level.
@property(assign, atomic, readonly) PNLogLevel logLevel;


#pragma mark - Logging

/// Process a `trace` level message.
///
/// - Parameters:
///   - location: Call site from which the log message has been sent.
///   - factoryBlock: Log entry message factory block for lazy message composition.
- (void)traceWithLocation:(NSString *)location andMessageFactory:(PNLogEntry * _Nullable (^)(void))factoryBlock;

/// Process a `trace` level message.
///
/// - Parameters:
///   - location: Call site from which the log message has been sent.
///   - message: Log entry message, which should be passed to the loggers.
- (void)traceWithLocation:(NSString *)location andMessage:(nullable PNLogEntry *)message;

/// Process a `debug` level message.
///
/// - Parameters:
///   - location: Call site from which the log message has been sent.
///   - factoryBlock: Log entry message factory block for lazy message composition.
- (void)debugWithLocation:(NSString *)location andMessageFactory:(PNLogEntry * _Nullable (^)(void))factoryBlock;

/// Process a `debug` level message.
///
/// - Parameters:
///   - location: Call site from which the log message has been sent.
///   - message: Log entry message, which should be passed to the loggers.
- (void)debugWithLocation:(NSString *)location andMessage:(nullable PNLogEntry *)message;

/// Process a `info` level message.
///
/// - Parameters:
///   - location: Call site from which the log message has been sent.
///   - factoryBlock: Log entry message factory block for lazy message composition.
- (void)infoWithLocation:(NSString *)location andMessageFactory:(PNLogEntry * _Nullable (^)(void))factoryBlock;

/// Process a `info` level message.
///
/// - Parameters:
///   - location: Call site from which the log message has been sent.
///   - message: Log entry message, which should be passed to the loggers.
- (void)infoWithLocation:(NSString *)location andMessage:(nullable PNLogEntry *)message;

/// Process a `warn` level message.
///
/// - Parameters:
///   - location: Call site from which the log message has been sent.
///   - factoryBlock: Log entry message factory block for lazy message composition.
- (void)warnWithLocation:(NSString *)location andMessageFactory:(PNLogEntry * _Nullable (^)(void))factoryBlock;

/// Process a `warn` level message.
///
/// - Parameters:
///   - location: Call site from which the log message has been sent.
///   - message: Log entry message, which should be passed to the loggers.
- (void)warnWithLocation:(NSString *)location andMessage:(nullable PNLogEntry *)message;

/// Process a `error` level message.
///
/// - Parameters:
///   - location: Call site from which the log message has been sent.
///   - factoryBlock: Log entry message factory block for lazy message composition.
- (void)errorWithLocation:(NSString *)location andMessageFactory:(PNLogEntry * _Nullable (^)(void))factoryBlock;

/// Process a `error` level message.
///
/// - Parameters:
///   - location: Call site from which the log message has been sent.
///   - message: Log entry message, which should be passed to the loggers.
- (void)errorWithLocation:(NSString *)location andMessage:(nullable PNLogEntry *)message;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
