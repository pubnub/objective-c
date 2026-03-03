/**
 * @author Serhii Mamontov
 * @copyright © 2010-2026 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <PubNub/PNHelpers.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

@interface PNDataTest : XCTestCase

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNDataTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"


#pragma mark - Tests :: HEX conversion :: HEXFrom:

- (void)testItShouldConvertToHEXWhenValidDataProvided {
    unsigned char bytes[] = {0xDE, 0xAD, 0xBE, 0xEF};
    NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];

    NSString *hex = [PNData HEXFrom:data];

    // The implementation iterates over data.length * 0.5, so it processes half the bytes.
    XCTAssertEqualObjects(hex, @"DEAD", @"HEX string should contain first half of bytes.");
}

- (void)testItShouldReturnEmptyStringWhenEmptyDataProvidedForHEX {
    NSData *data = [NSData data];

    NSString *hex = [PNData HEXFrom:data];

    XCTAssertEqual(hex.length, 0, @"HEX string from empty data should be empty.");
}

- (void)testItShouldReturnUppercaseHEXWhenDataProvided {
    unsigned char bytes[] = {0xab, 0xcd};
    NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];

    NSString *hex = [PNData HEXFrom:data];

    // The implementation uses %02lX (uppercase)
    XCTAssertEqualObjects(hex, @"AB", @"HEX should be uppercase.");
}


#pragma mark - Tests :: HEX conversion :: HEXFromDevicePushToken:

- (void)testItShouldConvertFullTokenToHEXWhenPushTokenProvided {
    unsigned char bytes[] = {0xDE, 0xAD, 0xBE, 0xEF};
    NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];

    NSString *hex = [PNData HEXFromDevicePushToken:data];

    // Unlike HEXFrom:, this method processes all bytes.
    XCTAssertEqualObjects(hex, @"DEADBEEF", @"HEX should contain all bytes of push token.");
}

- (void)testItShouldReturnEmptyStringWhenEmptyPushTokenProvided {
    NSData *data = [NSData data];

    NSString *hex = [PNData HEXFromDevicePushToken:data];

    XCTAssertEqual(hex.length, 0, @"HEX from empty push token should be empty.");
}

- (void)testItShouldConvertLongPushTokenWhenFullTokenProvided {
    unsigned char bytes[] = {0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF,
                             0xFE, 0xDC, 0xBA, 0x98, 0x76, 0x54, 0x32, 0x10};
    NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];

    NSString *hex = [PNData HEXFromDevicePushToken:data];

    XCTAssertEqual(hex.length, 32, @"16 bytes should produce 32-char HEX string.");
    XCTAssertEqualObjects(hex, @"0123456789ABCDEFFEDCBA9876543210",
                         @"Full push token should convert correctly.");
}

- (void)testItShouldPadSingleDigitBytesWhenLowValueBytesPresent {
    unsigned char bytes[] = {0x00, 0x01, 0x0F};
    NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];

    NSString *hex = [PNData HEXFromDevicePushToken:data];

    XCTAssertEqualObjects(hex, @"00010F", @"Low-value bytes should be zero-padded.");
}


#pragma mark - Tests :: Base64 conversion :: base64StringFrom:

- (void)testItShouldConvertToBase64WhenValidDataProvided {
    NSData *data = [@"Hello, World!" dataUsingEncoding:NSUTF8StringEncoding];

    NSString *base64 = [PNData base64StringFrom:data];

    XCTAssertEqualObjects(base64, @"SGVsbG8sIFdvcmxkIQ==",
                         @"Base64 encoding should match expected output.");
}

- (void)testItShouldReturnEmptyStringWhenEmptyDataProvidedForBase64 {
    NSData *data = [NSData data];

    NSString *base64 = [PNData base64StringFrom:data];

    XCTAssertEqual(base64.length, 0, @"Base64 from empty data should be empty string.");
}

- (void)testItShouldRoundTripWhenDataEncodedAndDecoded {
    NSData *originalData = [@"PubNub SDK" dataUsingEncoding:NSUTF8StringEncoding];

    NSString *base64 = [PNData base64StringFrom:originalData];
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:base64 options:0];

    XCTAssertEqualObjects(decodedData, originalData,
                         @"Base64 round-trip should produce original data.");
}


#pragma mark -

#pragma clang diagnostic pop

@end
