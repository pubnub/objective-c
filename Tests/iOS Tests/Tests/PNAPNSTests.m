//
//  PNAPNSTests.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 3/23/16.
//
//

#import <PubNub/PubNub.h>

#import "PNBasicSubscribeTestCase.h"

#import "NSString+PNTest.h"

@interface PNAPNSTests : PNBasicClientTestCase

@property XCTestExpectation *testExpectation;

@end

@implementation PNAPNSTests

- (void)setUp {
    [super setUp];
    
    // On Account you put there we obligatory need to enable Push Notifications
    // using PubNub Developer Console
    self.configuration = [PNConfiguration configurationWithPublishKey:self.publishKey
                                                         subscribeKey:self.subscribeKey];
    self.configuration.uuid = @"322A70B3-F0EA-48CD-9BB0-D3F0F5DE996C";
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    self.configuration.stripMobilePayload = NO;
#pragma clang diagnostic pop
    
    self.client = [PubNub clientWithConfiguration:self.configuration];
}

- (BOOL)isRecording{
    return NO;
}

#pragma mark - Tests

- (void)testAddPushOnChannels {
    
    self.testExpectation = [self expectationWithDescription:@"Add Push Expectation."];
    
    NSArray *channels = @[@"1", @"2", @"3"];
    NSString *pushKey = @"6652cff7f17536c86bc353527017741ec07a91699661abaf68c5977a83013091";
    
    NSData *pushToken = [pushKey dataFromHexString:pushKey];
    
    PNWeakify(self);
    
    [self.client addPushNotificationsOnChannels:channels
                            withDevicePushToken:pushToken
                                  andCompletion:^(PNAcknowledgmentStatus *status) {
                                      
                                      PNStrongify(self);
                                      
                                      XCTAssertNotNil(status);
                                      XCTAssertFalse(status.isError);
                                      XCTAssertEqual(status.statusCode, 200, @"Response status code is not 200");
                                      
                                      [self.testExpectation fulfill];
                                  }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)testAddPushOnNilChannels {
    
    self.testExpectation = [self expectationWithDescription:@"Add Push Expectation."];
    
    NSArray *channels = nil;
    NSString *pushKey = @"6652cff7f17536c86bc353527017741ec07a91699661abaf68c5977a83013091";
    
    NSData *pushToken = [pushKey dataFromHexString:pushKey];
    
    PNWeakify(self);
    
    [self.client addPushNotificationsOnChannels:channels
                            withDevicePushToken:pushToken
                                  andCompletion:^(PNAcknowledgmentStatus *status) {
                                      
                                      PNStrongify(self);
                                      
                                      XCTAssertNotNil(status);
                                      XCTAssertTrue(status.isError);
                                      XCTAssertEqual(status.statusCode, 400, @"Response status code is not 400");
                                      
                                      [self.testExpectation fulfill];
                                  }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
    
}

- (void)testAddPushOnChannelsWithNilPushToken {
    self.testExpectation = [self expectationWithDescription:@"Add Push Expectation."];
    
    NSArray *channels = @[@"1", @"2", @"3"];
    NSData *pushToken = nil;
    
    PNWeakify(self);
    
    [self.client addPushNotificationsOnChannels:channels
                            withDevicePushToken:pushToken
                                  andCompletion:^(PNAcknowledgmentStatus *status) {
                                      
                                      PNStrongify(self);
                                      
                                      XCTAssertNotNil(status);
                                      XCTAssertTrue(status.isError);
                                      XCTAssertEqual(status.statusCode, 400, @"Response status code is not 400");
                                      
                                      [self.testExpectation fulfill];
                                  }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}


- (void)testRemovePushNotificationFromChannel {
    self.testExpectation = [self expectationWithDescription:@"Remove Push Expectation."];
    
    NSArray *channels = @[@"1", @"2", @"3"];;
    NSString *pushKey = @"6652cff7f17536c86bc353527017741ec07a91699661abaf68c5977a83013091";

    NSData *pushToken = [pushKey dataFromHexString:pushKey];
    
    PNWeakify(self);
    
    [self.client removePushNotificationsFromChannels:channels
                                 withDevicePushToken:pushToken
                                       andCompletion:^(PNAcknowledgmentStatus *status) {
                                           
                                      PNStrongify(self);
                                      
                                      XCTAssertNotNil(status);
                                      XCTAssertFalse(status.isError);
                                      XCTAssertEqual(status.operation, PNRemovePushNotificationsFromChannelsOperation, @"Wrong operation.");
                                           
                                      XCTAssertEqual(status.statusCode, 200, @"Response status code is not 200");

                                      
                                      [self.testExpectation fulfill];
                                  }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)testRemovePushNotificationFromNilChannel {
    self.testExpectation = [self expectationWithDescription:@"Remove Push Expectation."];
    
    NSArray *channels = nil;
    NSString *pushKey = @"6652cff7f17536c86bc353527017741ec07a91699661abaf68c5977a83013091";
    
    NSData *pushToken = [pushKey dataFromHexString:pushKey];
    
    PNWeakify(self);
    
    [self.client removePushNotificationsFromChannels:channels
                                 withDevicePushToken:pushToken
                                       andCompletion:^(PNAcknowledgmentStatus *status) {
                                           
                                           PNStrongify(self);
                                           
                                           XCTAssertNotNil(status);
                                           XCTAssertFalse(status.isError);
                                           XCTAssertEqual(status.operation, PNRemoveAllPushNotificationsOperation, @"Wrong operation.");
                                           
                                           XCTAssertEqual(status.statusCode, 200, @"Response status code is not 200");
                                           
                                           [self.testExpectation fulfill];
                                       }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)testRemovePushNotificationFromNilChannelWithNilDevicePushToken {
    self.testExpectation = [self expectationWithDescription:@"Remove Push Expectation."];
    
    NSArray *channels = nil;
    NSData *pushToken = nil;
    
    PNWeakify(self);
    
    [self.client removePushNotificationsFromChannels:channels
                                 withDevicePushToken:pushToken
                                       andCompletion:^(PNAcknowledgmentStatus *status) {
                                           
                                           PNStrongify(self);
                                           
                                           XCTAssertNotNil(status);
                                           XCTAssertTrue(status.isError);
                                           XCTAssertEqual(status.operation, PNRemoveAllPushNotificationsOperation, @"Wrong operation.");
                                           
                                           XCTAssertEqual(status.statusCode, 400, @"Response status code is not 400");
                                           
                                           [self.testExpectation fulfill];
                                       }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)testRemovePushNotificationFromChannelWithNilDevicePushToken {
    self.testExpectation = [self expectationWithDescription:@"Remove Push Expectation."];
    
    NSArray *channels = @[@"1", @"2", @"3"];
    
    NSData *pushToken = nil;
    
    PNWeakify(self);
    
    [self.client removePushNotificationsFromChannels:channels
                                 withDevicePushToken:pushToken
                                       andCompletion:^(PNAcknowledgmentStatus *status) {
                                           
                                           PNStrongify(self);
                                           
                                           XCTAssertNotNil(status);
                                           XCTAssertTrue(status.isError);
                                           XCTAssertEqual(status.operation, PNRemovePushNotificationsFromChannelsOperation, @"Wrong operation.");
                                           XCTAssertEqual(status.statusCode, 400, @"Response status code is not 400");
                                           
                                           [self.testExpectation fulfill];
                                       }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)testRemoveAllPushNotificationFromDevice  {
    self.testExpectation = [self expectationWithDescription:@"Remove Push Expectation."];
    
    NSString *pushKey = @"6652cff7f17536c86bc353527017741ec07a91699661abaf68c5977a83013091";
    
    NSData *pushToken = [pushKey dataFromHexString:pushKey];
    
    PNWeakify(self);
    
    [self.client removeAllPushNotificationsFromDeviceWithPushToken:pushToken
                                                     andCompletion:^(PNAcknowledgmentStatus *status) {
                                           
                                           PNStrongify(self);
                                           
                                           XCTAssertNotNil(status);
                                           XCTAssertFalse(status.isError);
                                           XCTAssertEqual(status.operation, PNRemoveAllPushNotificationsOperation, @"Wrong operation.");
                                           
                                           XCTAssertEqual(status.statusCode, 200, @"Response status code is not 200");
                                           
                                           [self.testExpectation fulfill];
                                       }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

}

- (void)testRemoveAllPushNotificationFromDeviceWithNilToken  {
    self.testExpectation = [self expectationWithDescription:@"Remove Push Expectation."];
    
    NSData *pushToken = nil;
    
    PNWeakify(self);
    
    [self.client removeAllPushNotificationsFromDeviceWithPushToken:pushToken
                                                     andCompletion:^(PNAcknowledgmentStatus *status) {
                                                         
                                                         PNStrongify(self);
                                                         
                                                         XCTAssertNotNil(status);
                                                         XCTAssertTrue(status.isError);
                                                         XCTAssertEqual(status.operation, PNRemoveAllPushNotificationsOperation, @"Wrong operation.");
                                                         
                                                         XCTAssertEqual(status.statusCode, 400, @"Response status code is not 400");
                                                         
                                                         [self.testExpectation fulfill];
                                                     }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)testAuditPushNotificationStatus  {
    self.testExpectation = [self expectationWithDescription:@"Remove Push Expectation."];

    NSString *pushKey = @"6652cff7f17536c86bc353527017741ec07a91699661abaf68c5977a83013091";
    
    NSData *pushToken = [pushKey dataFromHexString:pushKey];
    
    PNWeakify(self);
    
    [self.client pushNotificationEnabledChannelsForDeviceWithPushToken:pushToken
                                                         andCompletion:^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
                                                         
                                                         PNStrongify(self);
                                                         
                                                         XCTAssertNil(status);
                                                         XCTAssertEqual(result.operation, PNPushNotificationEnabledChannelsOperation, @"Wrong operation.");
                                                         
                                                         XCTAssertEqual(result.statusCode, 200, @"Response status code is not 200");
                                                             
                                                         XCTAssertTrue([result.data.channels count] == 3, @"Channel list is not equal.");
                                                         
                                                         [self.testExpectation fulfill];
                                                     }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)testAuditPushNotificationStatusWithNilPushToken  {
    self.testExpectation = [self expectationWithDescription:@"Remove Push Expectation."];
    
    NSData *pushToken = nil;
    
    PNWeakify(self);
    
    [self.client pushNotificationEnabledChannelsForDeviceWithPushToken:pushToken
                                                         andCompletion:^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
                                                             
                                                             PNStrongify(self);
                                                             
                                                             XCTAssertNil(result);
                                                             XCTAssertNotNil(status);
                                                             XCTAssertEqual(status.operation, PNPushNotificationEnabledChannelsOperation, @"Wrong operation.");
                                                             
                                                             XCTAssertEqual(status.statusCode, 400, @"Response status code is not 400");
                                                             
                                                             [self.testExpectation fulfill];
                                                         }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
    
}

@end
