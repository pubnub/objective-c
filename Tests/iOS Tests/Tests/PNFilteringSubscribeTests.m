//
//  PNFilteringSubscribeTests.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 12/16/15.
//
//

#import "PNBasicSubscribeTestCase.h"

static NSString * const kPNChannelGroupTestsName = @"PNChannelGroupSubscribeTests";

@interface PNFilteringSubscribeTests : PNBasicSubscribeTestCase

@end

@implementation PNFilteringSubscribeTests

- (BOOL)isRecording{
    return YES;
}

- (PNConfiguration *)overrideClientConfiguration:(PNConfiguration *)configuration {
    configuration.filterExpression = @"region==east";
    return configuration;
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSimpleSubscribeWithPresence {
    PNWeakify(self);
    self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.category, PNConnectedCategory);
        NSArray *expectedChannelGroups = @[
                                           kPNChannelGroupTestsName,
                                           [kPNChannelGroupTestsName stringByAppendingString:@"-pnpres"]
                                           ];
        XCTAssertEqual(status.subscribedChannels.count, 0);
        XCTAssertEqualObjects([NSSet setWithArray:status.subscribedChannelGroups],
                              [NSSet setWithArray:expectedChannelGroups]);
        
        XCTAssertEqual(status.operation, PNSubscribeOperation);
        NSLog(@"timeToken: %@", status.currentTimetoken);
        XCTAssertEqualObjects(status.currentTimetoken, @14490969656951470);
        XCTAssertEqualObjects(status.currentTimetoken, status.data.timetoken);
        
    };
    self.didReceiveMessageAssertions = ^void (PubNub *client, PNMessageResult *message) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertEqualObjects(client.uuid, message.uuid);
        XCTAssertNotNil(message.uuid);
        XCTAssertNil(message.authKey);
        XCTAssertEqual(message.statusCode, 200);
        XCTAssertTrue(message.TLSEnabled);
        XCTAssertEqual(message.operation, PNSubscribeOperation);
        NSLog(@"message:");
        NSLog(@"%@", message.data.message);
        XCTAssertNotNil(message.data);
        XCTAssertEqualObjects(message.data.message, @"***********.... 439 - 2015-12-02 14:56:06");
        XCTAssertEqualObjects(message.data.actualChannel, @"a");
        XCTAssertEqualObjects(message.data.subscribedChannel, @"a");
        XCTAssertEqualObjects(message.data.timetoken, @14490969668672102);
        [self.channelGroupSubscribeExpectation fulfill];
    };
    [self PNTest_subscribeToChannels:@[@"a"] withPresence:YES];
}

@end
