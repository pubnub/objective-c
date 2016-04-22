//
//  PNPublishSizeOfMessageTestCase.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 4/22/16.
//
//

#import "PNClientTestCase.h"
#import "XCTestCase+PNPublish.h"

@interface PNPublishSizeOfMessageTestCase : PNClientTestCase

@end

@implementation PNPublishSizeOfMessageTestCase

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

- (void)testSizeOfStringMessage {
    PNWeakify(self);
    [self performExpectedSizeOfMessage:@"test" toChannel:self.publishChannel withCompletion:^(NSInteger size) {
        PNStrongify(self);
        XCTAssertEqual(size, 341);
    }];
}

#pragma mark - Helper

- (void)performExpectedSizeOfMessage:(id)message toChannel:(NSString *)channel withCompletion:(PNMessageSizeCalculationCompletionBlock)completionBlock {
    __block XCTestExpectation *sizeExpectation = [self expectationWithDescription:@"publish size"];
    [self.client sizeOfMessage:message toChannel:channel withCompletion:^(NSInteger size) {
        if (completionBlock) {
            completionBlock(size);
        }
        [sizeExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

@end
