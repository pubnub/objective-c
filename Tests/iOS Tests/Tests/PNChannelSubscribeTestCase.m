//
//  PNChannelSubscribeTestCase.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 4/22/16.
//
//

#import "PNSubscribeLoopTestCase.h"

@interface PNChannelSubscribeTestCase : PNSubscribeLoopTestCase
@property (nonatomic, strong) XCTestExpectation *subscribeExpectation;
@end

@implementation PNChannelSubscribeTestCase

- (BOOL)isRecording {
    return NO;
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
    PNWeakify(self);
    self.didReceiveStatusHandler = ^void (PubNub *client, PNStatus *status) {
        PNStrongify(self);
        XCTAssertNotNil(client);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.category, PNConnectedCategory);
        XCTAssertEqual(status.operation, PNSubscribeOperation);
        XCTAssertEqual(status.statusCode, 200);
        XCTAssertTrue([status isKindOfClass:[PNSubscribeStatus class]]);
        PNSubscribeStatus *subscribeStatus = (PNSubscribeStatus *)status;
        XCTAssertEqualObjects(subscribeStatus.data.timetoken, @14613450594876714);
        [self.subscribeExpectation fulfill];
    };
    self.subscribeExpectation = [self expectationWithDescription:@"subscribe"];
    [self.client subscribeToChannels:self.subscribedChannels withPresence:YES];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

@end
