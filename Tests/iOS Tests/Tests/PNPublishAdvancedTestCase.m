//
//  PNPublishAdvancedTestCase.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 4/22/16.
//
//

#import "PNClientTestCase.h"
#import "XCTestCase+PNPublish.h"

@interface PNPublishAdvancedTestCase : PNClientTestCase

@end

@implementation PNPublishAdvancedTestCase

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

- (void)testPublishStringWithPushPayloadAndStoreInHistoryAndCompressionAndMetadata {
    PNWeakify(self);
    NSDictionary *payload = @{@"aps" :
                                  @{@"alert" : @"You got your emails.@",
                                    @"badge" : @(9),
                                    @"sound" : @"bingbong.aiff"},
                              @"acme 1" : @(42)};
    NSDictionary *metadata = @{
                               @"foo": @"bar"
                               };
    [self performExpectedPublish:@"test" toChannel:self.publishChannel withMobilePushPayload:payload storeInHistory:YES compressed:YES withMetadata:metadata withCompletion:^(PNPublishStatus * _Nonnull status) {
        PNStrongify(self);
        [self PN_assertOnPublishStatus:status withSuccess:YES];
        XCTAssertEqualObjects(status.data.timetoken, @14613497208195952);
    }];
}

#pragma mark - Helper

- (void)performExpectedPublish:(id)message toChannel:(NSString *)channel withMobilePushPayload:(NSDictionary *)pushPayload storeInHistory:(BOOL)storeInHistory compressed:(BOOL)compressed withMetadata:(NSDictionary *)metadata withCompletion:(PNPublishCompletionBlock)completionBlock {
    __block XCTestExpectation *publishExpectation = [self expectationWithDescription:@"publish"];
    [self.client publish:message toChannel:channel mobilePushPayload:pushPayload storeInHistory:storeInHistory compressed:compressed withMetadata:metadata completion:^(PNPublishStatus * _Nonnull status) {
        if (completionBlock) {
            completionBlock(status);
        }
        [publishExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}
@end
