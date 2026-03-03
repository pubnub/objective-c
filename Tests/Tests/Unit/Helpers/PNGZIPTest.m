/**
 * @author Serhii Mamontov
 * @copyright © 2010-2026 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <PubNub/PNHelpers.h>
#import <zlib.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

@interface PNGZIPTest : XCTestCase

#pragma mark - Helpers

/// Decompress GZIP deflated data using zlib.
///
/// - Parameter data: Compressed data which should be inflated.
/// - Returns: Decompressed data or `nil` if decompression fails.
- (nullable NSData *)inflateData:(NSData *)data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNGZIPTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"


#pragma mark - Tests :: Compression :: Happy paths

- (void)testItShouldCompressDataWhenNonEmptyDataProvided {
    NSData *originalData = [@"Hello, PubNub!" dataUsingEncoding:NSUTF8StringEncoding];

    NSData *compressedData = [PNGZIP GZIPDeflatedData:originalData];

    XCTAssertNotNil(compressedData, @"Compressed data should not be nil for valid input.");
    XCTAssertGreaterThan(compressedData.length, 0, @"Compressed data should have non-zero length.");
}

- (void)testItShouldProduceDecompressibleDataWhenCompressed {
    NSData *originalData = [@"Hello, PubNub! This is a test of GZIP compression." dataUsingEncoding:NSUTF8StringEncoding];

    NSData *compressedData = [PNGZIP GZIPDeflatedData:originalData];
    XCTAssertNotNil(compressedData, @"Compressed data should not be nil.");

    NSData *decompressedData = [self inflateData:compressedData];

    XCTAssertNotNil(decompressedData, @"Decompressed data should not be nil.");
    XCTAssertEqualObjects(decompressedData, originalData, @"Decompressed data should match original.");
}

- (void)testItShouldReturnNilWhenEmptyDataProvided {
    NSData *emptyData = [NSData data];

    NSData *compressedData = [PNGZIP GZIPDeflatedData:emptyData];

    XCTAssertNil(compressedData, @"Compressing empty data should return nil.");
}

- (void)testItShouldCompressSmallDataWhenFewBytesProvided {
    NSData *smallData = [@"Hi" dataUsingEncoding:NSUTF8StringEncoding];

    NSData *compressedData = [PNGZIP GZIPDeflatedData:smallData];

    XCTAssertNotNil(compressedData, @"Should compress even very small data.");

    NSData *decompressed = [self inflateData:compressedData];
    XCTAssertEqualObjects(decompressed, smallData, @"Decompressed small data should match original.");
}

- (void)testItShouldCompressMediumDataWhenMultipleKilobytesProvided {
    NSMutableString *mediumString = [NSMutableString new];
    for (int i = 0; i < 500; i++) {
        [mediumString appendFormat:@"Line %d: The quick brown fox jumps over the lazy dog.\n", i];
    }
    NSData *mediumData = [mediumString dataUsingEncoding:NSUTF8StringEncoding];

    NSData *compressedData = [PNGZIP GZIPDeflatedData:mediumData];

    XCTAssertNotNil(compressedData, @"Should compress medium-sized data.");

    NSData *decompressed = [self inflateData:compressedData];
    XCTAssertEqualObjects(decompressed, mediumData, @"Decompressed medium data should match original.");
}

- (void)testItShouldCompressLargeDataWhenHundredsOfKilobytesProvided {
    NSMutableData *largeData = [NSMutableData dataWithCapacity:200000];
    NSData *chunk = [@"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" dataUsingEncoding:NSUTF8StringEncoding];
    for (int i = 0; i < 6000; i++) {
        [largeData appendData:chunk];
    }

    NSData *compressedData = [PNGZIP GZIPDeflatedData:largeData];

    XCTAssertNotNil(compressedData, @"Should compress large data.");

    NSData *decompressed = [self inflateData:compressedData];
    XCTAssertEqualObjects(decompressed, largeData, @"Decompressed large data should match original.");
}

- (void)testItShouldProduceSmallerOutputWhenCompressibleInputProvided {
    NSMutableString *repetitiveString = [NSMutableString new];
    for (int i = 0; i < 1000; i++) {
        [repetitiveString appendString:@"AAAAAAAAAA"];
    }
    NSData *originalData = [repetitiveString dataUsingEncoding:NSUTF8StringEncoding];

    NSData *compressedData = [PNGZIP GZIPDeflatedData:originalData];

    XCTAssertNotNil(compressedData, @"Compressed data should not be nil.");
    XCTAssertLessThan(compressedData.length, originalData.length,
                      @"Compressed output should be smaller than highly compressible input.");
}

- (void)testItShouldCompressBinaryDataWhenNonTextBytesProvided {
    unsigned char bytes[] = {0x00, 0x01, 0x02, 0xFF, 0xFE, 0xFD, 0x80, 0x7F};
    NSData *binaryData = [NSData dataWithBytes:bytes length:sizeof(bytes)];

    NSData *compressedData = [PNGZIP GZIPDeflatedData:binaryData];

    XCTAssertNotNil(compressedData, @"Should compress binary data.");

    NSData *decompressed = [self inflateData:compressedData];
    XCTAssertEqualObjects(decompressed, binaryData, @"Decompressed binary data should match original.");
}

- (void)testItShouldProduceValidGZIPHeaderWhenDataCompressed {
    NSData *originalData = [@"Test data for GZIP header validation" dataUsingEncoding:NSUTF8StringEncoding];

    NSData *compressedData = [PNGZIP GZIPDeflatedData:originalData];

    XCTAssertNotNil(compressedData, @"Compressed data should not be nil.");
    // GZIP magic number: first two bytes should be 0x1F 0x8B
    XCTAssertGreaterThanOrEqual(compressedData.length, (NSUInteger)2,
                                @"Compressed data should have at least 2 bytes for header.");
    const unsigned char *compressedBytes = compressedData.bytes;
    XCTAssertEqual(compressedBytes[0], 0x1F, @"First byte of GZIP header should be 0x1F.");
    XCTAssertEqual(compressedBytes[1], 0x8B, @"Second byte of GZIP header should be 0x8B.");
}

- (void)testItShouldCompressUnicodeDataWhenUTF8StringProvided {
    NSData *unicodeData = [@"Hello \u4e16\u754c \U0001F600 \u00E9\u00E0\u00FC" dataUsingEncoding:NSUTF8StringEncoding];

    NSData *compressedData = [PNGZIP GZIPDeflatedData:unicodeData];

    XCTAssertNotNil(compressedData, @"Should compress unicode data.");

    NSData *decompressed = [self inflateData:compressedData];
    XCTAssertEqualObjects(decompressed, unicodeData, @"Decompressed unicode data should match original.");
}

- (void)testItShouldCompressSingleByteWhenOneByteProvided {
    unsigned char singleByte = 0x42;
    NSData *singleByteData = [NSData dataWithBytes:&singleByte length:1];

    NSData *compressedData = [PNGZIP GZIPDeflatedData:singleByteData];

    XCTAssertNotNil(compressedData, @"Should compress single byte data.");

    NSData *decompressed = [self inflateData:compressedData];
    XCTAssertEqualObjects(decompressed, singleByteData, @"Decompressed single byte data should match.");
}


#pragma mark - Helpers

- (NSData *)inflateData:(NSData *)data {
    if (data.length == 0) return nil;

    z_stream stream;
    bzero(&stream, sizeof(stream));
    stream.next_in = (Bytef *)data.bytes;
    stream.avail_in = (uint)data.length;

    // Use MAX_WBITS + 32 to auto-detect gzip or zlib format.
    if (inflateInit2(&stream, MAX_WBITS + 32) != Z_OK) return nil;

    NSMutableData *decompressed = [NSMutableData dataWithLength:data.length * 4];
    int status;

    do {
        if (stream.total_out >= decompressed.length) {
            [decompressed increaseLengthBy:data.length];
        }

        stream.next_out = (Bytef *)decompressed.mutableBytes + stream.total_out;
        stream.avail_out = (uInt)(decompressed.length - stream.total_out);

        status = inflate(&stream, Z_NO_FLUSH);
    } while (status == Z_OK);

    inflateEnd(&stream);

    if (status != Z_STREAM_END) return nil;

    [decompressed setLength:stream.total_out];
    return [decompressed copy];
}


#pragma mark -

#pragma clang diagnostic pop

@end
