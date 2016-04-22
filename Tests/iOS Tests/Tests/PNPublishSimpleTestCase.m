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
    PNWeakify(self);
    [self performExpectedPublish:@"test" toChannel:self.publishChannel withCompletion:^(PNPublishStatus * _Nonnull status) {
        PNStrongify(self);
        [self PN_assertOnPublishStatus:status withSuccess:YES];
        XCTAssertEqualObjects(status.data.timetoken, @14613480530866726);
    }];
}

- (void)testPublishNilMessage {
    PNWeakify(self);
    [self performExpectedPublish:nil toChannel:self.publishChannel withCompletion:^(PNPublishStatus * _Nonnull status) {
        PNStrongify(self);
        [self PN_assertOnPublishStatus:status withSuccess:NO];
    }];
}

- (void)testPublishStringToNilChannel {
    PNWeakify(self);
    [self performExpectedPublish:@"test" toChannel:nil withCompletion:^(PNPublishStatus * _Nonnull status) {
        PNStrongify(self);
        [self PN_assertOnPublishStatus:status withSuccess:NO];
    }];
}

- (void)testPublishDictionary {
    PNWeakify(self);
    [self performExpectedPublish:@{@"test": @"test"} toChannel:self.publishChannel withCompletion:^(PNPublishStatus * _Nonnull status) {
        PNStrongify(self);
        [self PN_assertOnPublishStatus:status withSuccess:YES];
        XCTAssertEqualObjects(status.data.timetoken, @14613480529107131);
    }];
}

- (void)testPublishNestedDictionary {
    PNWeakify(self);
    [self performExpectedPublish:@{@"test": @{@"test": @"test"}} toChannel:self.publishChannel withCompletion:^(PNPublishStatus * _Nonnull status) {
        PNStrongify(self);
        [self PN_assertOnPublishStatus:status withSuccess:YES];
        XCTAssertEqualObjects(status.data.timetoken, @14613480529971055);
    }];
}

#pragma mark - Helper

- (void)performExpectedPublish:(id)message toChannel:(NSString *)channel withCompletion:(PNPublishCompletionBlock)completionBlock {
    __block XCTestExpectation *publishExpectation = [self expectationWithDescription:@"publish"];
    [self.client publish:message toChannel:channel withCompletion:^(PNPublishStatus * _Nonnull status) {
        if (completionBlock) {
            completionBlock(status);
        }
        [publishExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:kPNPublishTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

@end
