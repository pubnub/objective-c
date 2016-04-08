//
//  PNSubscribeTests.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 6/16/15.
//
//

#import <PubNub/PubNub.h>
#import <objc/runtime.h>

#import "PNBasicSubscribeTestCase.h"

@interface PNSubscribeTests : PNBasicSubscribeTestCase

@property (nonatomic, assign) NSUInteger expectedMessagesCount;
@property (nonatomic, assign) NSUInteger messageNumberToUseTimeToken;
@property (nonatomic) NSNumber *catchUpTimeToken;
@property (nonatomic) NSArray *receivedMessages;

@end

@implementation PNSubscribeTests

- (BOOL)isRecording {
    return NO;
}

- (void)setUp {
    [super setUp];
    
    if ([NSStringFromSelector(self.invocation.selector) isEqualToString:@"testSimpleSubscribeWithTimeToken"]) {
        
        [self setupForSubscribeWithTimeToken];
    }
}

- (void)setupForSubscribeWithTimeToken {
    
    PNWeakify(self);
    NSMutableArray *receivedMessages = [NSMutableArray new];
    _expectedMessagesCount = 5;
    _messageNumberToUseTimeToken = 4;
    __block NSUInteger receivedMessagesCount = 0;
    XCTestExpectation *fillExpecation = [self expectationWithDescription:@"channelFill"];
    self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
        
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.operation, PNSubscribeOperation);
        XCTAssertEqual(status.category, PNConnectedCategory);
        
        // Filling up target channel first.
        [self publish:@"Time token message #%@" count:self->_expectedMessagesCount
            toChannel:client.channels.lastObject withCompletion:^{
                PNStrongify(self);
                [self.publishExpectation fulfill];
                self.publishExpectation = nil;
            }];
        [self.subscribeExpectation fulfill];
        self.subscribeExpectation = nil;
    };
    self.didReceiveMessageAssertions = ^void (PubNub *client, PNMessageResult *message) {
        
        PNStrongify(self);
        receivedMessagesCount++;
        [receivedMessages addObject:message.data.message];
        if (receivedMessagesCount == self->_messageNumberToUseTimeToken) {
            
            self->_catchUpTimeToken = message.data.timetoken;
        }
        if (receivedMessagesCount == self->_expectedMessagesCount) {
            
            self->_receivedMessages = [receivedMessages copy];
            [fillExpecation fulfill];
        }
    };
    self.publishExpectation = [self expectationWithDescription:@"publish"];
    [self PNTest_subscribeToChannels:[self subscriptionChannels] withPresence:NO];
}

- (NSArray *)subscriptionChannels {
    
    NSArray *channels = @[@"a"];
    NSString *caseSelector = NSStringFromSelector(self.invocation.selector);
    if ([caseSelector isEqualToString:@"testSimpleSubscribeWithTimeToken"]) {
        
        channels = @[@"322A70B3-F0EA-48CD-9BB0-D3F0F5DE996C"];
    }
    else if ([caseSelector isEqualToString:@"testTimeTokenResetBetweenSubscriptionsWithUnsubscribe"] ||
             [caseSelector isEqualToString:@"testTimeTokenResetBetweenSubscriptionsWithUnsubscribeAll"]){
        
        channels = @[@"5ABCEBF2-A887-491E-9D8C-52957BEDBCCA",
                     @"343D8550-B5E3-48A5-9564-3220EA50A500"];
    }
    
    return channels;
}

/**
 @brief  Publish specified number of message to the channel and report with completion block when it
 done.
 
 @param messageFormatString Template for message which will be published and will use 
 \c messagesCount value to identify message for future purposes.
 @param messagesCount       How many messages should be sent to specified channel.
 @param channel             Name of the channel to which messages should be sent.
 @param block               Reference on block which should be called at the end of message publish 
 process.
 */
- (void)publish:(NSString *)messageFormatString count:(NSUInteger)messagesCount
      toChannel:(NSString *)channel withCompletion:(dispatch_block_t)block {
    
    __block NSUInteger messageIdx = 1;
    __block __weak dispatch_block_t weakMessagePublishBlock;
    dispatch_block_t messagePublishBlock;
    weakMessagePublishBlock = messagePublishBlock = ^{
        
        if (messageIdx <= messagesCount) {
            
            dispatch_block_t strongMessagePublishBlock = weakMessagePublishBlock;
            [self.client publish:[NSString stringWithFormat:messageFormatString, @(messageIdx)]
                       toChannel:channel withCompletion:^(PNPublishStatus *status) {
                           
                           XCTAssertNotNil(status);
                           XCTAssertFalse(status.isError);
                           XCTAssertEqual(status.operation, PNPublishOperation);
                           XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                           
                           messageIdx++;
                           strongMessagePublishBlock();
                       }];
        }
        else if (block) {
            
            block();
        }
    };
    messagePublishBlock();
}

- (void)tearDown {
    PNWeakify(self);
    self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(status);
        if (status.operation == PNSubscribeOperation) {
            return;
        }
        XCTAssertFalse(status.isError);
        //        XCTAssertEqual(status.operation, PNUnsubscribeOperation);
        //        XCTAssertEqual(status.category, PNDisconnectedCategory);
        //        XCTAssertEqual(status.subscribedChannels.count, 0);
        XCTAssertEqual(status.subscribedChannelGroups.count, 0);
        XCTAssertEqual(status.operation, PNUnsubscribeOperation);
        NSLog(@"timeToken: %@", status.currentTimetoken);
        //        XCTAssertEqualObjects(status.currentTimetoken, @14355626738514132);
        //        XCTAssertEqualObjects(status.currentTimetoken, status.data.timetoken);
        [self.unsubscribeExpectation fulfill];
        
    };
    [self PNTest_unsubscribeFromChannels:[self subscriptionChannels] withPresence:YES];
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
        XCTAssertEqual(status.subscribedChannelGroups.count, 0);
        NSArray *expectedPresenceSubscriptions = @[@"a", @"a-pnpres"];
        XCTAssertEqualObjects([NSSet setWithArray:status.subscribedChannels],
                              [NSSet setWithArray:expectedPresenceSubscriptions]);
        XCTAssertEqual(status.operation, PNSubscribeOperation);
        NSLog(@"timeToken: %@", status.currentTimetoken);
        XCTAssertEqualObjects(status.currentTimetoken, @14600770411449016);
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
        XCTAssertNil(message.data.actualChannel);
        XCTAssertEqualObjects(message.data.subscribedChannel, @"a");
        XCTAssertEqualObjects(message.data.message, @"*********...... 6809 - 2016-04-07 17:57:21");
        [self.subscribeExpectation fulfill];
        self.subscribeExpectation = nil;
    };
    [self PNTest_subscribeToChannels:[self subscriptionChannels] withPresence:YES];
}

- (void)testSimpleSubscribeWithNoPresence {
    PNWeakify(self);
    self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.category, PNConnectedCategory);
        XCTAssertEqual(status.subscribedChannelGroups.count, 0);
        NSArray *expectedPresenceSubscriptions = @[@"a"];
        XCTAssertEqualObjects([NSSet setWithArray:status.subscribedChannels],
                              [NSSet setWithArray:expectedPresenceSubscriptions]);
        XCTAssertEqual(status.operation, PNSubscribeOperation);
        NSLog(@"timeToken: %@", status.currentTimetoken);
        XCTAssertEqualObjects(status.currentTimetoken, @14600770398133870);
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
        XCTAssertNil(message.data.actualChannel);
        XCTAssertEqualObjects(message.data.subscribedChannel, @"a");
        XCTAssertEqualObjects(message.data.message, @"********....... 6808 - 2016-04-07 17:57:20");
        [self.subscribeExpectation fulfill];
    };
    [self PNTest_subscribeToChannels:[self subscriptionChannels] withPresence:NO];
}

- (void)testSimpleSubscribeWithTimeToken {
    
    PNWeakify(self);
    NSMutableArray *receivedMessages = [NSMutableArray new];
    __block NSUInteger receivedMessagesCount = 0;
    NSUInteger expectedMessagesCount = (self.expectedMessagesCount - (self.messageNumberToUseTimeToken - 1));
    __block XCTestExpectation *catchUpExpecation = [self expectationWithDescription:@"channelCatchUp"];
    self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
        
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.statusCode, 200);
        XCTAssertEqual(status.operation, PNSubscribeOperation);
        XCTAssertEqual(status.category, PNConnectedCategory);
        XCTAssertEqualObjects(status.currentTimetoken, self.catchUpTimeToken);
        XCTAssertEqual(status.subscribedChannelGroups.count, 0);
        XCTAssertEqualObjects([NSSet setWithArray:status.subscribedChannels],
                              [NSSet setWithArray:[self subscriptionChannels]]);
        [self.subscribeExpectation fulfill];
        self.subscribeExpectation = nil;
    };
    self.didReceiveMessageAssertions = ^void (PubNub *client, PNMessageResult *message) {
        
        PNStrongify(self);
        receivedMessagesCount++;
        [receivedMessages addObject:message.data.message];
        if (receivedMessagesCount == expectedMessagesCount) {
            
            NSRange messagesSubArrayRange = NSMakeRange(self.receivedMessages.count - receivedMessagesCount,
                                                        expectedMessagesCount);
            NSArray *messagesSubArray = [self.receivedMessages subarrayWithRange:messagesSubArrayRange];
            XCTAssertEqualObjects([NSSet setWithArray:messagesSubArray],
                                  [NSSet setWithArray:receivedMessages]);
            [catchUpExpecation fulfill];
        }
    };
    [self PNTest_subscribeToChannels:[self subscriptionChannels] withPresence:NO
                      usingTimeToken:self.catchUpTimeToken];
}

/**
 @brief      Make sure what used token will be reset in scenario:
 subscribed - unsuubscribed - subscribed.
 @discussion When client unsubscribed from all channels, time token should be reset to \b 0 to 
 prevent unwanted catch up.
 */
- (void)testTimeTokenResetBetweenSubscriptionsWithUnsubscribe {
    
    [self performTimeTokenResetBetweenSubscriptionsUsingUnsubscribeAll:NO];
}

- (void)testTimeTokenResetBetweenSubscriptionsWithUnsubscribeAll {
    
    [self performTimeTokenResetBetweenSubscriptionsUsingUnsubscribeAll:YES];
}

- (void)performTimeTokenResetBetweenSubscriptionsUsingUnsubscribeAll:(BOOL)useUnsubscribeAllSelector {
    
    PNWeakify(self);
    __block NSNumber *lastTimeToken = nil;
    __block PNOperationType expectedOperation = PNSubscribeOperation;
    __block PNStatusCategory expectedCategory = PNConnectedCategory;
    __block BOOL shouldUnsubscribe = YES;
    __block BOOL shouldSubscribe = NO;
    XCTestExpectation *finalSubscribeExpecation = [self expectationWithDescription:@"verificationSubscribe"];
    XCTestExpectation *unsubscribeExpectation = [self expectationWithDescription:@"unsubscribe"];
    self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
        
        PNStrongify(self);
        BOOL isVerificationSubscribe = (!shouldUnsubscribe && !shouldSubscribe);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.statusCode, 200);
        
        // Check whether this is initial subscription or not.
        if(lastTimeToken == nil) { lastTimeToken = status.currentTimetoken; }
        
        XCTAssertEqual(status.operation, expectedOperation);
        XCTAssertEqual(status.category, expectedCategory);
        if (expectedOperation == PNSubscribeOperation) {
            
            XCTAssertEqual(status.subscribedChannelGroups.count, 0);
            XCTAssertEqualObjects([NSSet setWithArray:status.subscribedChannels],
                                  [NSSet setWithArray:[self subscriptionChannels]]);
            if (!isVerificationSubscribe) { [self.subscribeExpectation fulfill]; }
            else {
                
                XCTAssertEqualObjects(status.lastTimeToken, @0);
                XCTAssertEqualObjects(status.currentTimetoken, status.data.timetoken);
                XCTAssertNotEqualObjects(status.currentTimetoken, lastTimeToken);
                [finalSubscribeExpecation fulfill];
            }
        }
        else {
            
            XCTAssertEqual(status.subscribedChannelGroups.count, 0);
            XCTAssertEqual(status.subscribedChannels.count, 0);
            [unsubscribeExpectation fulfill];
        }
        
        if (shouldUnsubscribe) {
            
            shouldUnsubscribe = NO;
            shouldSubscribe = YES;
            expectedOperation = PNUnsubscribeOperation;
            expectedCategory = PNDisconnectedCategory;
            if (useUnsubscribeAllSelector) { [self.client unsubscribeFromAll]; }
            else {
                
                [self.client unsubscribeFromChannels:[self subscriptionChannels] withPresence:NO];
            }
        }
        else if (shouldSubscribe) {
            
            shouldSubscribe = NO;
            expectedOperation = PNSubscribeOperation;
            expectedCategory = PNConnectedCategory;
            [self.client subscribeToChannels:[self subscriptionChannels] withPresence:NO];
        }
    };
    [self PNTest_subscribeToChannels:[self subscriptionChannels] withPresence:NO];
}

@end