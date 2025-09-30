#import "PNLoggerManager+Private.h"
#import "PNNetworkResponseLogEntry.h"
#import "PNNetworkRequestLogEntry.h"
#import "PNLogEntry+Private.h"
#import "PNStructures.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// Loggers' manager private extension.
@interface PNLoggerManager ()


#pragma mark - Properties

/// List of additional loggers that should be used along with user-provided custom loggers.
@property(copy, nonatomic) NSArray<id<PNLogger>> *loggers;

/// Unique **PubNub** client identifier.
@property(copy, nonatomic) NSString *clientIdentifier;

/// Configured minimum log entries level.
@property(assign, atomic) PNLogLevel logLevel;


#pragma mark - Initialization and Configuration

/// Initialize loggers' manager.
///
/// - Parameters:
///   - clientIdentifier: Unique **PubNub** client identifier.
///   - minimumLogLevel: Minimum log entries level to be logged.
///   - loggers: List of additional loggers that should be used along with user-provided custom loggers.
/// - Returns: Initialized loggers' manager.
///
- (instancetype)initWithClientIdentifier:(NSString *)clientIdentifier
                                logLevel:(PNLogLevel)minimumLogLevel
                              andLoggers:(NSArray<id<PNLogger>> *)loggers;


#pragma mark - Logging

/// Log message entry.
///
/// - Parameters:
///   - logLevel: Log entry level under which it should be processed.
///   - location: Call site from which the log message has been sent.
///   - message: Log entry message, which should be passed to the loggers.
- (void)logWithLevel:(PNLogLevel)logLevel location:(NSString *)location andMessage:(nullable PNLogEntry *)message;


#pragma mark - Helpers

/// Identify operation for transport request / response log entries.
///
/// - Parameter message: Message object which may contain transport request / response payload.
/// - Returns: Log operation.
- (PNLogMessageOperation)logOperationFromMessage:(PNLogEntry *)message;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNLoggerManager


#pragma mark - Initialization and Configuration

+ (instancetype)managerWithClientIdentifier:(NSString *)clientIdentifier
                                   logLevel:(PNLogLevel)minimumLogLevel
                                 andLoggers:(NSArray<id<PNLogger>> *)loggers {
    return [[self alloc] initWithClientIdentifier:clientIdentifier logLevel:minimumLogLevel andLoggers:loggers];
}

- (instancetype)initWithClientIdentifier:(NSString *)clientIdentifier
                                logLevel:(PNLogLevel)minimumLogLevel
                              andLoggers:(NSArray<id<PNLogger>> *)loggers {
    if ((self = [super init])) {
        _clientIdentifier = [clientIdentifier copy];
        _logLevel = minimumLogLevel;
        _loggers = [loggers copy];
    }
    
    return self;
}


#pragma mark - Logging

- (void)traceWithLocation:(NSString *)location andMessageFactory:(PNLogEntry * (^)(void))factoryBlock {
    if (self.logLevel > PNTraceLogLevel) return;
    
    [self traceWithLocation:location andMessage:factoryBlock()];
}

- (void)traceWithLocation:(NSString *)location andMessage:(PNLogEntry *)message {
    [self logWithLevel:PNTraceLogLevel location:location andMessage:message];
}

- (void)debugWithLocation:(NSString *)location andMessageFactory:(PNLogEntry * (^)(void))factoryBlock {
    if (self.logLevel > PNDebugLogLevel) return;
    
    [self debugWithLocation:location andMessage:factoryBlock()];
}

- (void)debugWithLocation:(NSString *)location andMessage:(PNLogEntry *)message {
    [self logWithLevel:PNDebugLogLevel location:location andMessage:message];
}

- (void)infoWithLocation:(NSString *)location andMessageFactory:(PNLogEntry * (^)(void))factoryBlock {
    if (self.logLevel > PNInfoLogLevel) return;
    
    [self infoWithLocation:location andMessage:factoryBlock()];
}

- (void)infoWithLocation:(NSString *)location andMessage:(PNLogEntry *)message {
    [self logWithLevel:PNInfoLogLevel location:location andMessage:message];
}

- (void)warnWithLocation:(NSString *)location andMessageFactory:(PNLogEntry * (^)(void))factoryBlock {
    if (self.logLevel > PNWarnLogLevel) return;
    
    [self warnWithLocation:location andMessage:factoryBlock()];
}

- (void)warnWithLocation:(NSString *)location andMessage:(PNLogEntry *)message {
    [self logWithLevel:PNWarnLogLevel location:location andMessage:message];
}

- (void)errorWithLocation:(NSString *)location andMessageFactory:(PNLogEntry * (^)(void))factoryBlock {
    if (self.logLevel > PNErrorLogLevel) return;
    
    [self errorWithLocation:location andMessage:factoryBlock()];
}

- (void)errorWithLocation:(NSString *)location andMessage:(PNLogEntry *)message {
    [self logWithLevel:PNErrorLogLevel location:location andMessage:message];
}

- (void)logWithLevel:(PNLogLevel)logLevel location:(NSString *)location andMessage:(PNLogEntry *)message {
    if (!message || self.logLevel == PNNoneLogLevel || logLevel < self.logLevel || self.loggers.count == 0) return;
    
    message.pubNubId = self.clientIdentifier;
    message.minimumLogLevel = self.logLevel;
    message.location = [location copy];
    message.logLevel = logLevel;
    
    // Assign operation for network request / response log messages.
    if (message.operation == PNUnknownLogMessageOperation) message.operation = [self logOperationFromMessage:message];
    
    for (id<PNLogger> logger in self.loggers) {
        if (message.logLevel == PNTraceLogLevel) [logger traceWithMessage:message];
        else if (message.logLevel == PNDebugLogLevel) [logger debugWithMessage:message];
        else if (message.logLevel == PNInfoLogLevel) [logger infoWithMessage:message];
        else if (message.logLevel == PNWarnLogLevel) [logger warnWithMessage:message];
        else if (message.logLevel == PNErrorLogLevel) [logger errorWithMessage:message];
    }
}


#pragma mark - Helpers

- (PNLogMessageOperation)logOperationFromMessage:(PNLogEntry *)message {
    PNLogMessageOperation endpoint = PNUnknownLogMessageOperation;
    PNLogMessageType messageType = message.messageType;
    if (messageType != PNNetworkRequestLogMessageType && messageType != PNNetworkResponseLogMessageType)
        return endpoint;
    
    NSString *path = nil;
    
    if (messageType == PNNetworkRequestLogMessageType) path = ((PNNetworkRequestLogEntry *)message).message.path;
    else {
        NSString *url = ((PNNetworkResponseLogEntry *)message).message.url;
        if (url) path = [NSURL URLWithString:url].path;
    }
    
    if (!path) return endpoint;
    
    if ([path hasPrefix:@"/v2/subscribe"]) endpoint = PNSubscribeLogMessageOperation;
    else if ([path hasPrefix:@"/publish/"] || [path hasPrefix:@"/signal/"]) endpoint = PNMessageSendLogMessageOperation;
    else if ([path hasPrefix:@"/v2/presence"]) endpoint = PNPresenceLogMessageOperation;
    else if ([path hasPrefix:@"/v2/history/"] || [path hasPrefix:@"/v3/history"])
        endpoint = PNMessageStorageLogMessageOperation;
    else if ([path hasPrefix:@"/v1/message-actions/"]) endpoint = PNMessageReactionsLogMessageOperation;
    else if ([path hasPrefix:@"/v1/channel-registration/"]) endpoint = PNChannelGroupsLogMessageOperation;
    else if ([path hasPrefix:@"/v2/objects/"]) endpoint = PNAppContextLogMessageOperation;
    else if ([path hasPrefix:@"/v1/push/"] || [path hasPrefix:@"/v2/push/"]) {
        endpoint = PNDevicePushNotificationsLogMessageOperation;
    } else if ([path hasPrefix:@"/v1/files/"]) {
        endpoint = PNFilesLogMessageOperation;
    }
    
    return endpoint;
}

#pragma mark -

@end
