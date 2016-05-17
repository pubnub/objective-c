//
//  PNChannelSubscribeTestCase.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 4/22/16.
//
//

#import <PubNub_Testing/PubNubTesting.h>

@interface PNChannelSubscribeTestCase : PNTSubscribeLoopTestCase
@property (nonatomic, strong) XCTestExpectation *subscribeExpectation;
@end

@implementation PNChannelSubscribeTestCase

- (BOOL)isRecording {
    return YES;
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.subscribeExpectation = nil;
    [super tearDown];
}

- (BOOL)shouldRunSetUp {
    return NO;
}

- (NSArray<NSString *> *)subscribedChannels {
    return @[@"a"];
}

- (void)testSubscribeWithPresence {
    PNTWeakify(self);
    self.didReceiveStatusHandler = ^void (PubNub *client, PNStatus *status) {
        PNTStrongify(self);
        XCTAssertNotNil(client);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.category, PNConnectedCategory);
        XCTAssertEqual(status.operation, PNSubscribeOperation);
        XCTAssertEqual(status.statusCode, 200);
        XCTAssertTrue([status isKindOfClass:[PNSubscribeStatus class]]);
//        PNSubscribeStatus *subscribeStatus = (PNSubscribeStatus *)status;
//        XCTAssertEqualObjects(subscribeStatus.data.timetoken, @14613450594876714);
        [self.subscribeExpectation fulfill];
    };
    self.subscribeExpectation = [self expectationWithDescription:@"subscribe"];
    [self.client subscribeToChannels:self.subscribedChannels withPresence:YES];
    [self waitFor:kPNTSubscribeTimeout];
}

@end
