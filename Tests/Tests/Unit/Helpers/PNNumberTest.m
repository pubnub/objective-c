/**
 * @author Serhii Mamontov
 * @copyright © 2010-2026 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <PubNub/PNHelpers.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

@interface PNNumberTest : XCTestCase

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNNumberTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"


#pragma mark - Tests :: timeTokenFromNumber:

- (void)testItShouldReturn17DigitTimetokenWhenUnixTimestampProvided {
    // Unix timestamp 10 digits: 1609459200 (2021-01-01T00:00:00Z)
    NSNumber *unixTimestamp = @(1609459200);

    NSNumber *timetoken = [PNNumber timeTokenFromNumber:unixTimestamp];

    // 10-digit timestamp needs 7 more digits to reach 17 total = multiply by 10^7
    NSNumber *expected = @(16094592000000000ULL);
    XCTAssertEqualObjects(timetoken, expected,
                         @"Unix timestamp should be converted to 17-digit timetoken.");
}

- (void)testItShouldReturnSameTimetokenWhen17DigitNumberProvided {
    // Already a 17-digit timetoken
    NSNumber *fullTimetoken = @(16094592000000000ULL);

    NSNumber *timetoken = [PNNumber timeTokenFromNumber:fullTimetoken];

    XCTAssertEqualObjects(timetoken, fullTimetoken,
                         @"Already 17-digit timetoken should remain unchanged.");
}

- (void)testItShouldReturnNilWhenNilProvided {
    NSNumber *timetoken = [PNNumber timeTokenFromNumber:nil];

    XCTAssertNil(timetoken, @"Timetoken from nil should be nil.");
}

- (void)testItShouldReturnZeroWhenZeroProvided {
    NSNumber *timetoken = [PNNumber timeTokenFromNumber:@0];

    XCTAssertEqualObjects(timetoken, @0,
                         @"Timetoken from zero should be zero (0 * any multiplier = 0).");
}

- (void)testItShouldConvert13DigitNumberWhenMillisecondTimestampProvided {
    // 13-digit millisecond timestamp
    NSNumber *millisTimestamp = @(1609459200000ULL);

    NSNumber *timetoken = [PNNumber timeTokenFromNumber:millisTimestamp];

    // 13 digits + 4 more to reach 17 = multiply by 10000
    NSNumber *expected = @(16094592000000000ULL);
    XCTAssertEqualObjects(timetoken, expected,
                         @"13-digit timestamp should be padded to 17 digits.");
}

- (void)testItShouldHandleFloatNumberWhenFloatTimestampProvided {
    // Float value representing unix timestamp with fractional seconds: 1609459200.123
    NSNumber *floatTimestamp = @(1609459200.123);

    NSNumber *timetoken = [PNNumber timeTokenFromNumber:floatTimestamp];

    XCTAssertGreaterThan(timetoken.unsignedLongLongValue, 0,
                        @"Float-based timetoken should produce positive result.");
}


#pragma mark -

#pragma clang diagnostic pop

@end
