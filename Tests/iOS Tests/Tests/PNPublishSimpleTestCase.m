//
//  PNPublishSimpleTestCase.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 4/22/16.
//
//

#import "PNClientTestCase.h"
#import "XCTestCase+PNPublish.h"

@interface PNPublishSimpleTestCase : PNClientTestCase

@end

@implementation PNPublishSimpleTestCase

- (BOOL)isRecording {
    return NO;
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (NSString *)publishChannel {
    return @"a";
}

- (void)testPublishString {
    __block XCTestExpectation *publishExpectation = [self expectationWithDescription:@"publish"];
    PNWeakify(self);
    [self.client publish:@"test" toChannel:self.publishChannel withCompletion:^(PNPublishStatus * _Nonnull status) {
        PNStrongify(self);
        [self PN_assertOnPublishStatus:status withSuccess:YES];
        XCTAssertEqualObjects(status.data.timetoken, @14613474403206448);
        [publishExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

- (void)testPublishNilMessage {
    __block XCTestExpectation *publishExpectation = [self expectationWithDescription:@"publish"];
    PNWeakify(self);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    [self.client publish:nil toChannel:self.publishChannel withCompletion:^(PNPublishStatus * _Nonnull status) {
        PNStrongify(self);
        [self PN_assertOnPublishStatus:status withSuccess:NO];
        [publishExpectation fulfill];
    }];
#pragma clang diagnostic pop
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

@end
