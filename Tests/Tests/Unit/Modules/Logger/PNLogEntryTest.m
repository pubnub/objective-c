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
#import "PNLogEntry+Private.h"


/// Minimal PNTransportResponse conforming object for testing purposes.
@interface PNTestTransportResponse : NSObject <PNTransportResponse>

@property(strong, nonatomic) NSDictionary<NSString *, NSString *> *headers;
@property(strong, nonatomic) NSInputStream *bodyStream;
@property(strong, nonatomic) NSString *MIMEType;
@property(assign, nonatomic) BOOL bodyStreamAvailable;
@property(strong, nonatomic) NSData *body;
@property(assign, nonatomic) NSUInteger statusCode;
@property(strong, nonatomic) NSString *url;

- (instancetype)initWithURL:(NSString *)url
                 statusCode:(NSUInteger)statusCode
                       body:(nullable NSData *)body
                    headers:(nullable NSDictionary *)headers;

@end


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Log entry data model unit tests.
@interface PNLogEntryTest : XCTestCase

#pragma mark -

@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNLogEntryTest


#pragma mark - Tests :: PNStringLogEntry :: Creation

- (void)testItShouldCreateStringLogEntryWithMessage {
    PNStringLogEntry *entry = [PNStringLogEntry entryWithMessage:@"Test log message"];

    XCTAssertEqualObjects(entry.message, @"Test log message", @"Message should match the provided string.");
    XCTAssertEqual(entry.messageType, PNTextLogMessageType, @"Message type should be PNTextLogMessageType.");
    XCTAssertEqual(entry.operation, PNUnknownLogMessageOperation,
                   @"Default operation should be PNUnknownLogMessageOperation.");
}

- (void)testItShouldCreateStringLogEntryWithTimestamp {
    NSDate *beforeCreation = [NSDate date];
    PNStringLogEntry *entry = [PNStringLogEntry entryWithMessage:@"Test"];
    NSDate *afterCreation = [NSDate date];

    XCTAssertTrue([entry.timestamp compare:beforeCreation] != NSOrderedAscending,
                  @"Timestamp should not be before creation time.");
    XCTAssertTrue([entry.timestamp compare:afterCreation] != NSOrderedDescending,
                  @"Timestamp should not be after creation time.");
}

- (void)testItShouldCreateStringLogEntryWithEmptyMessage {
    PNStringLogEntry *entry = [PNStringLogEntry entryWithMessage:@""];

    XCTAssertEqualObjects(entry.message, @"", @"Message should be an empty string.");
    XCTAssertEqual(entry.messageType, PNTextLogMessageType, @"Message type should be PNTextLogMessageType.");
}


#pragma mark - Tests :: PNStringLogEntry :: Properties set by manager

- (void)testItShouldAcceptLocationSetByManager {
    PNStringLogEntry *entry = [PNStringLogEntry entryWithMessage:@"Test"];
    entry.location = @"PubNub+Core.m:123";

    XCTAssertEqualObjects(entry.location, @"PubNub+Core.m:123",
                          @"Location should match the value set externally.");
}

- (void)testItShouldAcceptPubNubIdSetByManager {
    PNStringLogEntry *entry = [PNStringLogEntry entryWithMessage:@"Test"];
    entry.pubNubId = @"client-abc-123";

    XCTAssertEqualObjects(entry.pubNubId, @"client-abc-123",
                          @"PubNub ID should match the value set externally.");
}

- (void)testItShouldAcceptLogLevelSetByManager {
    PNStringLogEntry *entry = [PNStringLogEntry entryWithMessage:@"Test"];
    entry.logLevel = PNInfoLogLevel;

    XCTAssertEqual(entry.logLevel, PNInfoLogLevel, @"Log level should be PNInfoLogLevel after assignment.");
}

- (void)testItShouldAcceptMinimumLogLevelSetByManager {
    PNStringLogEntry *entry = [PNStringLogEntry entryWithMessage:@"Test"];
    entry.minimumLogLevel = PNDebugLogLevel;

    XCTAssertEqual(entry.minimumLogLevel, PNDebugLogLevel,
                   @"Minimum log level should be PNDebugLogLevel after assignment.");
}


#pragma mark - Tests :: PNDictionaryLogEntry :: Creation

- (void)testItShouldCreateDictionaryLogEntryWithMessageAndDetails {
    NSDictionary *dict = @{ @"key": @"value", @"count": @42 };
    PNDictionaryLogEntry *entry = [PNDictionaryLogEntry entryWithMessage:dict details:@"Some context"];

    XCTAssertEqualObjects(entry.message, dict, @"Message should match the provided dictionary.");
    XCTAssertEqualObjects(entry.details, @"Some context", @"Details should match the provided string.");
    XCTAssertEqual(entry.messageType, PNObjectLogMessageType, @"Message type should be PNObjectLogMessageType.");
    XCTAssertEqual(entry.operation, PNUnknownLogMessageOperation,
                   @"Default operation should be PNUnknownLogMessageOperation.");
}

- (void)testItShouldCreateDictionaryLogEntryWithNilDetails {
    NSDictionary *dict = @{ @"key": @"value" };
    PNDictionaryLogEntry *entry = [PNDictionaryLogEntry entryWithMessage:dict details:nil];

    XCTAssertEqualObjects(entry.message, dict, @"Message should match the provided dictionary.");
    XCTAssertNil(entry.details, @"Details should be nil when nil was provided.");
}

- (void)testItShouldCreateDictionaryLogEntryWithEmptyDictionary {
    NSDictionary *dict = @{};
    PNDictionaryLogEntry *entry = [PNDictionaryLogEntry entryWithMessage:dict details:@"empty dict"];

    XCTAssertEqualObjects(entry.message, dict, @"Message should be an empty dictionary.");
}

- (void)testItShouldCreateDictionaryLogEntryWithNestedDictionary {
    NSDictionary *dict = @{ @"outer": @{ @"inner": @"value" } };
    PNDictionaryLogEntry *entry = [PNDictionaryLogEntry entryWithMessage:dict details:nil];

    XCTAssertEqualObjects(entry.message[@"outer"], (@{ @"inner": @"value" }),
                          @"Nested dictionary should be preserved.");
}


#pragma mark - Tests :: PNErrorLogEntry :: Creation

- (void)testItShouldCreateErrorLogEntryWithError {
    NSError *error = [NSError errorWithDomain:@"com.pubnub.test" code:42 userInfo:@{
        NSLocalizedDescriptionKey: @"Test error occurred"
    }];
    PNErrorLogEntry *entry = [PNErrorLogEntry entryWithMessage:error];

    XCTAssertEqualObjects(entry.message, error, @"Message should match the provided error.");
    XCTAssertEqual(entry.messageType, PNErrorLogMessageType, @"Message type should be PNErrorLogMessageType.");
    XCTAssertEqual(entry.operation, PNUnknownLogMessageOperation,
                   @"Default operation should be PNUnknownLogMessageOperation.");
}

- (void)testItShouldCreateErrorLogEntryWithErrorDomainAndCode {
    NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorTimedOut userInfo:nil];
    PNErrorLogEntry *entry = [PNErrorLogEntry entryWithMessage:error];

    XCTAssertEqualObjects(entry.message.domain, NSURLErrorDomain, @"Error domain should be preserved.");
    XCTAssertEqual(entry.message.code, NSURLErrorTimedOut, @"Error code should be preserved.");
}

- (void)testItShouldCreateErrorLogEntryWithUnderlyingError {
    NSError *underlying = [NSError errorWithDomain:@"com.pubnub.underlying" code:1 userInfo:nil];
    NSError *error = [NSError errorWithDomain:@"com.pubnub.test" code:42 userInfo:@{
        NSUnderlyingErrorKey: underlying
    }];
    PNErrorLogEntry *entry = [PNErrorLogEntry entryWithMessage:error];

    XCTAssertNotNil(entry.message.userInfo[NSUnderlyingErrorKey],
                    @"Underlying error should be preserved in userInfo.");
}


#pragma mark - Tests :: PNNetworkRequestLogEntry :: Creation

- (void)testItShouldCreateNetworkRequestLogEntryWithTransportRequest {
    PNTransportRequest *request = [PNTransportRequest new];
    request.path = @"/v2/subscribe";
    request.origin = @"ps.pndsn.com";

    PNNetworkRequestLogEntry *entry = [PNNetworkRequestLogEntry entryWithMessage:request details:@"Subscribe request"];

    XCTAssertEqualObjects(entry.message, request, @"Message should match the provided transport request.");
    XCTAssertEqualObjects(entry.details, @"Subscribe request", @"Details should match the provided string.");
    XCTAssertEqual(entry.messageType, PNNetworkRequestLogMessageType,
                   @"Message type should be PNNetworkRequestLogMessageType.");
    XCTAssertFalse(entry.isCanceled, @"Canceled flag should be NO by default.");
    XCTAssertFalse(entry.isFailed, @"Failed flag should be NO by default.");
}

- (void)testItShouldCreateNetworkRequestLogEntryWithCancelledFlag {
    PNTransportRequest *request = [PNTransportRequest new];
    request.path = @"/publish/key";
    request.origin = @"ps.pndsn.com";

    PNNetworkRequestLogEntry *entry = [PNNetworkRequestLogEntry entryWithMessage:request
                                                                         details:nil
                                                                        canceled:YES
                                                                          failed:NO];

    XCTAssertTrue(entry.isCanceled, @"Canceled flag should be YES when set.");
    XCTAssertFalse(entry.isFailed, @"Failed flag should be NO when not set.");
}

- (void)testItShouldCreateNetworkRequestLogEntryWithFailedFlag {
    PNTransportRequest *request = [PNTransportRequest new];
    request.path = @"/publish/key";
    request.origin = @"ps.pndsn.com";

    PNNetworkRequestLogEntry *entry = [PNNetworkRequestLogEntry entryWithMessage:request
                                                                         details:nil
                                                                        canceled:NO
                                                                          failed:YES];

    XCTAssertFalse(entry.isCanceled, @"Canceled flag should be NO when not set.");
    XCTAssertTrue(entry.isFailed, @"Failed flag should be YES when set.");
}

- (void)testItShouldCreateNetworkRequestLogEntryWithNilDetails {
    PNTransportRequest *request = [PNTransportRequest new];
    request.path = @"/v2/presence";
    request.origin = @"ps.pndsn.com";

    PNNetworkRequestLogEntry *entry = [PNNetworkRequestLogEntry entryWithMessage:request details:nil];

    XCTAssertNil(entry.details, @"Details should be nil when nil was provided.");
}


#pragma mark - Tests :: PNNetworkResponseLogEntry :: Creation

- (void)testItShouldCreateNetworkResponseLogEntryWithResponse {
    id mockResponse = [self mockTransportResponseWithURL:@"https://ps.pndsn.com/v2/subscribe"
                                             statusCode:200
                                                   body:nil
                                                headers:nil];

    PNNetworkResponseLogEntry *entry = [PNNetworkResponseLogEntry entryWithMessage:mockResponse];

    XCTAssertEqual(entry.messageType, PNNetworkResponseLogMessageType,
                   @"Message type should be PNNetworkResponseLogMessageType.");
}

- (void)testItShouldCreateNetworkResponseLogEntryPreservingResponseURL {
    NSString *expectedURL = @"https://ps.pndsn.com/v2/subscribe?tt=0";
    id mockResponse = [self mockTransportResponseWithURL:expectedURL
                                             statusCode:200
                                                   body:nil
                                                headers:nil];

    PNNetworkResponseLogEntry *entry = [PNNetworkResponseLogEntry entryWithMessage:mockResponse];

    XCTAssertEqualObjects([entry.message url], expectedURL,
                          @"Response URL should be preserved in the log entry.");
}


#pragma mark - Tests :: PNLogEntry :: Operation assignment

- (void)testItShouldAllowOperationToBeSetOnStringEntry {
    PNStringLogEntry *entry = [PNStringLogEntry entryWithMessage:@"subscribe test"];
    entry.operation = PNSubscribeLogMessageOperation;

    XCTAssertEqual(entry.operation, PNSubscribeLogMessageOperation,
                   @"Operation should be PNSubscribeLogMessageOperation after assignment.");
}

- (void)testItShouldAllowOperationToBeSetOnDictionaryEntry {
    PNDictionaryLogEntry *entry = [PNDictionaryLogEntry entryWithMessage:@{} details:nil];
    entry.operation = PNMessageSendLogMessageOperation;

    XCTAssertEqual(entry.operation, PNMessageSendLogMessageOperation,
                   @"Operation should be PNMessageSendLogMessageOperation after assignment.");
}


#pragma mark - Tests :: PNLogEntry :: PreProcessedString caching

- (void)testItShouldStorePreProcessedString {
    PNStringLogEntry *entry = [PNStringLogEntry entryWithMessage:@"Test"];

    XCTAssertNil(entry.preProcessedString, @"Pre-processed string should be nil initially.");

    entry.preProcessedString = @"Formatted output";
    XCTAssertEqualObjects(entry.preProcessedString, @"Formatted output",
                          @"Pre-processed string should be stored after assignment.");
}


#pragma mark - Tests :: PNLogEntry :: Immutability of timestamp

- (void)testItShouldNotChangeTimestampAfterCreation {
    PNStringLogEntry *entry = [PNStringLogEntry entryWithMessage:@"Test"];
    NSDate *firstTimestamp = entry.timestamp;

    // Small delay to ensure time has passed.
    [NSThread sleepForTimeInterval:0.01];

    NSDate *secondTimestamp = entry.timestamp;
    XCTAssertEqualObjects(firstTimestamp, secondTimestamp,
                          @"Timestamp should remain the same after creation.");
}


#pragma mark - Helpers

- (id<PNTransportResponse>)mockTransportResponseWithURL:(NSString *)url
                                             statusCode:(NSUInteger)statusCode
                                                   body:(nullable NSData *)body
                                                headers:(nullable NSDictionary *)headers {
    // Create a simple object conforming to PNTransportResponse using NSProxy or a test double.
    // Since PNTransportResponse is a protocol, we use a simple class that implements it.
    return [[PNTestTransportResponse alloc] initWithURL:url statusCode:statusCode body:body headers:headers];
}

#pragma mark -

@end


#pragma mark - Test transport response helper

@implementation PNTestTransportResponse

- (instancetype)initWithURL:(NSString *)url
                 statusCode:(NSUInteger)statusCode
                       body:(NSData *)body
                    headers:(NSDictionary *)headers {
    if ((self = [super init])) {
        _statusCode = statusCode;
        _headers = headers;
        _body = body;
        _url = url;
    }
    return self;
}

@end
