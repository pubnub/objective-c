/**
 * @author Serhii Mamontov
 * @copyright © 2010-2026 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <PubNub/PNFunctions.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

@interface PNFunctionsTest : XCTestCase

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNFunctionsTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"


#pragma mark - Tests :: PNNSObjectIsKindOfAnyClass

- (void)testItShouldReturnYESWhenObjectMatchesOneOfProvidedClasses {
    NSString *object = @"hello";
    NSArray<Class> *classes = @[[NSNumber class], [NSString class]];

    BOOL result = PNNSObjectIsKindOfAnyClass(object, classes);

    XCTAssertTrue(result, @"NSString should match when NSString class is in the list.");
}

- (void)testItShouldReturnNOWhenObjectMatchesNoneOfProvidedClasses {
    NSString *object = @"hello";
    NSArray<Class> *classes = @[[NSNumber class], [NSArray class]];

    BOOL result = PNNSObjectIsKindOfAnyClass(object, classes);

    XCTAssertFalse(result, @"NSString should not match NSNumber or NSArray.");
}

- (void)testItShouldMatchSubclassWhenSuperclassIsInList {
    NSMutableArray *object = [NSMutableArray new];
    NSArray<Class> *classes = @[[NSArray class]];

    BOOL result = PNNSObjectIsKindOfAnyClass(object, classes);

    XCTAssertTrue(result, @"NSMutableArray should match NSArray (superclass).");
}


#pragma mark - Tests :: PNNSObjectIsSubclassOfAnyClass

- (void)testItShouldReturnYESWhenObjectIsSubclassOfProvidedClass {
    NSMutableString *object = [NSMutableString new];
    NSArray<Class> *classes = @[[NSString class]];

    BOOL result = PNNSObjectIsSubclassOfAnyClass(object, classes);

    XCTAssertTrue(result, @"NSMutableString should be subclass of NSString.");
}

- (void)testItShouldReturnNOWhenObjectIsNotSubclassOfAnyProvidedClass {
    NSString *object = @"hello";
    NSArray<Class> *classes = @[[NSNumber class], [NSArray class]];

    BOOL result = PNNSObjectIsSubclassOfAnyClass(object, classes);

    XCTAssertFalse(result, @"NSString should not be subclass of NSNumber or NSArray.");
}

- (void)testItShouldReturnYESWhenObjectIsSameClassAsProvided {
    NSString *object = @"hello";
    NSArray<Class> *classes = @[[NSString class]];

    BOOL result = PNNSObjectIsSubclassOfAnyClass(object, classes);

    XCTAssertTrue(result, @"Object's class should be considered subclass of itself.");
}


#pragma mark - Tests :: PNMessageFingerprint

- (void)testItShouldReturnConsistentFingerprintWhenSameStringProvidedTwice {
    NSString *payload = @"Hello, PubNub!";

    NSString *fingerprint1 = PNMessageFingerprint(payload);
    NSString *fingerprint2 = PNMessageFingerprint(payload);

    XCTAssertEqualObjects(fingerprint1, fingerprint2,
                         @"Same payload should produce same fingerprint.");
}

- (void)testItShouldReturnDifferentFingerprintsWhenDifferentStringsProvided {
    NSString *fingerprint1 = PNMessageFingerprint(@"Hello");
    NSString *fingerprint2 = PNMessageFingerprint(@"World");

    XCTAssertNotEqualObjects(fingerprint1, fingerprint2,
                            @"Different payloads should produce different fingerprints.");
}

- (void)testItShouldReturn8CharacterHexStringWhenStringPayloadProvided {
    NSString *fingerprint = PNMessageFingerprint(@"test payload");

    XCTAssertEqual(fingerprint.length, 8,
                  @"Fingerprint should be 8-character hex string.");
}

- (void)testItShouldReturnFingerprintWhenDictionaryPayloadProvided {
    NSDictionary *payload = @{@"message": @"hello", @"sender": @"test"};

    NSString *fingerprint = PNMessageFingerprint(payload);

    XCTAssertEqual(fingerprint.length, 8, @"Fingerprint should be 8 characters.");
}

- (void)testItShouldReturnFingerprintWhenArrayPayloadProvided {
    NSArray *payload = @[@1, @2, @3];

    NSString *fingerprint = PNMessageFingerprint(payload);

    XCTAssertEqual(fingerprint.length, 8, @"Fingerprint should be 8 characters.");
}

- (void)testItShouldReturnFingerprintWhenEmptyStringProvided {
    NSString *fingerprint = PNMessageFingerprint(@"");

    XCTAssertEqual(fingerprint.length, 8, @"Fingerprint should be 8 characters.");
}


#pragma mark - Tests :: PNStringFormat

- (void)testItShouldFormatStringWhenPlaceholdersProvided {
    NSString *result = PNStringFormat(@"Hello, %@!", @"PubNub");

    XCTAssertEqualObjects(result, @"Hello, PubNub!",
                         @"Format should substitute placeholders.");
}

- (void)testItShouldFormatNumericValuesWhenNumberPlaceholderProvided {
    NSString *result = PNStringFormat(@"Value: %d", 42);

    XCTAssertEqualObjects(result, @"Value: 42",
                         @"Format should handle numeric placeholders.");
}

- (void)testItShouldReturnFormatStringWhenNoArgumentsProvided {
    NSString *result = PNStringFormat(@"No args here");

    XCTAssertEqualObjects(result, @"No args here",
                         @"Format without arguments should return string as-is.");
}

- (void)testItShouldHandleMultiplePlaceholdersWhenProvided {
    NSString *result = PNStringFormat(@"%@ + %@ = %d", @"1", @"2", 3);

    XCTAssertEqualObjects(result, @"1 + 2 = 3",
                         @"Format should handle multiple mixed-type placeholders.");
}


#pragma mark - Tests :: PNErrorUserInfo

- (void)testItShouldCreateUserInfoDictionaryWhenAllFieldsProvided {
    NSError *underlyingError = [NSError errorWithDomain:@"test" code:1 userInfo:nil];

    NSDictionary *userInfo = PNErrorUserInfo(@"Description", @"Reason", @"Recovery", underlyingError);

    XCTAssertEqualObjects(userInfo[NSLocalizedDescriptionKey], @"Description",
                         @"Description should match.");
    XCTAssertEqualObjects(userInfo[NSLocalizedFailureReasonErrorKey], @"Reason",
                         @"Reason should match.");
    XCTAssertEqualObjects(userInfo[NSLocalizedRecoverySuggestionErrorKey], @"Recovery",
                         @"Recovery should match.");
    XCTAssertEqualObjects(userInfo[NSUnderlyingErrorKey], underlyingError,
                         @"Underlying error should match.");
}

- (void)testItShouldCreateUserInfoDictionaryWhenSomeFieldsAreNil {
    NSDictionary *userInfo = PNErrorUserInfo(@"Description", nil, nil, nil);

    XCTAssertEqualObjects(userInfo[NSLocalizedDescriptionKey], @"Description",
                         @"Description should match.");
    // NSMutableDictionary setObject:nil removes the key, so nil values should not be present.
}


#pragma mark -

#pragma clang diagnostic pop

@end
