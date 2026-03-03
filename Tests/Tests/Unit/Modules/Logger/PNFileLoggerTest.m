#import <XCTest/XCTest.h>
#import <PubNub/PNTransportResponse.h>
#import <PubNub/PNTransportRequest.h>
#import <PubNub/PNStringLogEntry.h>
#import <PubNub/PNErrorLogEntry.h>
#import <PubNub/PNLogEntry.h>
#import <PubNub/PNLogger.h>
#import "PNStringLogEntry+Private.h"
#import "PNErrorLogEntry+Private.h"
#import "PNTransportRequest+Private.h"
#import "PNLogEntry+Private.h"
#import "PNFileLogger.h"
#import "PNFileLoggerFileInformation.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// File logger unit tests.
@interface PNFileLoggerTest : XCTestCase

/// Temporary directory used for log files during tests.
@property(copy, nonatomic) NSString *testLogsDirectory;

#pragma mark -

@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNFileLoggerTest


#pragma mark - Setup / Teardown

- (void)setUp {
    [super setUp];

    NSString *uniqueDir = [NSString stringWithFormat:@"com.pubnub.test.logger.%@",
                           [[NSUUID UUID] UUIDString]];
    self.testLogsDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:uniqueDir];
}

- (void)tearDown {
    // Clean up test log files.
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.testLogsDirectory]) {
        [[NSFileManager defaultManager] removeItemAtPath:self.testLogsDirectory error:nil];
    }

    [super tearDown];
}


#pragma mark - Tests :: Creation

- (void)testItShouldCreateFileLoggerWithValidPath {
    PNFileLogger *logger = [PNFileLogger loggerWithLogsDirectoryPath:self.testLogsDirectory];

}

- (void)testItShouldConformToPNLoggerProtocol {
    PNFileLogger *logger = [PNFileLogger loggerWithLogsDirectoryPath:self.testLogsDirectory];

    XCTAssertTrue([logger conformsToProtocol:@protocol(PNLogger)],
                  @"File logger should conform to PNLogger protocol.");
}

- (void)testItShouldCreateLogsDirectoryOnInit {
    [PNFileLogger loggerWithLogsDirectoryPath:self.testLogsDirectory];
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:self.testLogsDirectory];

    XCTAssertTrue(exists, @"Logs directory should be created upon initialization.");
}


#pragma mark - Tests :: Default configuration

- (void)testItShouldHaveDefaultMaximumNumberOfLogFiles {
    PNFileLogger *logger = [PNFileLogger loggerWithLogsDirectoryPath:self.testLogsDirectory];

    XCTAssertEqual(logger.maximumNumberOfLogFiles, 5,
                   @"Default maximum number of log files should be 5.");
}

- (void)testItShouldHaveDefaultMaximumLogFileSize {
    PNFileLogger *logger = [PNFileLogger loggerWithLogsDirectoryPath:self.testLogsDirectory];

    XCTAssertEqual(logger.maximumLogFileSize, (1 * 1024 * 1024),
                   @"Default maximum log file size should be 1 MB.");
}

- (void)testItShouldHaveDefaultLogFilesDiskQuota {
    PNFileLogger *logger = [PNFileLogger loggerWithLogsDirectoryPath:self.testLogsDirectory];

    XCTAssertEqual(logger.logFilesDiskQuota, (20 * 1024 * 1024),
                   @"Default log files disk quota should be 20 MB.");
}


#pragma mark - Tests :: Configuration changes

- (void)testItShouldAllowChangingMaximumNumberOfLogFiles {
    PNFileLogger *logger = [PNFileLogger loggerWithLogsDirectoryPath:self.testLogsDirectory];
    logger.maximumNumberOfLogFiles = 10;

    XCTAssertEqual(logger.maximumNumberOfLogFiles, 10,
                   @"Maximum number of log files should be updated.");
}

- (void)testItShouldAllowChangingMaximumLogFileSize {
    PNFileLogger *logger = [PNFileLogger loggerWithLogsDirectoryPath:self.testLogsDirectory];
    logger.maximumLogFileSize = (5 * 1024 * 1024);

    XCTAssertEqual(logger.maximumLogFileSize, (5 * 1024 * 1024),
                   @"Maximum log file size should be updated.");
}

- (void)testItShouldAllowChangingLogFilesDiskQuota {
    PNFileLogger *logger = [PNFileLogger loggerWithLogsDirectoryPath:self.testLogsDirectory];
    logger.logFilesDiskQuota = (50 * 1024 * 1024);

    XCTAssertEqual(logger.logFilesDiskQuota, (50 * 1024 * 1024),
                   @"Log files disk quota should be updated.");
}


#pragma mark - Tests :: PNLogger protocol methods

- (void)testItShouldRespondToTraceWithMessage {
    PNFileLogger *logger = [PNFileLogger loggerWithLogsDirectoryPath:self.testLogsDirectory];

    XCTAssertTrue([logger respondsToSelector:@selector(traceWithMessage:)],
                  @"File logger should respond to traceWithMessage:.");
}

- (void)testItShouldRespondToDebugWithMessage {
    PNFileLogger *logger = [PNFileLogger loggerWithLogsDirectoryPath:self.testLogsDirectory];

    XCTAssertTrue([logger respondsToSelector:@selector(debugWithMessage:)],
                  @"File logger should respond to debugWithMessage:.");
}

- (void)testItShouldRespondToInfoWithMessage {
    PNFileLogger *logger = [PNFileLogger loggerWithLogsDirectoryPath:self.testLogsDirectory];

    XCTAssertTrue([logger respondsToSelector:@selector(infoWithMessage:)],
                  @"File logger should respond to infoWithMessage:.");
}

- (void)testItShouldRespondToWarnWithMessage {
    PNFileLogger *logger = [PNFileLogger loggerWithLogsDirectoryPath:self.testLogsDirectory];

    XCTAssertTrue([logger respondsToSelector:@selector(warnWithMessage:)],
                  @"File logger should respond to warnWithMessage:.");
}

- (void)testItShouldRespondToErrorWithMessage {
    PNFileLogger *logger = [PNFileLogger loggerWithLogsDirectoryPath:self.testLogsDirectory];

    XCTAssertTrue([logger respondsToSelector:@selector(errorWithMessage:)],
                  @"File logger should respond to errorWithMessage:.");
}


#pragma mark - Tests :: Writing log entries to file

- (void)testItShouldCreateLogFileWhenLoggingMessage {
    PNFileLogger *logger = [PNFileLogger loggerWithLogsDirectoryPath:self.testLogsDirectory];

    PNStringLogEntry *entry = [PNStringLogEntry entryWithMessage:@"File logger test message"];
    entry.pubNubId = @"client-1";
    entry.location = @"Test.m:1";
    entry.logLevel = PNInfoLogLevel;

    [logger infoWithMessage:entry];

    // Wait for async write to complete.
    XCTestExpectation *expectation = [self expectationWithDescription:@"Log file created"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.testLogsDirectory
                                                                             error:nil];
        // Filter for .txt files (log files).
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self ENDSWITH '.txt'"];
        NSArray *logFiles = [files filteredArrayUsingPredicate:predicate];

        XCTAssertGreaterThan(logFiles.count, 0, @"At least one log file should be created.");
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:3 handler:nil];
}

- (void)testItShouldWriteContentToLogFile {
    PNFileLogger *logger = [PNFileLogger loggerWithLogsDirectoryPath:self.testLogsDirectory];

    PNStringLogEntry *entry = [PNStringLogEntry entryWithMessage:@"Verify written content"];
    entry.pubNubId = @"client-write-test";
    entry.location = @"Test.m:42";
    entry.logLevel = PNDebugLogLevel;

    [logger debugWithMessage:entry];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Content written to file"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.testLogsDirectory
                                                                             error:nil];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self ENDSWITH '.txt'"];
        NSArray *logFiles = [files filteredArrayUsingPredicate:predicate];

        if (logFiles.count > 0) {
            NSString *filePath = [self.testLogsDirectory stringByAppendingPathComponent:logFiles.firstObject];
            NSString *content = [NSString stringWithContentsOfFile:filePath
                                                          encoding:NSUTF8StringEncoding
                                                             error:nil];
            XCTAssertTrue([content containsString:@"Verify written content"],
                          @"Log file should contain the message text.");
            XCTAssertTrue([content containsString:@"client-write-test"],
                          @"Log file should contain the PubNub client ID.");
        }

        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:3 handler:nil];
}

- (void)testItShouldCreateLogFileWithCorrectNamingPattern {
    PNFileLogger *logger = [PNFileLogger loggerWithLogsDirectoryPath:self.testLogsDirectory];

    PNStringLogEntry *entry = [PNStringLogEntry entryWithMessage:@"naming test"];
    entry.pubNubId = @"client-1";
    entry.location = @"Test.m:1";
    entry.logLevel = PNInfoLogLevel;

    [logger infoWithMessage:entry];

    XCTestExpectation *expectation = [self expectationWithDescription:@"File name pattern verified"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.testLogsDirectory
                                                                             error:nil];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self ENDSWITH '.txt'"];
        NSArray *logFiles = [files filteredArrayUsingPredicate:predicate];

        if (logFiles.count > 0) {
            NSString *fileName = logFiles.firstObject;
            XCTAssertTrue([fileName hasPrefix:@"pubnub-"],
                          @"Log file should start with 'pubnub-' prefix.");
            XCTAssertTrue([fileName hasSuffix:@".txt"],
                          @"Log file should have .txt extension.");
        }

        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:3 handler:nil];
}


#pragma mark - Tests :: Multiple writes to same file

- (void)testItShouldWriteMultipleEntriesToSameLogFile {
    PNFileLogger *logger = [PNFileLogger loggerWithLogsDirectoryPath:self.testLogsDirectory];

    for (NSUInteger i = 0; i < 5; i++) {
        PNStringLogEntry *entry = [PNStringLogEntry entryWithMessage:
                                   [NSString stringWithFormat:@"Message number %lu", (unsigned long)i]];
        entry.pubNubId = @"client-multi";
        entry.location = @"Test.m:1";
        entry.logLevel = PNInfoLogLevel;
        [logger infoWithMessage:entry];
    }

    XCTestExpectation *expectation = [self expectationWithDescription:@"Multiple entries written"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.testLogsDirectory
                                                                             error:nil];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self ENDSWITH '.txt'"];
        NSArray *logFiles = [files filteredArrayUsingPredicate:predicate];

        if (logFiles.count > 0) {
            NSString *filePath = [self.testLogsDirectory stringByAppendingPathComponent:logFiles.firstObject];
            NSString *content = [NSString stringWithContentsOfFile:filePath
                                                          encoding:NSUTF8StringEncoding
                                                             error:nil];
            XCTAssertTrue([content containsString:@"Message number 0"],
                          @"Log file should contain first message.");
            XCTAssertTrue([content containsString:@"Message number 4"],
                          @"Log file should contain last message.");
        }

        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:5 handler:nil];
}


#pragma mark - Tests :: All log level methods write to file

- (void)testItShouldNotCrashWhenCallingAllLogMethods {
    PNFileLogger *logger = [PNFileLogger loggerWithLogsDirectoryPath:self.testLogsDirectory];

    PNStringLogEntry *entry = [PNStringLogEntry entryWithMessage:@"stability"];
    entry.pubNubId = @"client-1";
    entry.location = @"Test.m:1";

    entry.logLevel = PNTraceLogLevel;
    XCTAssertNoThrow([logger traceWithMessage:entry], @"traceWithMessage: should not crash.");

    entry.logLevel = PNDebugLogLevel;
    XCTAssertNoThrow([logger debugWithMessage:entry], @"debugWithMessage: should not crash.");

    entry.logLevel = PNInfoLogLevel;
    XCTAssertNoThrow([logger infoWithMessage:entry], @"infoWithMessage: should not crash.");

    entry.logLevel = PNWarnLogLevel;
    XCTAssertNoThrow([logger warnWithMessage:entry], @"warnWithMessage: should not crash.");

    entry.logLevel = PNErrorLogLevel;
    XCTAssertNoThrow([logger errorWithMessage:entry], @"errorWithMessage: should not crash.");
}


#pragma mark - Tests :: PNFileLoggerFileInformation

- (void)testItShouldCreateFileInformationForExistingFile {
    // Create a temporary file.
    NSString *filePath = [self.testLogsDirectory stringByAppendingPathComponent:@"test-log.txt"];
    [[NSFileManager defaultManager] createDirectoryAtPath:self.testLogsDirectory
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];

    PNFileLoggerFileInformation *info = [PNFileLoggerFileInformation informationForFileAtPath:filePath];

    XCTAssertEqualObjects(info.path, filePath, @"Path should match the provided file path.");
    XCTAssertEqualObjects(info.name, @"test-log.txt", @"Name should be the file name component.");
}

- (void)testItShouldReportCreationDateForExistingFile {
    NSString *filePath = [self.testLogsDirectory stringByAppendingPathComponent:@"dated-log.txt"];
    [[NSFileManager defaultManager] createDirectoryAtPath:self.testLogsDirectory
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];

    PNFileLoggerFileInformation *info = [PNFileLoggerFileInformation informationForFileAtPath:filePath];

}

- (void)testItShouldReportModificationDateForExistingFile {
    NSString *filePath = [self.testLogsDirectory stringByAppendingPathComponent:@"modified-log.txt"];
    [[NSFileManager defaultManager] createDirectoryAtPath:self.testLogsDirectory
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];

    PNFileLoggerFileInformation *info = [PNFileLoggerFileInformation informationForFileAtPath:filePath];

}

- (void)testItShouldReportZeroSizeForEmptyFile {
    NSString *filePath = [self.testLogsDirectory stringByAppendingPathComponent:@"empty-log.txt"];
    [[NSFileManager defaultManager] createDirectoryAtPath:self.testLogsDirectory
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];

    PNFileLoggerFileInformation *info = [PNFileLoggerFileInformation informationForFileAtPath:filePath];

    XCTAssertEqual(info.size, 0, @"Size should be 0 for an empty file.");
}

- (void)testItShouldReportCorrectSizeForNonEmptyFile {
    NSString *filePath = [self.testLogsDirectory stringByAppendingPathComponent:@"sized-log.txt"];
    [[NSFileManager defaultManager] createDirectoryAtPath:self.testLogsDirectory
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    NSData *content = [@"Hello, World!" dataUsingEncoding:NSUTF8StringEncoding];
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:content attributes:nil];

    PNFileLoggerFileInformation *info = [PNFileLoggerFileInformation informationForFileAtPath:filePath];

    XCTAssertEqual(info.size, content.length, @"Size should match the written content length.");
}

- (void)testItShouldNotBeArchivedByDefault {
    NSString *filePath = [self.testLogsDirectory stringByAppendingPathComponent:@"fresh-log.txt"];
    [[NSFileManager defaultManager] createDirectoryAtPath:self.testLogsDirectory
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];

    PNFileLoggerFileInformation *info = [PNFileLoggerFileInformation informationForFileAtPath:filePath];

    XCTAssertFalse(info.isArchived, @"File should not be marked as archived by default.");
}

- (void)testItShouldAllowSettingArchivedFlag {
    NSString *filePath = [self.testLogsDirectory stringByAppendingPathComponent:@"archive-log.txt"];
    [[NSFileManager defaultManager] createDirectoryAtPath:self.testLogsDirectory
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];

    PNFileLoggerFileInformation *info = [PNFileLoggerFileInformation informationForFileAtPath:filePath];
    info.archived = YES;

    XCTAssertTrue(info.isArchived, @"File should be marked as archived after setting the flag.");
}

- (void)testItShouldAllowUnsettingArchivedFlag {
    NSString *filePath = [self.testLogsDirectory stringByAppendingPathComponent:@"unarchive-log.txt"];
    [[NSFileManager defaultManager] createDirectoryAtPath:self.testLogsDirectory
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];

    PNFileLoggerFileInformation *info = [PNFileLoggerFileInformation informationForFileAtPath:filePath];
    info.archived = YES;
    info.archived = NO;

    XCTAssertFalse(info.isArchived, @"File should not be archived after unsetting the flag.");
}

- (void)testItShouldConsiderTwoFileInformationsEqualWhenPathsMatch {
    NSString *filePath = [self.testLogsDirectory stringByAppendingPathComponent:@"equal-log.txt"];
    [[NSFileManager defaultManager] createDirectoryAtPath:self.testLogsDirectory
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];

    PNFileLoggerFileInformation *info1 = [PNFileLoggerFileInformation informationForFileAtPath:filePath];
    PNFileLoggerFileInformation *info2 = [PNFileLoggerFileInformation informationForFileAtPath:filePath];

    XCTAssertEqualObjects(info1, info2,
                          @"Two file information objects with the same path should be equal.");
}

- (void)testItShouldConsiderTwoFileInformationsNotEqualWhenPathsDiffer {
    [[NSFileManager defaultManager] createDirectoryAtPath:self.testLogsDirectory
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    NSString *path1 = [self.testLogsDirectory stringByAppendingPathComponent:@"log-a.txt"];
    NSString *path2 = [self.testLogsDirectory stringByAppendingPathComponent:@"log-b.txt"];
    [[NSFileManager defaultManager] createFileAtPath:path1 contents:nil attributes:nil];
    [[NSFileManager defaultManager] createFileAtPath:path2 contents:nil attributes:nil];

    PNFileLoggerFileInformation *info1 = [PNFileLoggerFileInformation informationForFileAtPath:path1];
    PNFileLoggerFileInformation *info2 = [PNFileLoggerFileInformation informationForFileAtPath:path2];

    XCTAssertNotEqualObjects(info1, info2,
                             @"Two file information objects with different paths should not be equal.");
}


#pragma mark -

@end
