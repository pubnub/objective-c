//
//  PNPublishWithStoreInHistoryTestCase.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 4/22/16.
//
//

#import "PNClientTestCase.h"
#import "XCTestCase+PNPublish.h"

@interface PNPublishWithStoreInHistoryTestCase : PNClientTestCase

@end

@implementation PNPublishWithStoreInHistoryTestCase

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

- (void)testPublishStringWithStoreInHistory {
    PNWeakify(self);
    [self performExpectedPublish:@"test" toChannel:self.publishChannel withStoreInHistory:YES withCompletion:^(PNPublishStatus * _Nonnull status) {
        PNStrongify(self);
        [self PN_assertOnPublishStatus:status withSuccess:YES];
        XCTAssertEqualObjects(status.data.timetoken, @14613497218336166);
    }];
}

#pragma mark - Helper

- (void)performExpectedPublish:(id)message toChannel:(NSString *)channel withStoreInHistory:(BOOL)shouldStoreInHistory withCompletion:(PNPublishCompletionBlock)completionBlock {
    __block XCTestExpectation *publishExpectation = [self expectationWithDescription:@"publish"];
    [self.client publish:message toChannel:channel storeInHistory:shouldStoreInHistory withCompletion:^(PNPublishStatus * _Nonnull status) {
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
