#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Types

/// Enum with available log levels.
typedef NS_ENUM(NSInteger, PNLogLevel) {
    /// Logging disabled.
    PNNoneLogLevel = -1,
    
    /// Used to notify about every last detail:
    /// - method calls,
    /// - full payloads,
    /// - internal variables,
    /// - state-machine hops.
    PNTraceLogLevel = 0,

    /// Used to notify about broad strokes of your SDK’s logic:
    /// - inputs/outputs to public methods,
    /// - network request
    /// - network response
    /// - decision branches.
    PNDebugLogLevel,

    /// Used to notify summary of what the SDK is doing under the hood:
    /// - initialized,
    /// - connected,
    /// - entity created.
    PNInfoLogLevel,

    /// Used to notify about non-fatal events:
    /// - deprecations,
    /// - request retries.
    PNWarnLogLevel,
    
    /// Used to notify about:
    /// - exceptions,
    /// - HTTP failures,
    /// - invalid states.
    PNErrorLogLevel,
};

/// Enum with known log entry payload types.
typedef NS_ENUM(NSUInteger, PNLogMessageType) {
    /// Log entry `message` field contains `NSString` instance.
    PNTextLogMessageType,
    
    /// Log entry `message` field contains `NSDictionary` instance.
    PNObjectLogMessageType,
    
    /// Log entry `message` field contains `NSError` instance.
    PNErrorLogMessageType,
    
    /// Log entry `message` field contains `PNTransportRequest` instance.
    PNNetworkRequestLogMessageType,
    
    /// Log entry `message` field contains `PNTransportResponse`-compatible instance.
    PNNetworkResponseLogMessageType
};

/// List of known operations for which log message created.
///
/// - Since: 6.0.0
typedef NS_ENUM(NSUInteger, PNLogMessageOperation) {
    /// Unknown operation.
    PNUnknownLogMessageOperation,
    
    /// The operation to send messages.
    PNMessageSendLogMessageOperation,
    
    /// The operation for real-time update retrieval.
    PNSubscribeLogMessageOperation,
    
    /// The operation to access and manage `user_id` presence and fetch channel presence information.
    PNPresenceLogMessageOperation,
    
    /// The operation to access and manage files in channel-specific storage.
    PNFilesLogMessageOperation,
    
    /// The operation to access and manage messages for a specific channel(s) in the persistent storage.
    PNMessageStorageLogMessageOperation,
    
    /// The operation to access and manage channel groups.
    PNChannelGroupsLogMessageOperation,
    
    /// The operation to access and manage device registration for channel push notifications.
    PNDevicePushNotificationsLogMessageOperation,
    
    /// The operation to access and manage App Context objects.
    PNAppContextLogMessageOperation,
    
    /// The operation to access and manage reactions for a specific message.
    PNMessageReactionsLogMessageOperation
};

#pragma mark - Class forwarding

@class PNLogEntry;


#pragma mark - Protocol interface declaration

@protocol PNLogger <NSObject>


#pragma mark - Logging

/// Process a `trace` level message.
///
/// - Parameter message: Log entry message, which should be passed to the loggers.
- (void)traceWithMessage:(PNLogEntry *)message;

/// Process a `debug` level message.
///
/// - Parameter message: Log entry message, which should be passed to the loggers.
- (void)debugWithMessage:(PNLogEntry *)message;

/// Process a `info` level message.
///
/// - Parameter message: Log entry message, which should be passed to the loggers.
- (void)infoWithMessage:(PNLogEntry *)message;

/// Process a `warn` level message.
///
/// - Parameter message: Log entry message, which should be passed to the loggers.
- (void)warnWithMessage:(PNLogEntry *)message;

/// Process a `error` level message.
///
/// - Parameter message: Log entry message, which should be passed to the loggers.
- (void)errorWithMessage:(PNLogEntry *)message;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
