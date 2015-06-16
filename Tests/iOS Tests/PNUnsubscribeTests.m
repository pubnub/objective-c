//
//  PNUnsubscribeTests.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 6/16/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <PubNub/PubNub.h>

#import "PNBasicSubscribeTestCase.h"

@interface PNUnsubscribeTests : PNBasicSubscribeTestCase <PNObjectEventListener>
@property (nonatomic, getter=isSettingUp) BOOL settingUp;
@property (nonatomic) XCTestExpectation *unsubscribeExpectation;
@end

@implementation PNUnsubscribeTests

- (BOOL)recording {
    return NO;
}

- (void)setUp {
    [super setUp];
    self.settingUp = YES;
    self.subscribeExpectation = [self expectationWithDescription:@"subscribe"];
    [self.client subscribeToChannels:@[@"a"] withPresence:YES];
    [self waitForExpectationsWithTimeout:500 handler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
    
}

- (void)tearDown {
    self.unsubscribeExpectation = nil;
    [super tearDown];
}

- (void)testUnsubscribe {    
    self.unsubscribeExpectation = [self expectationWithDescription:@"unsubscribe"];
    [self.client unsubscribeFromChannels:@[@"a"] withPresence:YES];
    [self waitForExpectationsWithTimeout:500 handler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
    
}

- (void)client:(PubNub *)client didReceiveMessage:(PNResult<PNMessageResult> *)message withStatus:(PNStatus<PNStatus> *)status {
    NSLog(@"message: %@", message);
    NSLog(@"status: %@", status);
}

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNResult<PNPresenceEventResult> *)event {
    NSLog(@"event: %@", event);
}

- (void)client:(PubNub *)client didReceiveStatus:(PNStatus<PNSubscriberStatus> *)status {
    NSLog(@"status: %@", status);
    if (self.isSettingUp) {
        XCTAssertNotNil(status);
        XCTAssertEqual(status.category, PNConnectedCategory);
        XCTAssertEqual(status.operation, PNSubscribeOperation);
        NSArray *expectedChannels = @[@"a", @"a-pnpres"];
        XCTAssertEqualObjects(status.subscribedChannels, expectedChannels);
        XCTAssertEqual(status.subscribedChannelGroups.count, 0);
        XCTAssertFalse(status.isError);
        self.settingUp = NO;
        [self.subscribeExpectation fulfill];
        return;
    }
    NSLog(@"status: %@", status);
    XCTAssertNotNil(status);
    XCTAssertFalse(status.isError);
    XCTAssertEqual(status.operation, PNSubscribeOperation);
    XCTAssertEqual(status.category, PNDisconnectedCategory);
    XCTAssertEqual(status.statusCode, 200);
    [self.unsubscribeExpectation fulfill];
}

@end
