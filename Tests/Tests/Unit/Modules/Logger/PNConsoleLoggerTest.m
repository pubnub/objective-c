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
#import "PNConsoleLogger.h"
#import "PNLogEntry+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Console logger unit tests.
@interface PNConsoleLoggerTest : XCTestCase

#pragma mark -

@end

/// Minimal PNTransportResponse conforming object for testing purposes.
@interface PNConsoleTestTransportResponse : NSObject <PNTransportResponse>

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

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNConsoleLoggerTest


#pragma mark - Tests :: Creation

- (void)testItShouldCreateConsoleLoggerInstance {
    PNConsoleLogger *logger = [PNConsoleLogger new];

}

- (void)testItShouldConformToPNLoggerProtocol {
    PNConsoleLogger *logger = [PNConsoleLogger new];

    XCTAssertTrue([logger conformsToProtocol:@protocol(PNLogger)],
                  @"Console logger should conform to PNLogger protocol.");
}


#pragma mark - Tests :: PNLogger protocol methods

- (void)testItShouldRespondToTraceWithMessage {
    PNConsoleLogger *logger = [PNConsoleLogger new];

    XCTAssertTrue([logger respondsToSelector:@selector(traceWithMessage:)],
                  @"Console logger should respond to traceWithMessage:.");
}

- (void)testItShouldRespondToDebugWithMessage {
    PNConsoleLogger *logger = [PNConsoleLogger new];

    XCTAssertTrue([logger respondsToSelector:@selector(debugWithMessage:)],
                  @"Console logger should respond to debugWithMessage:.");
}

- (void)testItShouldRespondToInfoWithMessage {
    PNConsoleLogger *logger = [PNConsoleLogger new];

    XCTAssertTrue([logger respondsToSelector:@selector(infoWithMessage:)],
                  @"Console logger should respond to infoWithMessage:.");
}

- (void)testItShouldRespondToWarnWithMessage {
    PNConsoleLogger *logger = [PNConsoleLogger new];

    XCTAssertTrue([logger respondsToSelector:@selector(warnWithMessage:)],
                  @"Console logger should respond to warnWithMessage:.");
}

- (void)testItShouldRespondToErrorWithMessage {
    PNConsoleLogger *logger = [PNConsoleLogger new];

    XCTAssertTrue([logger respondsToSelector:@selector(errorWithMessage:)],
                  @"Console logger should respond to errorWithMessage:.");
}


#pragma mark - Tests :: Stringification :: String entries

- (void)testItShouldStringifyStringLogEntry {
    PNStringLogEntry *entry = [PNStringLogEntry entryWithMessage:@"Hello, World!"];
    entry.pubNubId = @"client-123";
    entry.location = @"PubNub+Core.m:42";
    entry.logLevel = PNInfoLogLevel;

    NSString *result = [PNConsoleLogger stringifiedLogEntry:entry];

    XCTAssertTrue([result containsString:@"PubNub-client-123"],
                  @"Output should contain the PubNub client identifier.");
    XCTAssertTrue([result containsString:@"PubNub+Core.m:42"],
                  @"Output should contain the location.");
    XCTAssertTrue([result containsString:@"Hello, World!"],
                  @"Output should contain the original message text.");
    XCTAssertTrue([result containsString:@"INFO"],
                  @"Output should contain the INFO log level label.");
}

- (void)testItShouldStringifyStringLogEntryWithTraceLevel {
    PNStringLogEntry *entry = [PNStringLogEntry entryWithMessage:@"Trace test"];
    entry.pubNubId = @"client-1";
    entry.location = @"Test.m:1";
    entry.logLevel = PNTraceLogLevel;

    NSString *result = [PNConsoleLogger stringifiedLogEntry:entry];

    XCTAssertTrue([result containsString:@"TRACE"],
                  @"Output should contain the TRACE log level label.");
}

- (void)testItShouldStringifyStringLogEntryWithDebugLevel {
    PNStringLogEntry *entry = [PNStringLogEntry entryWithMessage:@"Debug test"];
    entry.pubNubId = @"client-1";
    entry.location = @"Test.m:1";
    entry.logLevel = PNDebugLogLevel;

    NSString *result = [PNConsoleLogger stringifiedLogEntry:entry];

    XCTAssertTrue([result containsString:@"DEBUG"],
                  @"Output should contain the DEBUG log level label.");
}

- (void)testItShouldStringifyStringLogEntryWithWarnLevel {
    PNStringLogEntry *entry = [PNStringLogEntry entryWithMessage:@"Warn test"];
    entry.pubNubId = @"client-1";
    entry.location = @"Test.m:1";
    entry.logLevel = PNWarnLogLevel;

    NSString *result = [PNConsoleLogger stringifiedLogEntry:entry];

    XCTAssertTrue([result containsString:@"WARN"],
                  @"Output should contain the WARN log level label.");
}

- (void)testItShouldStringifyStringLogEntryWithErrorLevel {
    PNStringLogEntry *entry = [PNStringLogEntry entryWithMessage:@"Error test"];
    entry.pubNubId = @"client-1";
    entry.location = @"Test.m:1";
    entry.logLevel = PNErrorLogLevel;

    NSString *result = [PNConsoleLogger stringifiedLogEntry:entry];

    XCTAssertTrue([result containsString:@"ERROR"],
                  @"Output should contain the ERROR log level label.");
}

- (void)testItShouldStringifyNoneLogLevelAsUnknown {
    PNStringLogEntry *entry = [PNStringLogEntry entryWithMessage:@"None test"];
    entry.pubNubId = @"client-1";
    entry.location = @"Test.m:1";
    entry.logLevel = PNNoneLogLevel;

    NSString *result = [PNConsoleLogger stringifiedLogEntry:entry];

    XCTAssertTrue([result containsString:@"UNKNW"],
                  @"Output should contain UNKNW for PNNoneLogLevel.");
}


#pragma mark - Tests :: Stringification :: Dictionary entries

- (void)testItShouldStringifyDictionaryLogEntry {
    NSDictionary *dict = @{ @"key": @"value" };
    PNDictionaryLogEntry *entry = [PNDictionaryLogEntry entryWithMessage:dict details:@"Test context"];
    entry.pubNubId = @"client-1";
    entry.location = @"Test.m:1";
    entry.logLevel = PNDebugLogLevel;

    NSString *result = [PNConsoleLogger stringifiedLogEntry:entry];

    XCTAssertTrue([result containsString:@"Test context"],
                  @"Output should contain the details string.");
    XCTAssertTrue([result containsString:@"key"],
                  @"Output should contain the dictionary key.");
    XCTAssertTrue([result containsString:@"value"],
                  @"Output should contain the dictionary value.");
}

- (void)testItShouldStringifyDictionaryLogEntryWithNilDetails {
    NSDictionary *dict = @{ @"status": @"ok" };
    PNDictionaryLogEntry *entry = [PNDictionaryLogEntry entryWithMessage:dict details:nil];
    entry.pubNubId = @"client-1";
    entry.location = @"Test.m:1";
    entry.logLevel = PNDebugLogLevel;

    NSString *result = [PNConsoleLogger stringifiedLogEntry:entry];

    XCTAssertTrue([result containsString:@"status"],
                  @"Output should contain the dictionary key.");
}

- (void)testItShouldStringifyEmptyDictionary {
    NSDictionary *dict = @{};
    PNDictionaryLogEntry *entry = [PNDictionaryLogEntry entryWithMessage:dict details:nil];
    entry.pubNubId = @"client-1";
    entry.location = @"Test.m:1";
    entry.logLevel = PNInfoLogLevel;

    NSString *result = [PNConsoleLogger stringifiedLogEntry:entry];

    XCTAssertTrue([result containsString:@"{}"],
                  @"Output should contain '{}' for an empty dictionary.");
}

- (void)testItShouldStringifyDictionaryWithBooleanValues {
    NSDictionary *dict = @{ @"enabled": @YES, @"disabled": @NO };
    PNDictionaryLogEntry *entry = [PNDictionaryLogEntry entryWithMessage:dict details:nil];
    entry.pubNubId = @"client-1";
    entry.location = @"Test.m:1";
    entry.logLevel = PNInfoLogLevel;

    NSString *result = [PNConsoleLogger stringifiedLogEntry:entry];

    XCTAssertTrue([result containsString:@"YES"] || [result containsString:@"NO"],
                  @"Boolean values should be stringified as YES/NO.");
}

- (void)testItShouldStringifyNestedDictionary {
    NSDictionary *dict = @{ @"outer": @{ @"inner": @"value" } };
    PNDictionaryLogEntry *entry = [PNDictionaryLogEntry entryWithMessage:dict details:nil];
    entry.pubNubId = @"client-1";
    entry.location = @"Test.m:1";
    entry.logLevel = PNInfoLogLevel;

    NSString *result = [PNConsoleLogger stringifiedLogEntry:entry];

    XCTAssertTrue([result containsString:@"inner"],
                  @"Output should contain nested dictionary key.");
    XCTAssertTrue([result containsString:@"value"],
                  @"Output should contain nested dictionary value.");
}


#pragma mark - Tests :: Stringification :: Error entries

- (void)testItShouldStringifyErrorLogEntry {
    NSError *error = [NSError errorWithDomain:@"com.pubnub.test" code:42 userInfo:@{
        NSLocalizedDescriptionKey: @"Something went wrong"
    }];
    PNErrorLogEntry *entry = [PNErrorLogEntry entryWithMessage:error];
    entry.pubNubId = @"client-1";
    entry.location = @"Test.m:1";
    entry.logLevel = PNErrorLogLevel;

    NSString *result = [PNConsoleLogger stringifiedLogEntry:entry];

    XCTAssertTrue([result containsString:@"com.pubnub.test"],
                  @"Output should contain the error domain.");
    XCTAssertTrue([result containsString:@"42"],
                  @"Output should contain the error code.");
    XCTAssertTrue([result containsString:@"Something went wrong"],
                  @"Output should contain the error description.");
}

- (void)testItShouldStringifyErrorWithFailureReason {
    NSError *error = [NSError errorWithDomain:@"com.pubnub.test" code:1 userInfo:@{
        NSLocalizedDescriptionKey: @"Request failed",
        NSLocalizedFailureReasonErrorKey: @"Network timeout"
    }];
    PNErrorLogEntry *entry = [PNErrorLogEntry entryWithMessage:error];
    entry.pubNubId = @"client-1";
    entry.location = @"Test.m:1";
    entry.logLevel = PNErrorLogLevel;

    NSString *result = [PNConsoleLogger stringifiedLogEntry:entry];

    XCTAssertTrue([result containsString:@"Network timeout"],
                  @"Output should contain the failure reason.");
}

- (void)testItShouldStringifyErrorWithRecoverySuggestion {
    NSError *error = [NSError errorWithDomain:@"com.pubnub.test" code:1 userInfo:@{
        NSLocalizedDescriptionKey: @"Auth failed",
        NSLocalizedRecoverySuggestionErrorKey: @"Check your credentials"
    }];
    PNErrorLogEntry *entry = [PNErrorLogEntry entryWithMessage:error];
    entry.pubNubId = @"client-1";
    entry.location = @"Test.m:1";
    entry.logLevel = PNErrorLogLevel;

    NSString *result = [PNConsoleLogger stringifiedLogEntry:entry];

    XCTAssertTrue([result containsString:@"Check your credentials"],
                  @"Output should contain the recovery suggestion.");
}

- (void)testItShouldStringifyErrorWithUnderlyingError {
    NSError *underlying = [NSError errorWithDomain:@"com.pubnub.underlying" code:99 userInfo:@{
        NSLocalizedDescriptionKey: @"Root cause"
    }];
    NSError *error = [NSError errorWithDomain:@"com.pubnub.test" code:1 userInfo:@{
        NSLocalizedDescriptionKey: @"Outer error",
        NSUnderlyingErrorKey: underlying
    }];
    PNErrorLogEntry *entry = [PNErrorLogEntry entryWithMessage:error];
    entry.pubNubId = @"client-1";
    entry.location = @"Test.m:1";
    entry.logLevel = PNErrorLogLevel;

    NSString *result = [PNConsoleLogger stringifiedLogEntry:entry];

    XCTAssertTrue([result containsString:@"com.pubnub.underlying"],
                  @"Output should contain the underlying error domain.");
}

- (void)testItShouldStringifyErrorWithNoUserInfo {
    NSError *error = [NSError errorWithDomain:@"com.pubnub.test" code:0 userInfo:nil];
    PNErrorLogEntry *entry = [PNErrorLogEntry entryWithMessage:error];
    entry.pubNubId = @"client-1";
    entry.location = @"Test.m:1";
    entry.logLevel = PNErrorLogLevel;

    NSString *result = [PNConsoleLogger stringifiedLogEntry:entry];

    XCTAssertTrue([result containsString:@"com.pubnub.test"],
                  @"Output should contain the error domain.");
}


#pragma mark - Tests :: Stringification :: Network request entries

- (void)testItShouldStringifyNetworkRequestLogEntry {
    PNTransportRequest *request = [PNTransportRequest new];
    request.path = @"/v2/subscribe/sub-key/channel/0";
    request.origin = @"ps.pndsn.com";
    request.method = TransportGETMethod;

    PNNetworkRequestLogEntry *entry = [PNNetworkRequestLogEntry entryWithMessage:request
                                                                         details:@"Subscribe"];
    entry.pubNubId = @"client-1";
    entry.location = @"Transport.m:1";
    entry.logLevel = PNDebugLogLevel;

    NSString *result = [PNConsoleLogger stringifiedLogEntry:entry];

    XCTAssertTrue([result containsString:@"Sending"],
                  @"Output should contain 'Sending' prefix for normal requests.");
    XCTAssertTrue([result containsString:@"Subscribe"],
                  @"Output should contain the request details.");
    XCTAssertTrue([result containsString:@"ps.pndsn.com"],
                  @"Output should contain the request origin.");
    XCTAssertTrue([result containsString:@"/v2/subscribe"],
                  @"Output should contain the request path.");
}

- (void)testItShouldStringifyCancelledNetworkRequestLogEntry {
    PNTransportRequest *request = [PNTransportRequest new];
    request.path = @"/publish/key";
    request.origin = @"ps.pndsn.com";
    request.cancelled = YES;

    PNNetworkRequestLogEntry *entry = [PNNetworkRequestLogEntry entryWithMessage:request
                                                                         details:nil
                                                                        canceled:YES
                                                                          failed:NO];
    entry.pubNubId = @"client-1";
    entry.location = @"Transport.m:1";
    entry.logLevel = PNDebugLogLevel;

    NSString *result = [PNConsoleLogger stringifiedLogEntry:entry];

    XCTAssertTrue([result containsString:@"Canceled"],
                  @"Output should contain 'Canceled' for cancelled requests.");
}

- (void)testItShouldStringifyFailedNetworkRequestLogEntry {
    PNTransportRequest *request = [PNTransportRequest new];
    request.path = @"/publish/key";
    request.origin = @"ps.pndsn.com";
    request.failed = YES;

    PNNetworkRequestLogEntry *entry = [PNNetworkRequestLogEntry entryWithMessage:request
                                                                         details:nil
                                                                        canceled:NO
                                                                          failed:YES];
    entry.pubNubId = @"client-1";
    entry.location = @"Transport.m:1";
    entry.logLevel = PNDebugLogLevel;

    NSString *result = [PNConsoleLogger stringifiedLogEntry:entry];

    XCTAssertTrue([result containsString:@"Failed"],
                  @"Output should contain 'Failed' for failed requests.");
}

- (void)testItShouldStringifyNetworkRequestWithQueryParameters {
    PNTransportRequest *request = [PNTransportRequest new];
    request.path = @"/v2/subscribe/sub-key/channel/0";
    request.origin = @"ps.pndsn.com";
    request.query = @{ @"tt": @"0", @"tr": @"1" };

    PNNetworkRequestLogEntry *entry = [PNNetworkRequestLogEntry entryWithMessage:request details:nil];
    entry.pubNubId = @"client-1";
    entry.location = @"Transport.m:1";
    entry.logLevel = PNDebugLogLevel;

    NSString *result = [PNConsoleLogger stringifiedLogEntry:entry];

    XCTAssertTrue([result containsString:@"tt=0"] || [result containsString:@"tr=1"],
                  @"Output should contain query parameters.");
}


#pragma mark - Tests :: Stringification :: Network response entries

- (void)testItShouldStringifyNetworkResponseLogEntry {
    PNConsoleTestTransportResponse *response =
        [[PNConsoleTestTransportResponse alloc] initWithURL:@"https://ps.pndsn.com/v2/subscribe?tt=0"
                                                 statusCode:200
                                                       body:nil
                                                    headers:nil];

    PNNetworkResponseLogEntry *entry = [PNNetworkResponseLogEntry entryWithMessage:response];
    entry.pubNubId = @"client-1";
    entry.location = @"Transport.m:1";
    entry.logLevel = PNDebugLogLevel;

    NSString *result = [PNConsoleLogger stringifiedLogEntry:entry];

    XCTAssertTrue([result containsString:@"Received HTTP response"],
                  @"Output should contain 'Received HTTP response' prefix.");
    XCTAssertTrue([result containsString:@"ps.pndsn.com"],
                  @"Output should contain the response URL.");
}

- (void)testItShouldStringifyNetworkResponseWithJSONBody {
    NSData *body = [@"{\"status\":200}" dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *headers = @{ @"content-type": @"application/json" };

    PNConsoleTestTransportResponse *response =
        [[PNConsoleTestTransportResponse alloc] initWithURL:@"https://ps.pndsn.com/publish"
                                                 statusCode:200
                                                       body:body
                                                    headers:headers];

    PNNetworkResponseLogEntry *entry = [PNNetworkResponseLogEntry entryWithMessage:response];
    entry.pubNubId = @"client-1";
    entry.location = @"Transport.m:1";
    entry.logLevel = PNDebugLogLevel;

    NSString *result = [PNConsoleLogger stringifiedLogEntry:entry];

    XCTAssertTrue([result containsString:@"{\"status\":200}"],
                  @"Output should contain the JSON body content.");
}

- (void)testItShouldStringifyNetworkResponseWithBinaryBody {
    NSData *body = [@"binary data" dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *headers = @{ @"content-type": @"application/octet-stream" };

    PNConsoleTestTransportResponse *response =
        [[PNConsoleTestTransportResponse alloc] initWithURL:@"https://ps.pndsn.com/files"
                                                 statusCode:200
                                                       body:body
                                                    headers:headers];

    PNNetworkResponseLogEntry *entry = [PNNetworkResponseLogEntry entryWithMessage:response];
    entry.pubNubId = @"client-1";
    entry.location = @"Transport.m:1";
    entry.logLevel = PNDebugLogLevel;

    NSString *result = [PNConsoleLogger stringifiedLogEntry:entry];

    XCTAssertTrue([result containsString:@"NSData (length:"],
                  @"Output should show binary body as NSData with length.");
}


#pragma mark - Tests :: Stringification :: Headers at trace level

- (void)testItShouldIncludeRequestHeadersAtTraceLevel {
    PNTransportRequest *request = [PNTransportRequest new];
    request.path = @"/v2/subscribe/sub-key/channel/0";
    request.origin = @"ps.pndsn.com";
    request.headers = @{ @"Authorization": @"Bearer token123" };

    PNNetworkRequestLogEntry *entry = [PNNetworkRequestLogEntry entryWithMessage:request details:nil];
    entry.pubNubId = @"client-1";
    entry.location = @"Transport.m:1";
    entry.logLevel = PNDebugLogLevel;
    entry.minimumLogLevel = PNTraceLogLevel;

    NSString *result = [PNConsoleLogger stringifiedLogEntry:entry];

    XCTAssertTrue([result containsString:@"Authorization"],
                  @"Output should include request headers at trace level.");
}

- (void)testItShouldNotIncludeRequestHeadersAboveTraceLevel {
    PNTransportRequest *request = [PNTransportRequest new];
    request.path = @"/v2/subscribe/sub-key/channel/0";
    request.origin = @"ps.pndsn.com";
    request.headers = @{ @"Authorization": @"Bearer token123" };

    PNNetworkRequestLogEntry *entry = [PNNetworkRequestLogEntry entryWithMessage:request details:nil];
    entry.pubNubId = @"client-1";
    entry.location = @"Transport.m:1";
    entry.logLevel = PNDebugLogLevel;
    entry.minimumLogLevel = PNDebugLogLevel;

    NSString *result = [PNConsoleLogger stringifiedLogEntry:entry];

    XCTAssertFalse([result containsString:@"Authorization"],
                   @"Output should NOT include request headers above trace level.");
}

- (void)testItShouldIncludeResponseHeadersAtTraceLevel {
    NSDictionary *headers = @{ @"content-type": @"application/json", @"x-custom": @"custom-value" };

    PNConsoleTestTransportResponse *response =
        [[PNConsoleTestTransportResponse alloc] initWithURL:@"https://ps.pndsn.com/subscribe"
                                                 statusCode:200
                                                       body:nil
                                                    headers:headers];

    PNNetworkResponseLogEntry *entry = [PNNetworkResponseLogEntry entryWithMessage:response];
    entry.pubNubId = @"client-1";
    entry.location = @"Transport.m:1";
    entry.logLevel = PNDebugLogLevel;
    entry.minimumLogLevel = PNTraceLogLevel;

    NSString *result = [PNConsoleLogger stringifiedLogEntry:entry];

    XCTAssertTrue([result containsString:@"x-custom"],
                  @"Output should include response headers at trace level.");
}


#pragma mark - Tests :: Pre-processed string caching

- (void)testItShouldNotCallLogMessageWhenLogEntryAlreadyLogged {
    PNConsoleLogger *logger = [PNConsoleLogger new];

    PNStringLogEntry *entry = [PNStringLogEntry entryWithMessage:@"test"];
    entry.pubNubId = @"client-1";
    entry.location = @"Test.m:1";
    entry.logLevel = PNInfoLogLevel;

    // First log sets preProcessedString.
    [logger infoWithMessage:entry];
    NSString *cached = entry.preProcessedString;

    XCTAssertNotNil(cached, @"Pre-processed string should be set after first log call.");

    // Second log should use cached version.
    [logger infoWithMessage:entry];
    XCTAssertEqualObjects(entry.preProcessedString, cached,
                          @"Pre-processed string should remain unchanged on second log call.");
}


#pragma mark - Tests :: Log method dispatching

- (void)testItShouldNotCrashWhenCallingAllLogMethods {
    PNConsoleLogger *logger = [PNConsoleLogger new];

    PNStringLogEntry *entry = [PNStringLogEntry entryWithMessage:@"stability test"];
    entry.pubNubId = @"client-1";
    entry.location = @"Test.m:1";

    entry.logLevel = PNTraceLogLevel;
    XCTAssertNoThrow([logger traceWithMessage:entry], @"traceWithMessage: should not throw.");

    entry.logLevel = PNDebugLogLevel;
    XCTAssertNoThrow([logger debugWithMessage:entry], @"debugWithMessage: should not throw.");

    entry.logLevel = PNInfoLogLevel;
    XCTAssertNoThrow([logger infoWithMessage:entry], @"infoWithMessage: should not throw.");

    entry.logLevel = PNWarnLogLevel;
    XCTAssertNoThrow([logger warnWithMessage:entry], @"warnWithMessage: should not throw.");

    entry.logLevel = PNErrorLogLevel;
    XCTAssertNoThrow([logger errorWithMessage:entry], @"errorWithMessage: should not throw.");
}


#pragma mark - Tests :: ISO8601 timestamp format

- (void)testItShouldIncludeISO8601TimestampInOutput {
    PNStringLogEntry *entry = [PNStringLogEntry entryWithMessage:@"timestamp test"];
    entry.pubNubId = @"client-1";
    entry.location = @"Test.m:1";
    entry.logLevel = PNInfoLogLevel;

    NSString *result = [PNConsoleLogger stringifiedLogEntry:entry];

    // ISO8601 timestamps contain T separator and end with Z (for UTC) or timezone offset.
    NSString *pattern = @"\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    NSUInteger matches = [regex numberOfMatchesInString:result options:0 range:NSMakeRange(0, result.length)];

    XCTAssertGreaterThan(matches, 0, @"Output should contain an ISO8601-formatted timestamp.");
}


#pragma mark -

@end


#pragma mark - Test transport response helper

@implementation PNConsoleTestTransportResponse

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
