/**
 * @author Serhii Mamontov
 * @copyright © 2010-2026 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <PubNub/PNHelpers.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

@interface PNDictionaryTest : XCTestCase

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNDictionaryTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"


#pragma mark - Tests :: Validation :: isDictionary:containValueOfClasses:

- (void)testItShouldReturnYESWhenAllValuesMatchExpectedClasses {
    NSDictionary *dictionary = @{@"key1": @"value1", @"key2": @"value2"};
    NSArray<Class> *classes = @[[NSString class]];

    BOOL result = [PNDictionary isDictionary:dictionary containValueOfClasses:classes];

    XCTAssertTrue(result, @"Should return YES when all values are of expected class.");
}

- (void)testItShouldReturnNOWhenSomeValuesDoNotMatchExpectedClasses {
    NSDictionary *dictionary = @{@"key1": @"value1", @"key2": @(42)};
    NSArray<Class> *classes = @[[NSString class]];

    BOOL result = [PNDictionary isDictionary:dictionary containValueOfClasses:classes];

    XCTAssertFalse(result, @"Should return NO when some values are not of expected class.");
}

- (void)testItShouldReturnYESWhenValuesMatchAnyOfMultipleClasses {
    NSDictionary *dictionary = @{@"key1": @"value1", @"key2": @(42)};
    NSArray<Class> *classes = @[[NSString class], [NSNumber class]];

    BOOL result = [PNDictionary isDictionary:dictionary containValueOfClasses:classes];

    XCTAssertTrue(result, @"Should return YES when values match any of the specified classes.");
}

- (void)testItShouldReturnYESWhenEmptyDictionaryProvided {
    NSDictionary *dictionary = @{};
    NSArray<Class> *classes = @[[NSString class]];

    BOOL result = [PNDictionary isDictionary:dictionary containValueOfClasses:classes];

    XCTAssertTrue(result, @"Should return YES for empty dictionary since there are no non-matching values.");
}

- (void)testItShouldReturnNOWhenNoValuesMatchAnyExpectedClass {
    NSDictionary *dictionary = @{@"key1": @(1), @"key2": @(2)};
    NSArray<Class> *classes = @[[NSString class]];

    BOOL result = [PNDictionary isDictionary:dictionary containValueOfClasses:classes];

    XCTAssertFalse(result, @"Should return NO when no values match expected classes.");
}

- (void)testItShouldMatchSubclassesWhenSubclassValuePresent {
    NSMutableString *mutableString = [NSMutableString stringWithString:@"mutable"];
    NSDictionary *dictionary = @{@"key1": mutableString};
    NSArray<Class> *classes = @[[NSString class]];

    BOOL result = [PNDictionary isDictionary:dictionary containValueOfClasses:classes];

    XCTAssertTrue(result, @"Should match subclasses (NSMutableString is subclass of NSString).");
}

- (void)testItShouldReturnYESWhenDictionaryContainsNestedDictionaries {
    NSDictionary *dictionary = @{@"key1": @{@"nested": @"value"}, @"key2": @{@"nested2": @"value2"}};
    NSArray<Class> *classes = @[[NSDictionary class]];

    BOOL result = [PNDictionary isDictionary:dictionary containValueOfClasses:classes];

    XCTAssertTrue(result, @"Should return YES when all values are dictionaries as expected.");
}

- (void)testItShouldReturnYESWhenDictionaryContainsArrayValues {
    NSDictionary *dictionary = @{@"key1": @[@1, @2], @"key2": @[@3, @4]};
    NSArray<Class> *classes = @[[NSArray class]];

    BOOL result = [PNDictionary isDictionary:dictionary containValueOfClasses:classes];

    XCTAssertTrue(result, @"Should return YES when all values are arrays as expected.");
}


#pragma mark - Tests :: URL helper :: queryStringFrom:

- (void)testItShouldCreateQueryStringWhenDictionaryHasSingleEntry {
    NSDictionary *dictionary = @{@"key": @"value"};

    NSString *query = [PNDictionary queryStringFrom:dictionary];

    XCTAssertEqualObjects(query, @"key=value", @"Should produce correct query string for single entry.");
}

- (void)testItShouldCreateQueryStringWhenDictionaryHasMultipleEntries {
    NSDictionary *dictionary = @{@"a": @"1", @"b": @"2"};

    NSString *query = [PNDictionary queryStringFrom:dictionary];

    // Dictionary ordering is not guaranteed, so check both entries are present
    XCTAssertTrue([query containsString:@"a=1"], @"Query should contain a=1.");
    XCTAssertTrue([query containsString:@"b=2"], @"Query should contain b=2.");
    XCTAssertTrue([query containsString:@"&"], @"Query should contain ampersand separator.");
}

- (void)testItShouldReturnNilWhenEmptyDictionaryProvided {
    NSDictionary *dictionary = @{};

    NSString *query = [PNDictionary queryStringFrom:dictionary];

    XCTAssertNil(query, @"Query string from empty dictionary should be nil.");
}

- (void)testItShouldIncludeNumericValuesWhenDictionaryContainsNumbers {
    NSDictionary *dictionary = @{@"count": @(42)};

    NSString *query = [PNDictionary queryStringFrom:dictionary];

    XCTAssertEqualObjects(query, @"count=42", @"Should correctly format numeric values.");
}


#pragma mark -

#pragma clang diagnostic pop

@end
