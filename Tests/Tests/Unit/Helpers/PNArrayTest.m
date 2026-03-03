/**
 * @author Serhii Mamontov
 * @copyright © 2010-2026 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <PubNub/PNHelpers.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

@interface PNArrayTest : XCTestCase

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNArrayTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"


#pragma mark - Tests :: Data mapping :: mapObjects:usingBlock:

- (void)testItShouldMapObjectsWhenTransformBlockProvided {
    NSArray *objects = @[@1, @2, @3];

    NSArray *mapped = [PNArray mapObjects:objects usingBlock:^id(NSNumber *object) {
        return @(object.integerValue * 2);
    }];

    XCTAssertEqual(mapped.count, 3, @"Mapped array should have same count.");
    XCTAssertEqualObjects(mapped[0], @2, @"First element should be doubled.");
    XCTAssertEqualObjects(mapped[1], @4, @"Second element should be doubled.");
    XCTAssertEqualObjects(mapped[2], @6, @"Third element should be doubled.");
}

- (void)testItShouldReturnNilWhenEmptyArrayProvided {
    NSArray *objects = @[];

    NSArray *mapped = [PNArray mapObjects:objects usingBlock:^id(id object) {
        return object;
    }];

    XCTAssertNil(mapped, @"Mapping empty array should return nil.");
}

- (void)testItShouldFilterNilValuesWhenBlockReturnsNilForSomeObjects {
    NSArray *objects = @[@1, @2, @3, @4, @5];

    NSArray *mapped = [PNArray mapObjects:objects usingBlock:^id(NSNumber *object) {
        // Only keep even numbers
        return (object.integerValue % 2 == 0) ? object : nil;
    }];

    XCTAssertEqual(mapped.count, 2, @"Mapped array should only contain even numbers.");
    XCTAssertEqualObjects(mapped[0], @2, @"First element should be 2.");
    XCTAssertEqualObjects(mapped[1], @4, @"Second element should be 4.");
}

- (void)testItShouldMapStringsWhenStringTransformProvided {
    NSArray *objects = @[@"hello", @"world"];

    NSArray *mapped = [PNArray mapObjects:objects usingBlock:^id(NSString *object) {
        return [object uppercaseString];
    }];

    XCTAssertEqual(mapped.count, 2, @"Mapped array should have same count.");
    XCTAssertEqualObjects(mapped[0], @"HELLO", @"First element should be uppercased.");
    XCTAssertEqualObjects(mapped[1], @"WORLD", @"Second element should be uppercased.");
}

- (void)testItShouldReturnNilWhenAllObjectsFilteredOut {
    NSArray *objects = @[@1, @2, @3];

    NSArray *mapped = [PNArray mapObjects:objects usingBlock:^id(__unused id object) {
        return nil;
    }];

    // When all objects map to nil, the mutable array is empty and copy returns empty array.
    XCTAssertEqual(mapped.count, 0, @"Mapped array should be empty when all objects filtered.");
}

- (void)testItShouldChangeObjectTypesWhenBlockReturnsNewType {
    NSArray *objects = @[@1, @2, @3];

    NSArray *mapped = [PNArray mapObjects:objects usingBlock:^id(NSNumber *object) {
        return [object stringValue];
    }];

    XCTAssertEqual(mapped.count, 3, @"Mapped array should have same count.");
    XCTAssertTrue([mapped[0] isKindOfClass:[NSString class]],
                  @"Mapped objects should be strings.");
    XCTAssertEqualObjects(mapped[0], @"1", @"First element should be string '1'.");
}

- (void)testItShouldMapSingleElementWhenSingleElementArrayProvided {
    NSArray *objects = @[@42];

    NSArray *mapped = [PNArray mapObjects:objects usingBlock:^id(NSNumber *object) {
        return @(object.integerValue + 8);
    }];

    XCTAssertEqual(mapped.count, 1, @"Mapped array should have one element.");
    XCTAssertEqualObjects(mapped[0], @50, @"Single element should be mapped correctly.");
}


#pragma mark -

#pragma clang diagnostic pop

@end
