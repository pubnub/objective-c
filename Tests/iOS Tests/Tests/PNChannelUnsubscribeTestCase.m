//
//  PNChannelUnsubscribeTestCase.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 4/22/16.
//
//

#import "PNSubscribeLoopTestCase.h"

@interface PNChannelUnsubscribeTestCase : PNSubscribeLoopTestCase
@property (nonatomic, strong) XCTestExpectation *unsubscribeExpectation;
@end

@implementation PNChannelUnsubscribeTestCase

- (BOOL)isRecording {
    return NO;
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.unsubscribeExpectation = nil;
    [super tearDown];
}

- (BOOL)shouldRunTearDown {
    return NO;
}

- (NSArray<NSString *> *)subscribedChannels {
    return @[@"a"];
}

- (void)testUnsubscribeWithPresence {
    PNWeakify(self);
    self.didReceiveStatusHandler = ^void (PubNub *client, PNStatus *status) {
        PNStrongify(self);
        XCTAssertNotNil(client);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.category, PNDisconnectedCategory);
        XCTAssertEqual(status.operation, PNUnsubscribeOperation);
        XCTAssertEqual(status.statusCode, 200);
        [self.unsubscribeExpectation fulfill];
    };
    self.unsubscribeExpectation = [self expectationWithDescription:@"unsubscribe"];
    [self.client unsubscribeFromChannels:self.subscribedChannels withPresence:YES];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

@end
