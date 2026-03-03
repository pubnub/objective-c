#import <XCTest/XCTest.h>
#import <PubNub/PNNetworkResponseLogEntry.h>
#import <PubNub/PNNetworkRequestLogEntry.h>
#import <PubNub/PNDictionaryLogEntry.h>
#import <PubNub/PNTransportResponse.h>
#import <PubNub/PNTransportRequest.h>
#import <PubNub/PNStringLogEntry.h>
#import <PubNub/PNErrorLogEntry.h>
#import <PubNub/PNLogEntry.h>
#import <PubNub/PNLogger.h>
#import "PNNetworkResponseLogEntry+Private.h"
#import "PNNetworkRequestLogEntry+Private.h"
#import "PNDictionaryLogEntry+Private.h"
#import "PNStringLogEntry+Private.h"
#import "PNErrorLogEntry+Private.h"
#import "PNTransportRequest+Private.h"
#import "PNLoggerManager+Private.h"
#import "PNLogEntry+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Mock logger

/// Mock logger that records received messages for verification.
@interface PNMockLogger : NSObject <PNLogger>

/// All messages received across all log level methods.
@property(strong, nonatomic, readonly) NSMutableArray<PNLogEntry *> *receivedMessages;

/// Messages received specifically via `traceWithMessage:`.
@property(strong, nonatomic, readonly) NSMutableArray<PNLogEntry *> *traceMessages;

/// Messages received specifically via `debugWithMessage:`.
@property(strong, nonatomic, readonly) NSMutableArray<PNLogEntry *> *debugMessages;

/// Messages received specifically via `infoWithMessage:`.
@property(strong, nonatomic, readonly) NSMutableArray<PNLogEntry *> *infoMessages;

/// Messages received specifically via `warnWithMessage:`.
@property(strong, nonatomic, readonly) NSMutableArray<PNLogEntry *> *warnMessages;

/// Messages received specifically via `errorWithMessage:`.
@property(strong, nonatomic, readonly) NSMutableArray<PNLogEntry *> *errorMessages;

@end


@implementation PNMockLogger

- (instancetype)init {
    if ((self = [super init])) {
        _receivedMessages = [NSMutableArray new];
        _traceMessages = [NSMutableArray new];
        _debugMessages = [NSMutableArray new];
        _infoMessages = [NSMutableArray new];
        _warnMessages = [NSMutableArray new];
        _errorMessages = [NSMutableArray new];
    }
    return self;
}

- (void)traceWithMessage:(PNLogEntry *)message {
    [self.receivedMessages addObject:message];
    [self.traceMessages addObject:message];
}

- (void)debugWithMessage:(PNLogEntry *)message {
    [self.receivedMessages addObject:message];
    [self.debugMessages addObject:message];
}

- (void)infoWithMessage:(PNLogEntry *)message {
    [self.receivedMessages addObject:message];
    [self.infoMessages addObject:message];
}

- (void)warnWithMessage:(PNLogEntry *)message {
    [self.receivedMessages addObject:message];
    [self.warnMessages addObject:message];
}

- (void)errorWithMessage:(PNLogEntry *)message {
    [self.receivedMessages addObject:message];
    [self.errorMessages addObject:message];
}

@end


#pragma mark - Interface declaration

/// Logger manager module unit tests.
@interface PNLoggerManagerTest : XCTestCase

#pragma mark -

@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNLoggerManagerTest


#pragma mark - Tests :: Initialization

- (void)testItShouldCreateManagerWithDefaultConfiguration {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNDebugLogLevel
                                                                 andLoggers:@[logger]];

    XCTAssertEqual(manager.logLevel, PNDebugLogLevel, @"Log level should match the configured value.");
}

- (void)testItShouldCreateManagerWithTraceLogLevel {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNTraceLogLevel
                                                                 andLoggers:@[logger]];

    XCTAssertEqual(manager.logLevel, PNTraceLogLevel, @"Log level should be PNTraceLogLevel.");
}

- (void)testItShouldCreateManagerWithNoneLogLevel {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNNoneLogLevel
                                                                 andLoggers:@[logger]];

    XCTAssertEqual(manager.logLevel, PNNoneLogLevel, @"Log level should be PNNoneLogLevel.");
}

- (void)testItShouldCreateManagerWithEmptyLoggersArray {
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNInfoLogLevel
                                                                 andLoggers:@[]];

}

- (void)testItShouldAllowLogLevelToBeChanged {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNDebugLogLevel
                                                                 andLoggers:@[logger]];

    manager.logLevel = PNErrorLogLevel;
    XCTAssertEqual(manager.logLevel, PNErrorLogLevel, @"Log level should be updated to PNErrorLogLevel.");
}


#pragma mark - Tests :: Trace level logging

- (void)testItShouldForwardTraceMessageToLoggerWhenLogLevelIsTrace {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNTraceLogLevel
                                                                 andLoggers:@[logger]];
    PNStringLogEntry *entry = [PNStringLogEntry entryWithMessage:@"trace message"];

    [manager traceWithLocation:@"TestClass.m:10" andMessage:entry];

    XCTAssertEqual(logger.traceMessages.count, 1, @"Trace logger should receive exactly 1 message.");
    XCTAssertEqualObjects(logger.traceMessages.firstObject, entry,
                          @"The forwarded message should be the same entry.");
}

- (void)testItShouldNotForwardTraceMessageWhenLogLevelIsDebug {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNDebugLogLevel
                                                                 andLoggers:@[logger]];
    PNStringLogEntry *entry = [PNStringLogEntry entryWithMessage:@"trace message"];

    [manager traceWithLocation:@"TestClass.m:10" andMessage:entry];

    XCTAssertEqual(logger.receivedMessages.count, 0,
                   @"No messages should be forwarded when log level is higher than trace.");
}


#pragma mark - Tests :: Debug level logging

- (void)testItShouldForwardDebugMessageWhenLogLevelIsDebug {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNDebugLogLevel
                                                                 andLoggers:@[logger]];
    PNStringLogEntry *entry = [PNStringLogEntry entryWithMessage:@"debug message"];

    [manager debugWithLocation:@"TestClass.m:20" andMessage:entry];

    XCTAssertEqual(logger.debugMessages.count, 1, @"Debug logger should receive exactly 1 message.");
}

- (void)testItShouldForwardDebugMessageWhenLogLevelIsTrace {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNTraceLogLevel
                                                                 andLoggers:@[logger]];
    PNStringLogEntry *entry = [PNStringLogEntry entryWithMessage:@"debug message"];

    [manager debugWithLocation:@"TestClass.m:20" andMessage:entry];

    XCTAssertEqual(logger.debugMessages.count, 1,
                   @"Debug message should be forwarded when log level is lower (trace).");
}

- (void)testItShouldNotForwardDebugMessageWhenLogLevelIsInfo {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNInfoLogLevel
                                                                 andLoggers:@[logger]];
    PNStringLogEntry *entry = [PNStringLogEntry entryWithMessage:@"debug message"];

    [manager debugWithLocation:@"TestClass.m:20" andMessage:entry];

    XCTAssertEqual(logger.receivedMessages.count, 0,
                   @"Debug message should not be forwarded when log level is info.");
}


#pragma mark - Tests :: Info level logging

- (void)testItShouldForwardInfoMessageWhenLogLevelIsInfo {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNInfoLogLevel
                                                                 andLoggers:@[logger]];
    PNStringLogEntry *entry = [PNStringLogEntry entryWithMessage:@"info message"];

    [manager infoWithLocation:@"TestClass.m:30" andMessage:entry];

    XCTAssertEqual(logger.infoMessages.count, 1, @"Info logger should receive exactly 1 message.");
}

- (void)testItShouldNotForwardInfoMessageWhenLogLevelIsWarn {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNWarnLogLevel
                                                                 andLoggers:@[logger]];
    PNStringLogEntry *entry = [PNStringLogEntry entryWithMessage:@"info message"];

    [manager infoWithLocation:@"TestClass.m:30" andMessage:entry];

    XCTAssertEqual(logger.receivedMessages.count, 0,
                   @"Info message should not be forwarded when log level is warn.");
}


#pragma mark - Tests :: Warn level logging

- (void)testItShouldForwardWarnMessageWhenLogLevelIsWarn {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNWarnLogLevel
                                                                 andLoggers:@[logger]];
    PNStringLogEntry *entry = [PNStringLogEntry entryWithMessage:@"warn message"];

    [manager warnWithLocation:@"TestClass.m:40" andMessage:entry];

    XCTAssertEqual(logger.warnMessages.count, 1, @"Warn logger should receive exactly 1 message.");
}

- (void)testItShouldNotForwardWarnMessageWhenLogLevelIsError {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNErrorLogLevel
                                                                 andLoggers:@[logger]];
    PNStringLogEntry *entry = [PNStringLogEntry entryWithMessage:@"warn message"];

    [manager warnWithLocation:@"TestClass.m:40" andMessage:entry];

    XCTAssertEqual(logger.receivedMessages.count, 0,
                   @"Warn message should not be forwarded when log level is error.");
}


#pragma mark - Tests :: Error level logging

- (void)testItShouldForwardErrorMessageWhenLogLevelIsError {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNErrorLogLevel
                                                                 andLoggers:@[logger]];
    NSError *error = [NSError errorWithDomain:@"com.pubnub.test" code:1 userInfo:nil];
    PNErrorLogEntry *entry = [PNErrorLogEntry entryWithMessage:error];

    [manager errorWithLocation:@"TestClass.m:50" andMessage:entry];

    XCTAssertEqual(logger.errorMessages.count, 1, @"Error logger should receive exactly 1 message.");
}

- (void)testItShouldForwardErrorMessageWhenLogLevelIsTrace {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNTraceLogLevel
                                                                 andLoggers:@[logger]];
    NSError *error = [NSError errorWithDomain:@"com.pubnub.test" code:1 userInfo:nil];
    PNErrorLogEntry *entry = [PNErrorLogEntry entryWithMessage:error];

    [manager errorWithLocation:@"TestClass.m:50" andMessage:entry];

    XCTAssertEqual(logger.errorMessages.count, 1,
                   @"Error message should be forwarded when log level is lower (trace).");
}


#pragma mark - Tests :: Multiple loggers

- (void)testItShouldForwardMessageToAllRegisteredLoggers {
    PNMockLogger *logger1 = [PNMockLogger new];
    PNMockLogger *logger2 = [PNMockLogger new];
    PNMockLogger *logger3 = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNInfoLogLevel
                                                                 andLoggers:@[logger1, logger2, logger3]];
    PNStringLogEntry *entry = [PNStringLogEntry entryWithMessage:@"broadcast message"];

    [manager infoWithLocation:@"TestClass.m:60" andMessage:entry];

    XCTAssertEqual(logger1.infoMessages.count, 1, @"Logger 1 should receive the info message.");
    XCTAssertEqual(logger2.infoMessages.count, 1, @"Logger 2 should receive the info message.");
    XCTAssertEqual(logger3.infoMessages.count, 1, @"Logger 3 should receive the info message.");
}

- (void)testItShouldForwardSameEntryInstanceToAllLoggers {
    PNMockLogger *logger1 = [PNMockLogger new];
    PNMockLogger *logger2 = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNDebugLogLevel
                                                                 andLoggers:@[logger1, logger2]];
    PNStringLogEntry *entry = [PNStringLogEntry entryWithMessage:@"shared entry"];

    [manager debugWithLocation:@"TestClass.m:70" andMessage:entry];

    XCTAssertEqual(logger1.debugMessages.firstObject, logger2.debugMessages.firstObject,
                   @"Both loggers should receive the same entry object.");
}


#pragma mark - Tests :: Message enrichment

- (void)testItShouldSetPubNubIdOnMessageWhenLogging {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"client-xyz"
                                                                   logLevel:PNInfoLogLevel
                                                                 andLoggers:@[logger]];
    PNStringLogEntry *entry = [PNStringLogEntry entryWithMessage:@"test"];

    [manager infoWithLocation:@"TestClass.m:80" andMessage:entry];

    XCTAssertEqualObjects(entry.pubNubId, @"client-xyz",
                          @"PubNub ID should be set to the client identifier from the manager.");
}

- (void)testItShouldSetLocationOnMessageWhenLogging {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNInfoLogLevel
                                                                 andLoggers:@[logger]];
    PNStringLogEntry *entry = [PNStringLogEntry entryWithMessage:@"test"];

    [manager infoWithLocation:@"PubNub+Core.m:42" andMessage:entry];

    XCTAssertEqualObjects(entry.location, @"PubNub+Core.m:42",
                          @"Location should be set to the value provided to the log method.");
}

- (void)testItShouldSetLogLevelOnMessageWhenLogging {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNTraceLogLevel
                                                                 andLoggers:@[logger]];
    PNStringLogEntry *entry = [PNStringLogEntry entryWithMessage:@"test"];

    [manager warnWithLocation:@"TestClass.m:90" andMessage:entry];

    XCTAssertEqual(entry.logLevel, PNWarnLogLevel,
                   @"Log level on the entry should match the method used (warn).");
}

- (void)testItShouldSetMinimumLogLevelOnMessageWhenLogging {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNDebugLogLevel
                                                                 andLoggers:@[logger]];
    PNStringLogEntry *entry = [PNStringLogEntry entryWithMessage:@"test"];

    [manager debugWithLocation:@"TestClass.m:100" andMessage:entry];

    XCTAssertEqual(entry.minimumLogLevel, PNDebugLogLevel,
                   @"Minimum log level should be set from the manager's configured level.");
}


#pragma mark - Tests :: Factory block logging

- (void)testItShouldCallFactoryBlockWhenLogLevelPermitsTrace {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNTraceLogLevel
                                                                 andLoggers:@[logger]];
    __block BOOL factoryCalled = NO;

    [manager traceWithLocation:@"TestClass.m:110" andMessageFactory:^PNLogEntry * _Nullable{
        factoryCalled = YES;
        return [PNStringLogEntry entryWithMessage:@"lazy trace"];
    }];

    XCTAssertTrue(factoryCalled, @"Factory block should be called when log level permits trace.");
    XCTAssertEqual(logger.traceMessages.count, 1, @"Trace message from factory should be forwarded.");
}

- (void)testItShouldNotCallFactoryBlockWhenLogLevelDoesNotPermitTrace {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNErrorLogLevel
                                                                 andLoggers:@[logger]];
    __block BOOL factoryCalled = NO;

    [manager traceWithLocation:@"TestClass.m:120" andMessageFactory:^PNLogEntry * _Nullable{
        factoryCalled = YES;
        return [PNStringLogEntry entryWithMessage:@"lazy trace"];
    }];

    XCTAssertFalse(factoryCalled,
                   @"Factory block should NOT be called when log level is higher than trace.");
}

- (void)testItShouldCallDebugFactoryBlockWhenLogLevelPermits {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNDebugLogLevel
                                                                 andLoggers:@[logger]];
    __block BOOL factoryCalled = NO;

    [manager debugWithLocation:@"TestClass.m:130" andMessageFactory:^PNLogEntry * _Nullable{
        factoryCalled = YES;
        return [PNStringLogEntry entryWithMessage:@"lazy debug"];
    }];

    XCTAssertTrue(factoryCalled, @"Debug factory block should be called when log level permits.");
}

- (void)testItShouldNotCallDebugFactoryBlockWhenLogLevelDoesNotPermit {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNInfoLogLevel
                                                                 andLoggers:@[logger]];
    __block BOOL factoryCalled = NO;

    [manager debugWithLocation:@"TestClass.m:140" andMessageFactory:^PNLogEntry * _Nullable{
        factoryCalled = YES;
        return [PNStringLogEntry entryWithMessage:@"lazy debug"];
    }];

    XCTAssertFalse(factoryCalled,
                   @"Debug factory block should NOT be called when log level is higher than debug.");
}

- (void)testItShouldCallInfoFactoryBlockWhenLogLevelPermits {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNInfoLogLevel
                                                                 andLoggers:@[logger]];
    __block BOOL factoryCalled = NO;

    [manager infoWithLocation:@"TestClass.m:150" andMessageFactory:^PNLogEntry * _Nullable{
        factoryCalled = YES;
        return [PNStringLogEntry entryWithMessage:@"lazy info"];
    }];

    XCTAssertTrue(factoryCalled, @"Info factory block should be called when log level permits.");
}

- (void)testItShouldNotCallInfoFactoryBlockWhenLogLevelDoesNotPermit {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNWarnLogLevel
                                                                 andLoggers:@[logger]];
    __block BOOL factoryCalled = NO;

    [manager infoWithLocation:@"TestClass.m:160" andMessageFactory:^PNLogEntry * _Nullable{
        factoryCalled = YES;
        return [PNStringLogEntry entryWithMessage:@"lazy info"];
    }];

    XCTAssertFalse(factoryCalled,
                   @"Info factory block should NOT be called when log level is higher than info.");
}

- (void)testItShouldCallWarnFactoryBlockWhenLogLevelPermits {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNWarnLogLevel
                                                                 andLoggers:@[logger]];
    __block BOOL factoryCalled = NO;

    [manager warnWithLocation:@"TestClass.m:170" andMessageFactory:^PNLogEntry * _Nullable{
        factoryCalled = YES;
        return [PNStringLogEntry entryWithMessage:@"lazy warn"];
    }];

    XCTAssertTrue(factoryCalled, @"Warn factory block should be called when log level permits.");
}

- (void)testItShouldNotCallWarnFactoryBlockWhenLogLevelDoesNotPermit {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNErrorLogLevel
                                                                 andLoggers:@[logger]];
    __block BOOL factoryCalled = NO;

    [manager warnWithLocation:@"TestClass.m:180" andMessageFactory:^PNLogEntry * _Nullable{
        factoryCalled = YES;
        return [PNStringLogEntry entryWithMessage:@"lazy warn"];
    }];

    XCTAssertFalse(factoryCalled,
                   @"Warn factory block should NOT be called when log level is higher than warn.");
}

- (void)testItShouldCallErrorFactoryBlockWhenLogLevelPermits {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNErrorLogLevel
                                                                 andLoggers:@[logger]];
    __block BOOL factoryCalled = NO;

    [manager errorWithLocation:@"TestClass.m:190" andMessageFactory:^PNLogEntry * _Nullable{
        factoryCalled = YES;
        NSError *error = [NSError errorWithDomain:@"test" code:1 userInfo:nil];
        return [PNErrorLogEntry entryWithMessage:error];
    }];

    XCTAssertTrue(factoryCalled, @"Error factory block should be called when log level permits.");
}


#pragma mark - Tests :: Nil message handling

- (void)testItShouldNotForwardNilMessageToLoggers {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNTraceLogLevel
                                                                 andLoggers:@[logger]];

    [manager infoWithLocation:@"TestClass.m:200" andMessage:nil];

    XCTAssertEqual(logger.receivedMessages.count, 0,
                   @"No messages should be forwarded when the message is nil.");
}

- (void)testItShouldNotForwardWhenFactoryReturnsNil {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNTraceLogLevel
                                                                 andLoggers:@[logger]];

    [manager traceWithLocation:@"TestClass.m:210" andMessageFactory:^PNLogEntry * _Nullable{
        return nil;
    }];

    XCTAssertEqual(logger.receivedMessages.count, 0,
                   @"No messages should be forwarded when the factory block returns nil.");
}


#pragma mark - Tests :: No loggers registered

- (void)testItShouldNotCrashWhenLoggingWithNoLoggers {
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNTraceLogLevel
                                                                 andLoggers:@[]];
    PNStringLogEntry *entry = [PNStringLogEntry entryWithMessage:@"no loggers"];

    XCTAssertNoThrow([manager infoWithLocation:@"TestClass.m:220" andMessage:entry],
                     @"Logging with no loggers should not throw or crash.");
}


#pragma mark - Tests :: None log level

- (void)testItShouldNotForwardAnyMessageWhenLogLevelIsNone {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNNoneLogLevel
                                                                 andLoggers:@[logger]];

    [manager traceWithLocation:@"T" andMessage:[PNStringLogEntry entryWithMessage:@"t"]];
    [manager debugWithLocation:@"T" andMessage:[PNStringLogEntry entryWithMessage:@"d"]];
    [manager infoWithLocation:@"T" andMessage:[PNStringLogEntry entryWithMessage:@"i"]];
    [manager warnWithLocation:@"T" andMessage:[PNStringLogEntry entryWithMessage:@"w"]];
    [manager errorWithLocation:@"T" andMessage:[PNErrorLogEntry entryWithMessage:
        [NSError errorWithDomain:@"test" code:1 userInfo:nil]]];

    XCTAssertEqual(logger.receivedMessages.count, 0,
                   @"No messages should be forwarded when log level is PNNoneLogLevel.");
}


#pragma mark - Tests :: Operation detection from path

- (void)testItShouldDetectSubscribeOperationForSubscribePath {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNTraceLogLevel
                                                                 andLoggers:@[logger]];

    PNTransportRequest *request = [PNTransportRequest new];
    request.path = @"/v2/subscribe/sub-key/channel/0";
    request.origin = @"ps.pndsn.com";
    PNNetworkRequestLogEntry *entry = [PNNetworkRequestLogEntry entryWithMessage:request details:nil];

    [manager debugWithLocation:@"Transport" andMessage:entry];

    XCTAssertEqual(entry.operation, PNSubscribeLogMessageOperation,
                   @"Operation should be detected as subscribe based on the path.");
}

- (void)testItShouldDetectPublishOperationForPublishPath {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNTraceLogLevel
                                                                 andLoggers:@[logger]];

    PNTransportRequest *request = [PNTransportRequest new];
    request.path = @"/publish/pub-key/sub-key/0/channel/0";
    request.origin = @"ps.pndsn.com";
    PNNetworkRequestLogEntry *entry = [PNNetworkRequestLogEntry entryWithMessage:request details:nil];

    [manager debugWithLocation:@"Transport" andMessage:entry];

    XCTAssertEqual(entry.operation, PNMessageSendLogMessageOperation,
                   @"Operation should be detected as message send for publish path.");
}

- (void)testItShouldDetectSignalOperationForSignalPath {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNTraceLogLevel
                                                                 andLoggers:@[logger]];

    PNTransportRequest *request = [PNTransportRequest new];
    request.path = @"/signal/pub-key/sub-key/0/channel/0";
    request.origin = @"ps.pndsn.com";
    PNNetworkRequestLogEntry *entry = [PNNetworkRequestLogEntry entryWithMessage:request details:nil];

    [manager debugWithLocation:@"Transport" andMessage:entry];

    XCTAssertEqual(entry.operation, PNMessageSendLogMessageOperation,
                   @"Operation should be detected as message send for signal path.");
}

- (void)testItShouldDetectPresenceOperationForPresencePath {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNTraceLogLevel
                                                                 andLoggers:@[logger]];

    PNTransportRequest *request = [PNTransportRequest new];
    request.path = @"/v2/presence/sub-key/channel";
    request.origin = @"ps.pndsn.com";
    PNNetworkRequestLogEntry *entry = [PNNetworkRequestLogEntry entryWithMessage:request details:nil];

    [manager debugWithLocation:@"Transport" andMessage:entry];

    XCTAssertEqual(entry.operation, PNPresenceLogMessageOperation,
                   @"Operation should be detected as presence for presence path.");
}

- (void)testItShouldDetectHistoryOperationForV2HistoryPath {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNTraceLogLevel
                                                                 andLoggers:@[logger]];

    PNTransportRequest *request = [PNTransportRequest new];
    request.path = @"/v2/history/sub-key/channel";
    request.origin = @"ps.pndsn.com";
    PNNetworkRequestLogEntry *entry = [PNNetworkRequestLogEntry entryWithMessage:request details:nil];

    [manager debugWithLocation:@"Transport" andMessage:entry];

    XCTAssertEqual(entry.operation, PNMessageStorageLogMessageOperation,
                   @"Operation should be detected as message storage for v2 history path.");
}

- (void)testItShouldDetectHistoryOperationForV3HistoryPath {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNTraceLogLevel
                                                                 andLoggers:@[logger]];

    PNTransportRequest *request = [PNTransportRequest new];
    request.path = @"/v3/history/sub-key/channel";
    request.origin = @"ps.pndsn.com";
    PNNetworkRequestLogEntry *entry = [PNNetworkRequestLogEntry entryWithMessage:request details:nil];

    [manager debugWithLocation:@"Transport" andMessage:entry];

    XCTAssertEqual(entry.operation, PNMessageStorageLogMessageOperation,
                   @"Operation should be detected as message storage for v3 history path.");
}

- (void)testItShouldDetectMessageActionsOperationForPath {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNTraceLogLevel
                                                                 andLoggers:@[logger]];

    PNTransportRequest *request = [PNTransportRequest new];
    request.path = @"/v1/message-actions/sub-key/channel";
    request.origin = @"ps.pndsn.com";
    PNNetworkRequestLogEntry *entry = [PNNetworkRequestLogEntry entryWithMessage:request details:nil];

    [manager debugWithLocation:@"Transport" andMessage:entry];

    XCTAssertEqual(entry.operation, PNMessageReactionsLogMessageOperation,
                   @"Operation should be detected as message reactions for message-actions path.");
}

- (void)testItShouldDetectChannelGroupsOperationForPath {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNTraceLogLevel
                                                                 andLoggers:@[logger]];

    PNTransportRequest *request = [PNTransportRequest new];
    request.path = @"/v1/channel-registration/sub-key/channel-group";
    request.origin = @"ps.pndsn.com";
    PNNetworkRequestLogEntry *entry = [PNNetworkRequestLogEntry entryWithMessage:request details:nil];

    [manager debugWithLocation:@"Transport" andMessage:entry];

    XCTAssertEqual(entry.operation, PNChannelGroupsLogMessageOperation,
                   @"Operation should be detected as channel groups for channel-registration path.");
}

- (void)testItShouldDetectAppContextOperationForPath {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNTraceLogLevel
                                                                 andLoggers:@[logger]];

    PNTransportRequest *request = [PNTransportRequest new];
    request.path = @"/v2/objects/sub-key/uuid";
    request.origin = @"ps.pndsn.com";
    PNNetworkRequestLogEntry *entry = [PNNetworkRequestLogEntry entryWithMessage:request details:nil];

    [manager debugWithLocation:@"Transport" andMessage:entry];

    XCTAssertEqual(entry.operation, PNAppContextLogMessageOperation,
                   @"Operation should be detected as app context for objects path.");
}

- (void)testItShouldDetectPushOperationForV1PushPath {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNTraceLogLevel
                                                                 andLoggers:@[logger]];

    PNTransportRequest *request = [PNTransportRequest new];
    request.path = @"/v1/push/sub-key/devices/token";
    request.origin = @"ps.pndsn.com";
    PNNetworkRequestLogEntry *entry = [PNNetworkRequestLogEntry entryWithMessage:request details:nil];

    [manager debugWithLocation:@"Transport" andMessage:entry];

    XCTAssertEqual(entry.operation, PNDevicePushNotificationsLogMessageOperation,
                   @"Operation should be detected as push notifications for v1 push path.");
}

- (void)testItShouldDetectPushOperationForV2PushPath {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNTraceLogLevel
                                                                 andLoggers:@[logger]];

    PNTransportRequest *request = [PNTransportRequest new];
    request.path = @"/v2/push/sub-key/devices/token";
    request.origin = @"ps.pndsn.com";
    PNNetworkRequestLogEntry *entry = [PNNetworkRequestLogEntry entryWithMessage:request details:nil];

    [manager debugWithLocation:@"Transport" andMessage:entry];

    XCTAssertEqual(entry.operation, PNDevicePushNotificationsLogMessageOperation,
                   @"Operation should be detected as push notifications for v2 push path.");
}

- (void)testItShouldDetectFilesOperationForPath {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNTraceLogLevel
                                                                 andLoggers:@[logger]];

    PNTransportRequest *request = [PNTransportRequest new];
    request.path = @"/v1/files/sub-key/channels/channel/files";
    request.origin = @"ps.pndsn.com";
    PNNetworkRequestLogEntry *entry = [PNNetworkRequestLogEntry entryWithMessage:request details:nil];

    [manager debugWithLocation:@"Transport" andMessage:entry];

    XCTAssertEqual(entry.operation, PNFilesLogMessageOperation,
                   @"Operation should be detected as files for files path.");
}

- (void)testItShouldReturnUnknownOperationForUnrecognizedPath {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNTraceLogLevel
                                                                 andLoggers:@[logger]];

    PNTransportRequest *request = [PNTransportRequest new];
    request.path = @"/v99/unknown/endpoint";
    request.origin = @"ps.pndsn.com";
    PNNetworkRequestLogEntry *entry = [PNNetworkRequestLogEntry entryWithMessage:request details:nil];

    [manager debugWithLocation:@"Transport" andMessage:entry];

    XCTAssertEqual(entry.operation, PNUnknownLogMessageOperation,
                   @"Operation should remain unknown for unrecognized paths.");
}

- (void)testItShouldNotOverrideExplicitlySetOperation {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNTraceLogLevel
                                                                 andLoggers:@[logger]];

    PNTransportRequest *request = [PNTransportRequest new];
    request.path = @"/v2/subscribe/sub-key/channel/0";
    request.origin = @"ps.pndsn.com";
    PNNetworkRequestLogEntry *entry = [PNNetworkRequestLogEntry entryWithMessage:request details:nil];
    entry.operation = PNMessageSendLogMessageOperation;

    [manager debugWithLocation:@"Transport" andMessage:entry];

    XCTAssertEqual(entry.operation, PNMessageSendLogMessageOperation,
                   @"Explicitly set operation should not be overridden by path-based detection.");
}


#pragma mark - Tests :: Log level hierarchy

- (void)testItShouldForwardAllLevelsWhenLogLevelIsTrace {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNTraceLogLevel
                                                                 andLoggers:@[logger]];
    NSError *error = [NSError errorWithDomain:@"test" code:1 userInfo:nil];

    [manager traceWithLocation:@"T" andMessage:[PNStringLogEntry entryWithMessage:@"t"]];
    [manager debugWithLocation:@"T" andMessage:[PNStringLogEntry entryWithMessage:@"d"]];
    [manager infoWithLocation:@"T" andMessage:[PNStringLogEntry entryWithMessage:@"i"]];
    [manager warnWithLocation:@"T" andMessage:[PNStringLogEntry entryWithMessage:@"w"]];
    [manager errorWithLocation:@"T" andMessage:[PNErrorLogEntry entryWithMessage:error]];

    XCTAssertEqual(logger.receivedMessages.count, 5,
                   @"All 5 messages should be forwarded when log level is trace.");
    XCTAssertEqual(logger.traceMessages.count, 1, @"Exactly 1 trace message should be received.");
    XCTAssertEqual(logger.debugMessages.count, 1, @"Exactly 1 debug message should be received.");
    XCTAssertEqual(logger.infoMessages.count, 1, @"Exactly 1 info message should be received.");
    XCTAssertEqual(logger.warnMessages.count, 1, @"Exactly 1 warn message should be received.");
    XCTAssertEqual(logger.errorMessages.count, 1, @"Exactly 1 error message should be received.");
}

- (void)testItShouldOnlyForwardErrorWhenLogLevelIsError {
    PNMockLogger *logger = [PNMockLogger new];
    PNLoggerManager *manager = [PNLoggerManager managerWithClientIdentifier:@"test-client"
                                                                   logLevel:PNErrorLogLevel
                                                                 andLoggers:@[logger]];
    NSError *error = [NSError errorWithDomain:@"test" code:1 userInfo:nil];

    [manager traceWithLocation:@"T" andMessage:[PNStringLogEntry entryWithMessage:@"t"]];
    [manager debugWithLocation:@"T" andMessage:[PNStringLogEntry entryWithMessage:@"d"]];
    [manager infoWithLocation:@"T" andMessage:[PNStringLogEntry entryWithMessage:@"i"]];
    [manager warnWithLocation:@"T" andMessage:[PNStringLogEntry entryWithMessage:@"w"]];
    [manager errorWithLocation:@"T" andMessage:[PNErrorLogEntry entryWithMessage:error]];

    XCTAssertEqual(logger.receivedMessages.count, 1,
                   @"Only 1 message should be forwarded when log level is error.");
    XCTAssertEqual(logger.errorMessages.count, 1, @"Only the error message should be received.");
}


#pragma mark -

@end
