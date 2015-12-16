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
    _messageNumberToUseTimeToken = 3;
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
            toChannel:client.channels.lastObject withCompletion:NULL];
        [self.subscribeExpectation fulfill];
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
    [self PNTest_subscribeToChannels:[self subscriptionChannels] withPresence:NO];
}

- (BOOL)isRecording{
    
    return NO;
}

- (NSArray *)subscriptionChannels {
    
    NSArray *channels = @[@"a"];
    if ([NSStringFromSelector(self.invocation.selector) isEqualToString:@"testSimpleSubscribeWithTimeToken"]) {
        
        channels = @[@"322A70B3-F0EA-48CD-9BB0-D3F0F5DE996C"];
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
        XCTAssertEqualObjects(status.currentTimetoken, @14491012608783773);
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
        XCTAssertEqualObjects(message.data.actualChannel, @"a");
        XCTAssertEqualObjects(message.data.subscribedChannel, @"a");
        XCTAssertEqualObjects(message.data.message, @"*******........ 4080 - 2015-12-02 16:07:41");
        [self.subscribeExpectation fulfill];
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
        XCTAssertEqualObjects(status.currentTimetoken, @14491012597272806);
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
        XCTAssertEqualObjects(message.data.actualChannel, @"a");
        XCTAssertEqualObjects(message.data.subscribedChannel, @"a");
        XCTAssertEqualObjects(message.data.message, @"******......... 4079 - 2015-12-02 16:07:40");
        [self.subscribeExpectation fulfill];
    };
    [self PNTest_subscribeToChannels:[self subscriptionChannels] withPresence:NO];
}

- (void)testSimpleSubscribeWithTimeToken {
    
    PNWeakify(self);
    NSMutableArray *receivedMessages = [NSMutableArray new];
    __block NSUInteger receivedMessagesCount = 0;
    NSUInteger expectedMessagesCount = (self.expectedMessagesCount - self.messageNumberToUseTimeToken);
    XCTestExpectation *catchUpExpecation = [self expectationWithDescription:@"channelCatchUp"];
    self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
        
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.operation, PNSubscribeOperation);
        XCTAssertEqual(status.category, PNConnectedCategory);
        XCTAssertEqualObjects(status.currentTimetoken, self.catchUpTimeToken);
        XCTAssertNotEqualObjects(status.currentTimetoken, status.data.timetoken);
        XCTAssertEqual(status.subscribedChannelGroups.count, 0);
        XCTAssertEqualObjects([NSSet setWithArray:status.subscribedChannels],
                              [NSSet setWithArray:[self subscriptionChannels]]);
        [self.subscribeExpectation fulfill];
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

@end
