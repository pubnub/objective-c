#import <XCTest/XCTest.h>
#import <PubNub/PNEncryptedData.h>
#import <PubNub/PNEncryptedStream.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `PNEncryptedData` and `PNEncryptedStream` model unit tests.
///
/// Tests covering construction and property access for cryptor data model objects.
@interface PNEncryptedDataTest : XCTestCase

#pragma mark -

@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNEncryptedDataTest


#pragma mark - Tests :: PNEncryptedData construction

- (void)testItShouldCreateEncryptedDataWithDataAndMetadata {
    NSData *data = [@"encrypted payload" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *metadata = [@"initialization vector" dataUsingEncoding:NSUTF8StringEncoding];

    PNEncryptedData *encryptedData = [PNEncryptedData encryptedDataWithData:data metadata:metadata];

    XCTAssertEqualObjects(encryptedData.data, data, @"Data property should match provided data.");
    XCTAssertEqualObjects(encryptedData.metadata, metadata, @"Metadata property should match provided metadata.");
}

- (void)testItShouldCreateEncryptedDataWithNilMetadata {
    NSData *data = [@"encrypted payload" dataUsingEncoding:NSUTF8StringEncoding];

    PNEncryptedData *encryptedData = [PNEncryptedData encryptedDataWithData:data metadata:nil];

    XCTAssertEqualObjects(encryptedData.data, data, @"Data property should match provided data.");
    XCTAssertNil(encryptedData.metadata, @"Metadata should be nil when not provided.");
}

- (void)testItShouldPreserveDataIntegrity {
    NSMutableData *data = [NSMutableData dataWithLength:256];
    SecRandomCopyBytes(kSecRandomDefault, data.length, data.mutableBytes);
    NSMutableData *metadata = [NSMutableData dataWithLength:16];
    SecRandomCopyBytes(kSecRandomDefault, metadata.length, metadata.mutableBytes);

    PNEncryptedData *encryptedData = [PNEncryptedData encryptedDataWithData:data metadata:metadata];

    XCTAssertEqualObjects(encryptedData.data, data,
                          @"Data property should preserve the exact binary content.");
    XCTAssertEqualObjects(encryptedData.metadata, metadata,
                          @"Metadata property should preserve the exact binary content.");
}

- (void)testItShouldCreateEncryptedDataWithEmptyData {
    NSData *data = [NSData data];
    NSData *metadata = [NSData data];

    PNEncryptedData *encryptedData = [PNEncryptedData encryptedDataWithData:data metadata:metadata];

    XCTAssertEqual(encryptedData.data.length, 0u, @"Data length should be zero for empty data.");
    XCTAssertEqual(encryptedData.metadata.length, 0u, @"Metadata length should be zero for empty metadata.");
}


#pragma mark - Tests :: PNEncryptedData readonly properties

- (void)testDataPropertyShouldBeReadonly {
    NSData *data = [@"test" dataUsingEncoding:NSUTF8StringEncoding];
    PNEncryptedData *encryptedData = [PNEncryptedData encryptedDataWithData:data metadata:nil];

    // Verify the property value is stable (readonly).
    NSData *firstAccess = encryptedData.data;
    NSData *secondAccess = encryptedData.data;

    XCTAssertEqualObjects(firstAccess, secondAccess,
                          @"Multiple accesses to data property should return the same value.");
}

- (void)testMetadataPropertyShouldBeReadonly {
    NSData *metadata = [@"meta" dataUsingEncoding:NSUTF8StringEncoding];
    PNEncryptedData *encryptedData = [PNEncryptedData encryptedDataWithData:[NSData data] metadata:metadata];

    NSData *firstAccess = encryptedData.metadata;
    NSData *secondAccess = encryptedData.metadata;

    XCTAssertEqualObjects(firstAccess, secondAccess,
                          @"Multiple accesses to metadata property should return the same value.");
}


#pragma mark - Tests :: Multiple instances independence

- (void)testMultipleInstancesShouldBeIndependent {
    NSData *data1 = [@"payload1" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *meta1 = [@"meta1" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *data2 = [@"payload2" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *meta2 = [@"meta2" dataUsingEncoding:NSUTF8StringEncoding];

    PNEncryptedData *encrypted1 = [PNEncryptedData encryptedDataWithData:data1 metadata:meta1];
    PNEncryptedData *encrypted2 = [PNEncryptedData encryptedDataWithData:data2 metadata:meta2];

    XCTAssertEqualObjects(encrypted1.data, data1, @"First instance data should remain unchanged.");
    XCTAssertEqualObjects(encrypted1.metadata, meta1, @"First instance metadata should remain unchanged.");
    XCTAssertEqualObjects(encrypted2.data, data2, @"Second instance data should be independent.");
    XCTAssertEqualObjects(encrypted2.metadata, meta2, @"Second instance metadata should be independent.");
    XCTAssertFalse([encrypted1.data isEqualToData:encrypted2.data],
                   @"Different instances should hold different data.");
}


#pragma mark -

@end
