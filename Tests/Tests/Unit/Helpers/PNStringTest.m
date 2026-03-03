/**
 * @author Serhii Mamontov
 * @copyright © 2010-2026 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <PubNub/PNHelpers.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

@interface PNStringTest : XCTestCase

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNStringTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"


#pragma mark - Tests :: Percent Encoding

- (void)testItShouldPercentEncodeSpecialCharactersWhenStringContainsReservedCharacters {
    NSString *input = @"hello world&foo=bar";

    NSString *encoded = [PNString percentEscapedString:input];

    XCTAssertTrue([encoded rangeOfString:@"&"].location == NSNotFound,
                  @"Ampersand should be percent-encoded.");
    XCTAssertTrue([encoded rangeOfString:@"="].location == NSNotFound,
                  @"Equals sign should be percent-encoded.");
    XCTAssertTrue([encoded rangeOfString:@" "].location == NSNotFound,
                  @"Space should be percent-encoded.");
}

- (void)testItShouldReturnSameStringWhenNoSpecialCharactersPresent {
    NSString *input = @"helloworld";

    NSString *encoded = [PNString percentEscapedString:input];

    XCTAssertEqualObjects(encoded, input, @"String without special characters should remain unchanged.");
}

- (void)testItShouldEncodeNewlinesWhenStringContainsCRLF {
    NSString *input = @"line1\nline2\rline3";

    NSString *encoded = [PNString percentEscapedString:input];

    // The implementation replaces %0A with %5Cn and %0D with %5Cr
    XCTAssertTrue([encoded rangeOfString:@"%5Cn"].location != NSNotFound,
                  @"Newline should be encoded as escaped newline.");
    XCTAssertTrue([encoded rangeOfString:@"%5Cr"].location != NSNotFound,
                  @"Carriage return should be encoded as escaped carriage return.");
}

- (void)testItShouldEncodeColonAndSlashWhenStringContainsThem {
    NSString *input = @"http://example.com:8080/path?q=1";

    NSString *encoded = [PNString percentEscapedString:input];

    // Colons, slashes, question marks should be percent-encoded per the implementation
    XCTAssertTrue([encoded rangeOfString:@":"].location == NSNotFound,
                  @"Colons should be percent-encoded.");
    XCTAssertTrue([encoded rangeOfString:@"?"].location == NSNotFound,
                  @"Question marks should be percent-encoded.");
}

- (void)testItShouldHandleUnicodeCharactersWhenStringContainsNonASCII {
    NSString *input = @"\u00E9\u00E0\u00FC\u00F1";

    NSString *encoded = [PNString percentEscapedString:input];

    XCTAssertGreaterThan(encoded.length, 0, @"Encoded unicode string should have non-zero length.");
}

- (void)testItShouldReturnEmptyStringWhenEmptyStringProvided {
    NSString *input = @"";

    NSString *encoded = [PNString percentEscapedString:input];

    XCTAssertEqual(encoded.length, 0, @"Encoded empty string should have zero length.");
}

- (void)testItShouldEncodeHashAndBracketsWhenStringContainsThem {
    NSString *input = @"test#value[0]";

    NSString *encoded = [PNString percentEscapedString:input];

    XCTAssertTrue([encoded rangeOfString:@"#"].location == NSNotFound,
                  @"Hash should be percent-encoded.");
    XCTAssertTrue([encoded rangeOfString:@"["].location == NSNotFound,
                  @"Opening bracket should be percent-encoded.");
    XCTAssertTrue([encoded rangeOfString:@"]"].location == NSNotFound,
                  @"Closing bracket should be percent-encoded.");
}


#pragma mark - Tests :: UTF8 Data Conversion

- (void)testItShouldConvertToUTF8DataWhenValidStringProvided {
    NSString *input = @"Hello, PubNub!";

    NSData *data = [PNString UTF8DataFrom:input];

    XCTAssertNotNil(data, @"UTF8 data should not be nil.");
    NSString *roundTrip = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects(roundTrip, input, @"Round-trip conversion should match original string.");
}

- (void)testItShouldReturnEmptyDataWhenEmptyStringProvided {
    NSString *input = @"";

    NSData *data = [PNString UTF8DataFrom:input];

    XCTAssertNotNil(data, @"UTF8 data from empty string should not be nil.");
    XCTAssertEqual(data.length, 0, @"UTF8 data from empty string should have zero length.");
}

- (void)testItShouldConvertUnicodeToUTF8DataWhenUnicodeStringProvided {
    NSString *input = @"\u4e16\u754c \U0001F600";

    NSData *data = [PNString UTF8DataFrom:input];

    XCTAssertNotNil(data, @"UTF8 data from unicode string should not be nil.");
    XCTAssertGreaterThan(data.length, 0, @"UTF8 data should have non-zero length.");
    NSString *roundTrip = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects(roundTrip, input, @"Round-trip of unicode should match original.");
}


#pragma mark - Tests :: Base64 Data Conversion

- (void)testItShouldDecodeBase64DataWhenValidBase64StringProvided {
    NSString *original = @"Hello, World!";
    NSString *base64String = [[original dataUsingEncoding:NSUTF8StringEncoding]
                              base64EncodedStringWithOptions:0];

    NSData *decodedData = [PNString base64DataFrom:base64String];

    NSString *decoded = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects(decoded, original, @"Decoded base64 string should match original.");
}

- (void)testItShouldReturnEmptyDataWhenEmptyBase64StringProvided {
    NSString *base64String = @"";

    NSData *decodedData = [PNString base64DataFrom:base64String];

    XCTAssertEqual(decodedData.length, 0, @"Decoded base64 from empty string should have zero length.");
}


#pragma mark - Tests :: SHA-256 Hashing

- (void)testItShouldProduceConsistentHashWhenSameStringHashedTwice {
    NSString *input = @"Hello, PubNub!";

    NSData *hash1 = [PNString SHA256DataFrom:input];
    NSData *hash2 = [PNString SHA256DataFrom:input];

    XCTAssertEqualObjects(hash1, hash2, @"Same input should always produce the same SHA-256 hash.");
}

- (void)testItShouldReturn32ByteHashWhenStringProvided {
    NSString *input = @"test";

    NSData *hash = [PNString SHA256DataFrom:input];

    XCTAssertEqual(hash.length, (NSUInteger)CC_SHA256_DIGEST_LENGTH,
                   @"SHA-256 hash should be 32 bytes (256 bits).");
}

- (void)testItShouldProduceDifferentHashesWhenDifferentStringsProvided {
    NSData *hash1 = [PNString SHA256DataFrom:@"Hello"];
    NSData *hash2 = [PNString SHA256DataFrom:@"World"];

    XCTAssertNotEqualObjects(hash1, hash2, @"Different strings should produce different SHA-256 hashes.");
}

- (void)testItShouldHashEmptyStringWhenEmptyStringProvided {
    NSData *hash = [PNString SHA256DataFrom:@""];

    XCTAssertEqual(hash.length, (NSUInteger)CC_SHA256_DIGEST_LENGTH,
                   @"SHA-256 hash of empty string should still be 32 bytes.");
}


#pragma mark - Tests :: URL-Friendly Base64

- (void)testItShouldConvertURLFriendlyBase64WhenDashesAndUnderscoresPresent {
    // URL-friendly base64 uses - instead of + and _ instead of /
    NSString *urlFriendlyBase64 = @"SGVsbG8-V29ybGQ_";

    NSString *standardBase64 = [PNString base64StringFromURLFriendlyBase64String:urlFriendlyBase64];

    XCTAssertTrue([standardBase64 rangeOfString:@"-"].location == NSNotFound,
                  @"Dashes should be replaced with plus signs.");
    XCTAssertTrue([standardBase64 rangeOfString:@"_"].location == NSNotFound,
                  @"Underscores should be replaced with slashes.");
    XCTAssertTrue([standardBase64 rangeOfString:@"+"].location != NSNotFound,
                  @"Plus signs should be present in standard base64.");
    XCTAssertTrue([standardBase64 rangeOfString:@"/"].location != NSNotFound,
                  @"Slashes should be present in standard base64.");
}

- (void)testItShouldReturnSameStringWhenNoURLFriendlyCharactersPresent {
    NSString *standardBase64 = @"SGVsbG8gV29ybGQ=";

    NSString *result = [PNString base64StringFromURLFriendlyBase64String:standardBase64];

    XCTAssertEqualObjects(result, standardBase64,
                         @"String without URL-friendly chars should remain unchanged.");
}

- (void)testItShouldReturnEmptyStringWhenEmptyBase64StringProvided {
    NSString *result = [PNString base64StringFromURLFriendlyBase64String:@""];

    XCTAssertEqual(result.length, 0, @"Result should be empty for empty input.");
}


#pragma mark -

#pragma clang diagnostic pop

@end
