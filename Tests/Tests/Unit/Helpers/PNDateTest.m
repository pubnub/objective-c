/**
 * @author Serhii Mamontov
 * @copyright © 2010-2026 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <PubNub/PNHelpers.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

@interface PNDateTest : XCTestCase

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNDateTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"


#pragma mark - Tests :: RFC3339 Conversion

- (void)testItShouldFormatDateAsRFC3339WhenUnixEpochProvided {
    // Unix epoch: January 1, 1970, 00:00:00 UTC
    NSDate *epochDate = [NSDate dateWithTimeIntervalSince1970:0];

    NSString *result = [PNDate RFC3339StringFromDate:epochDate];

    XCTAssertEqualObjects(result, @"1970-01-01T00:00:00Z",
                         @"Unix epoch should format as expected RFC3339 string.");
}

- (void)testItShouldFormatDateAsRFC3339WhenSpecificDateProvided {
    // Create a specific date: 2023-06-15T12:30:45Z
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.year = 2023;
    components.month = 6;
    components.day = 15;
    components.hour = 12;
    components.minute = 30;
    components.second = 45;
    components.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date = [calendar dateFromComponents:components];

    NSString *result = [PNDate RFC3339StringFromDate:date];

    XCTAssertEqualObjects(result, @"2023-06-15T12:30:45Z",
                         @"Specific date should format correctly.");
}

- (void)testItShouldFormatDateInUTCWhenNonUTCDateProvided {
    // The formatter should always produce UTC time regardless of input timezone
    NSString *result = [PNDate RFC3339StringFromDate:[NSDate dateWithTimeIntervalSince1970:0]];

    XCTAssertTrue([result hasSuffix:@"Z"], @"RFC3339 string should end with 'Z' (UTC indicator).");
}

- (void)testItShouldIncludeDateAndTimeComponentsWhenFormatted {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:1000000000]; // 2001-09-09T01:46:40Z

    NSString *result = [PNDate RFC3339StringFromDate:date];

    XCTAssertTrue([result containsString:@"T"],
                  @"RFC3339 string should contain 'T' separator between date and time.");
    XCTAssertTrue([result containsString:@"-"],
                  @"RFC3339 string should contain hyphens in date portion.");
    XCTAssertTrue([result containsString:@":"],
                  @"RFC3339 string should contain colons in time portion.");
}

- (void)testItShouldFormatFarFutureDateWhenYear2099DateProvided {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.year = 2099;
    components.month = 12;
    components.day = 31;
    components.hour = 23;
    components.minute = 59;
    components.second = 59;
    components.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date = [calendar dateFromComponents:components];

    NSString *result = [PNDate RFC3339StringFromDate:date];

    XCTAssertEqualObjects(result, @"2099-12-31T23:59:59Z",
                         @"Far future date should format correctly.");
}

- (void)testItShouldFormatDateConsistentlyWhenSameDateFormattedTwice {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:1234567890];

    NSString *result1 = [PNDate RFC3339StringFromDate:date];
    NSString *result2 = [PNDate RFC3339StringFromDate:date];

    XCTAssertEqualObjects(result1, result2,
                         @"Same date should always produce the same RFC3339 string.");
}

- (void)testItShouldFormatLeapYearDateWhenFebruary29Provided {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.year = 2024;
    components.month = 2;
    components.day = 29;
    components.hour = 12;
    components.minute = 0;
    components.second = 0;
    components.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date = [calendar dateFromComponents:components];

    NSString *result = [PNDate RFC3339StringFromDate:date];

    XCTAssertEqualObjects(result, @"2024-02-29T12:00:00Z",
                         @"Leap year date should format correctly.");
}


#pragma mark -

#pragma clang diagnostic pop

@end
