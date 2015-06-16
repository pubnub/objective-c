//
//  PNIntegrationTests.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 6/9/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <PubNub/PubNub.h>
#import <JSZVCR/JSZVCR.h>

@interface PNIntegrationTests : JSZVCRTestCase <PNObjectEventListener>
@property (nonatomic) PubNub *client;
@property (nonatomic) XCTestExpectation *networkExpectation;
@end

@implementation PNIntegrationTests

- (BOOL)recording {
    return NO;
}

- (void)setUp {
    [super setUp];
    PNConfiguration *config = [PNConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
    config.uuid = @"322A70B3-F0EA-48CD-9BB0-D3F0F5DE996C";
    self.client = [PubNub clientWithConfiguration:config];
    [self.client addListeners:@[self]];
}

- (void)tearDown {
    self.networkExpectation = nil;
    [self.client removeListeners:@[self]];
    self.client = nil;
    [super tearDown];
}

- (void)testSimpleSubscribe {
    self.networkExpectation = [self expectationWithDescription:@"network"];
    [self.client subscribeToChannels:@[@"a"] withPresence:NO];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

#pragma mark - PNObjectEventListener

- (void)client:(PubNub *)client didReceiveMessage:(PNResult<PNMessageResult> *)message withStatus:(PNStatus<PNStatus> *)status {
    [self.networkExpectation fulfill];
    XCTAssertNil(status);
    XCTAssertEqualObjects(self.client, client);
    XCTAssertEqualObjects(client.uuid, message.uuid);
    XCTAssertNotNil(message.uuid);
    XCTAssertNil(message.authKey);
    XCTAssertEqual(message.statusCode, 200);
    XCTAssertTrue(message.TLSEnabled);
    XCTAssertEqual(message.operation, PNSubscribeOperation);
    NSLog(@"message:");
    NSLog(@"%@", message.data.message);
    XCTAssertEqualObjects(message.data.message, @"*********...... 2501 - 2015-06-15 22:23:26");
}

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNResult<PNPresenceEventResult> *)event {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)client:(PubNub *)client didReceiveStatus:(PNStatus<PNSubscriberStatus> *)status {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end
