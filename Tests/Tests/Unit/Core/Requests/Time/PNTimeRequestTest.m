#import <XCTest/XCTest.h>
#import <PubNub/PNTimeRequest.h>
#import "PNBaseRequest+Private.h"


#pragma mark Interface declaration

@interface PNTimeRequestTest : XCTestCase

@end


#pragma mark - Tests

@implementation PNTimeRequestTest


#pragma mark - Construction

- (void)testItShouldCreateTimeRequestWhenInitialized {
    PNTimeRequest *request = [PNTimeRequest new];

    XCTAssertNotNil(request);
}

- (void)testItShouldHaveNilQueryWhenCreated {
    PNTimeRequest *request = [PNTimeRequest new];

    XCTAssertNil(request.query);
}

- (void)testItShouldIncludeArbitraryParametersInQuery {
    PNTimeRequest *request = [PNTimeRequest new];
    request.arbitraryQueryParameters = @{ @"custom_key": @"custom_value" };

    XCTAssertEqualObjects(request.query[@"custom_key"], @"custom_value");
}

- (void)testItShouldReturnNilQueryWhenEmptyParametersSet {
    PNTimeRequest *request = [PNTimeRequest new];
    request.arbitraryQueryParameters = @{};

    XCTAssertNil(request.query, @"Empty arbitrary parameters should not produce a query");
}

- (void)testItShouldIncludeAllArbitraryParametersInQuery {
    PNTimeRequest *request = [PNTimeRequest new];
    request.arbitraryQueryParameters = @{ @"key1": @"val1", @"key2": @"val2", @"key3": @"val3" };

    NSDictionary *query = request.query;

    XCTAssertEqual(query.count, 3);
    XCTAssertEqualObjects(query[@"key2"], @"val2");
}

- (void)testItShouldPassValidationWhenCreated {
    PNTimeRequest *request = [PNTimeRequest new];

    // Time request has no required parameters, validate should return nil.
    XCTAssertNil([request validate]);
}

- (void)testItShouldOnlyIncludeLatestParametersInQuery {
    PNTimeRequest *request = [PNTimeRequest new];
    request.arbitraryQueryParameters = @{ @"key1": @"val1" };
    request.arbitraryQueryParameters = @{ @"key2": @"val2" };

    NSDictionary *query = request.query;

    XCTAssertNil(query[@"key1"]);
    XCTAssertEqualObjects(query[@"key2"], @"val2");
}


#pragma mark -

@end
