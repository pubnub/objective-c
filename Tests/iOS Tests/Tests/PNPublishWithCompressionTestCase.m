//
//  PNPublishWithCompressionTestCase.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 4/22/16.
//
//

#import "PNClientTestCase.h"
#import "XCTestCase+PNPublish.h"

@interface PNPublishWithCompressionTestCase : PNClientTestCase

@end

@implementation PNPublishWithCompressionTestCase

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

- (void)testPublishStringWithCompression {
    PNWeakify(self);
    [self performExpectedPublish:@"test" toChannel:self.publishChannel withCompression:YES withCompletion:^(PNPublishStatus * _Nonnull status) {
        PNStrongify(self);
        [self PN_assertOnPublishStatus:status withSuccess:YES];
        XCTAssertEqualObjects(status.data.timetoken, @14613497214576406);
    }];
}

- (void)testPublishStringWithNoCompression {
    PNWeakify(self);
    [self performExpectedPublish:@"test" toChannel:self.publishChannel withCompression:NO withCompletion:^(PNPublishStatus * _Nonnull status) {
        PNStrongify(self);
        [self PN_assertOnPublishStatus:status withSuccess:YES];
        XCTAssertEqualObjects(status.data.timetoken, @14613497216762423);
    }];
}

#pragma mark - Helper

- (void)performExpectedPublish:(id)message toChannel:(NSString *)channel withCompression:(BOOL)isCompressed withCompletion:(PNPublishCompletionBlock)completionBlock {
    __block XCTestExpectation *publishExpectation = [self expectationWithDescription:@"publish"];
    [self.client publish:message toChannel:channel compressed:isCompressed withCompletion:^(PNPublishStatus * _Nonnull status) {
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
