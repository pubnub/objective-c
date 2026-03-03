/**
 * @author Serhii Mamontov
 * @copyright © 2010-2026 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <PubNub/PNHelpers.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

@interface PNJSONHelperTest : XCTestCase

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNJSONHelperTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"


#pragma mark - Tests :: Serialization :: JSONStringFrom:withError:

- (void)testItShouldSerializeDictionaryWhenDictionaryProvided {
    NSDictionary *object = @{@"key": @"value"};
    NSError *error = nil;

    NSString *jsonString = [PNJSON JSONStringFrom:object withError:&error];

    XCTAssertNotNil(jsonString, @"JSON string should not be nil.");
    XCTAssertNil(error, @"Error should be nil for valid dictionary.");
    XCTAssertEqualObjects(jsonString, @"{\"key\":\"value\"}",
                         @"Dictionary should serialize to expected JSON string.");
}

- (void)testItShouldSerializeArrayWhenArrayProvided {
    NSArray *object = @[@1, @2, @3];
    NSError *error = nil;

    NSString *jsonString = [PNJSON JSONStringFrom:object withError:&error];

    XCTAssertNotNil(jsonString, @"JSON string should not be nil.");
    XCTAssertNil(error, @"Error should be nil for valid array.");
    XCTAssertEqualObjects(jsonString, @"[1,2,3]",
                         @"Array should serialize to expected JSON string.");
}

- (void)testItShouldWrapStringInQuotesWhenPlainStringProvided {
    NSString *object = @"hello";
    NSError *error = nil;

    NSString *jsonString = [PNJSON JSONStringFrom:object withError:&error];

    XCTAssertNotNil(jsonString, @"JSON string should not be nil.");
    XCTAssertEqualObjects(jsonString, @"\"hello\"",
                         @"Plain string should be wrapped in quotes.");
}

- (void)testItShouldReturnExistingJSONStringWhenAlreadyJSONFormattedStringProvided {
    NSString *object = @"{\"already\":\"json\"}";
    NSError *error = nil;

    NSString *jsonString = [PNJSON JSONStringFrom:object withError:&error];

    XCTAssertNotNil(jsonString, @"JSON string should not be nil.");
    XCTAssertEqualObjects(jsonString, object,
                         @"Already-JSON-formatted string should pass through unchanged.");
}

- (void)testItShouldReturnNilWhenNilObjectProvided {
    NSError *error = nil;

    NSString *jsonString = [PNJSON JSONStringFrom:nil withError:&error];

    XCTAssertNil(jsonString, @"JSON string should be nil for nil input.");
}

- (void)testItShouldSerializeEmptyDictionaryWhenEmptyDictionaryProvided {
    NSDictionary *object = @{};
    NSError *error = nil;

    NSString *jsonString = [PNJSON JSONStringFrom:object withError:&error];

    XCTAssertNotNil(jsonString, @"JSON string should not be nil.");
    XCTAssertEqualObjects(jsonString, @"{}",
                         @"Empty dictionary should serialize to '{}'.");
}

- (void)testItShouldSerializeEmptyArrayWhenEmptyArrayProvided {
    NSArray *object = @[];
    NSError *error = nil;

    NSString *jsonString = [PNJSON JSONStringFrom:object withError:&error];

    XCTAssertNotNil(jsonString, @"JSON string should not be nil.");
    XCTAssertEqualObjects(jsonString, @"[]",
                         @"Empty array should serialize to '[]'.");
}

- (void)testItShouldSerializeNestedObjectWhenNestedDictionaryProvided {
    NSDictionary *object = @{@"outer": @{@"inner": @"value"}};
    NSError *error = nil;

    NSString *jsonString = [PNJSON JSONStringFrom:object withError:&error];

    XCTAssertNotNil(jsonString, @"JSON string should not be nil.");
    XCTAssertNil(error, @"Error should be nil.");
    XCTAssertTrue([jsonString containsString:@"\"outer\""],
                  @"Should contain outer key.");
    XCTAssertTrue([jsonString containsString:@"\"inner\""],
                  @"Should contain inner key.");
}


#pragma mark - Tests :: De-serialization :: JSONObjectFrom:withError:

- (void)testItShouldDeserializeDictionaryWhenJSONDictionaryStringProvided {
    NSString *jsonString = @"{\"key\":\"value\"}";
    NSError *error = nil;

    id result = [PNJSON JSONObjectFrom:jsonString withError:&error];

    XCTAssertNotNil(result, @"Deserialized object should not be nil.");
    XCTAssertNil(error, @"Error should be nil for valid JSON.");
    XCTAssertTrue([result isKindOfClass:[NSDictionary class]],
                  @"Result should be a dictionary.");
    XCTAssertEqualObjects(result[@"key"], @"value",
                         @"Dictionary value should match.");
}

- (void)testItShouldDeserializeArrayWhenJSONArrayStringProvided {
    NSString *jsonString = @"[1,2,3]";
    NSError *error = nil;

    id result = [PNJSON JSONObjectFrom:jsonString withError:&error];

    XCTAssertNotNil(result, @"Deserialized object should not be nil.");
    XCTAssertNil(error, @"Error should be nil for valid JSON.");
    XCTAssertTrue([result isKindOfClass:[NSArray class]],
                  @"Result should be an array.");
    XCTAssertEqual([(NSArray *)result count], 3, @"Array should have 3 elements.");
}

- (void)testItShouldDeserializeStringWhenQuotedStringProvided {
    NSString *jsonString = @"\"hello world\"";
    NSError *error = nil;

    id result = [PNJSON JSONObjectFrom:jsonString withError:&error];

    XCTAssertNotNil(result, @"Deserialized object should not be nil.");
    XCTAssertTrue([result isKindOfClass:[NSString class]],
                  @"Result should be a string.");
    XCTAssertEqualObjects(result, @"hello world",
                         @"Deserialized string should match original without quotes.");
}

- (void)testItShouldReturnNilWhenNilStringProvidedForDeserialization {
    NSError *error = nil;

    id result = [PNJSON JSONObjectFrom:nil withError:&error];

    XCTAssertNil(result, @"Result should be nil for nil input.");
}

- (void)testItShouldSetErrorWhenInvalidJSONStringProvided {
    NSString *jsonString = @"{invalid json}";
    NSError *error = nil;

    id result = [PNJSON JSONObjectFrom:jsonString withError:&error];

    // The implementation tries to parse and should fail for invalid JSON.
    // Depending on whether the braces trigger the JSON path or string path.
    // '{invalid json}' starts with { and ends with }, so isJSONString returns YES but
    // the NSJSONSerialization should fail.
    // Actually the implementation checks first char == '"', so this goes to NSJSONSerialization.
    XCTAssertNil(result, @"Result should be nil for invalid JSON.");
    XCTAssertNotNil(error, @"Error should be set for invalid JSON.");
}

- (void)testItShouldDeserializeNumberWhenNumericJSONStringProvided {
    NSString *jsonString = @"42";
    NSError *error = nil;

    id result = [PNJSON JSONObjectFrom:jsonString withError:&error];

    XCTAssertNotNil(result, @"Deserialized object should not be nil.");
    XCTAssertNil(error, @"Error should be nil.");
    XCTAssertEqualObjects(result, @(42), @"Deserialized number should match.");
}

- (void)testItShouldDeserializeBooleanWhenBoolJSONStringProvided {
    NSString *jsonString = @"true";
    NSError *error = nil;

    id result = [PNJSON JSONObjectFrom:jsonString withError:&error];

    XCTAssertNotNil(result, @"Deserialized object should not be nil.");
    XCTAssertNil(error, @"Error should be nil.");
    XCTAssertEqualObjects(result, @YES, @"Deserialized boolean should be YES.");
}


#pragma mark - Tests :: Validation :: isJSONString:

- (void)testItShouldReturnYESWhenStringStartsAndEndsWithCurlyBraces {
    XCTAssertTrue([PNJSON isJSONString:@"{\"key\":\"value\"}"],
                  @"String starting and ending with curly braces should be detected as JSON.");
}

- (void)testItShouldReturnYESWhenStringStartsAndEndsWithSquareBrackets {
    XCTAssertTrue([PNJSON isJSONString:@"[1,2,3]"],
                  @"String starting and ending with square brackets should be detected as JSON.");
}

- (void)testItShouldReturnYESWhenStringStartsAndEndsWithQuotes {
    XCTAssertTrue([PNJSON isJSONString:@"\"hello\""],
                  @"String starting and ending with quotes should be detected as JSON.");
}

- (void)testItShouldReturnNOWhenPlainStringProvided {
    XCTAssertFalse([PNJSON isJSONString:@"hello"],
                   @"Plain string without JSON delimiters should not be detected as JSON.");
}

- (void)testItShouldReturnNOWhenEmptyStringProvided {
    XCTAssertFalse([PNJSON isJSONString:@""],
                   @"Empty string should not be detected as JSON.");
}

- (void)testItShouldReturnYESWhenNSNumberProvided {
    XCTAssertTrue([PNJSON isJSONString:@(42)],
                  @"NSNumber should be detected as JSON (numeric literal).");
}

- (void)testItShouldReturnNOWhenMismatchedBracesProvided {
    XCTAssertFalse([PNJSON isJSONString:@"{hello]"],
                   @"Mismatched braces should not be detected as JSON.");
}

- (void)testItShouldReturnYESWhenEmptyJSONObjectProvided {
    XCTAssertTrue([PNJSON isJSONString:@"{}"],
                  @"Empty JSON object should be detected as JSON.");
}

- (void)testItShouldReturnYESWhenEmptyJSONArrayProvided {
    XCTAssertTrue([PNJSON isJSONString:@"[]"],
                  @"Empty JSON array should be detected as JSON.");
}


#pragma mark -

#pragma clang diagnostic pop

@end
