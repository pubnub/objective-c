//
//  HugeCompressedMessageTest.m
//  pubnub
//
//  Created by Vadim Osovets on 4/15/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface HugeCompressedMessageTest : XCTestCase <PNDelegate>
@end

@implementation HugeCompressedMessageTest {
    GCDGroup *_resGroup;
    NSString *maxAllowMessage;
}

- (void)setUp
{
    [super setUp];
    [PubNub disconnect];
    [PubNub setDelegate:self];
}

- (void)tearDown
{
    [PubNub setDelegate:nil];
    maxAllowMessage = nil;
    [PubNub disconnect];
    [super tearDown];
}

- (void)testScenario {
    
    XCTAssertTrue([self connectToPubNub]);
    XCTAssertTrue([self subscribeOnChannels:@[@"test_a"]]);
    
    //  The maximum allowable message - 30000 digits
    XCTAssertTrue([self sendMessageToChannel:@"test_a" message:[self creatMessageOfSize:30000]]);
    
    //  The message > 30000 digits is not allowable (limit from PubNub)
    XCTAssertFalse([self sendMessageToChannel:@"test_a" message:[self creatMessageOfSize:40000]]);
    
    XCTAssertTrue([self unsubscribeFromChannels:@[@"test_a"]]);
    
}

- (BOOL)connectToPubNub {
    
    _resGroup = [GCDGroup group];
    [_resGroup enter];
    
    PNConfiguration *configuration = [PNConfiguration configurationForOrigin:kTestPNOriginHost
                                                                  publishKey:kTestPNPublishKey
                                                                subscribeKey:kTestPNSubscriptionKey
                                                                   secretKey:nil
                                                                   cipherKey:nil];
    [PubNub setConfiguration:configuration];
    
    [PubNub connectWithSuccessBlock:^(NSString *origin) {
        [_resGroup leave];
    } errorBlock:^(PNError *connectionError) {
        XCTFail(@"Error when connection %@", connectionError);
        [_resGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:5]) {
        XCTFail(@"Timeout is fired. PubNub does't connected");
        return NO;
    }
    
    _resGroup = nil;
    return [[PubNub sharedInstance] isConnected];
    
}

- (BOOL)subscribeOnChannels:(NSArray*)subChannels {
    
    _resGroup = [GCDGroup group];
    [_resGroup enter];
    
    NSArray *_channels = [PNChannel channelsWithNames:subChannels];
    
    [PubNub subscribeOn:_channels withClientState:nil andCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
        XCTAssertNil(error,@"Error when subscribing on channels");
        switch (state) {
            case PNSubscriptionProcessSubscribedState: {
                [_resGroup leave];
            }
                break;
            default:
                break;
        }
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:5]) {
        XCTFail(@"Timeout is fired. Didn't subscribe on channels");
        return NO;
    } else {
        _resGroup = nil;
        return YES;
    }
}

- (NSString *)creatMessageOfSize:(int)size {
    int i;
    maxAllowMessage = [NSString new];
        for (i = 1; i < size; i++) {
            maxAllowMessage = [maxAllowMessage stringByAppendingString:[NSString stringWithFormat:@"%d", arc4random() % 10]];
        }
    return maxAllowMessage;
}

- (BOOL)sendMessageToChannel:(NSString *)channel
                    message:(NSString *)message {
    PNChannel *_channel = [PNChannel channelWithName:channel];
    
    _resGroup = [GCDGroup group];
    [_resGroup enter];
    
    [PubNub sendMessage:message
               toChannel:_channel
              compressed:YES
     withCompletionBlock:^(PNMessageState state, id data) {
          switch (state) {
             case PNMessageSending:
                 break;
             case PNMessageSendingError:
                 NSLog(@"Error during PNMessageSending occured: PNMessageSendingError");
                 break;
             case PNMessageSent:
                 [_resGroup leave];
                 break;
         }
     }];

    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:3]) {
        NSLog(@"Timeout is fired. Not all messages were sent");
        return NO;
    }
    
    _resGroup = nil;
    return YES;
    
}

- (BOOL)unsubscribeFromChannels:(NSArray*)unsubChannels {
    
    _resGroup = [GCDGroup group];
    [_resGroup enter];
    
    NSArray *_channels = [PNChannel channelsWithNames:unsubChannels];
    
    [PubNub unsubscribeFrom:_channels withCompletionHandlingBlock:^(NSArray *channels, PNError *error) {
        XCTAssertNil(error,@"Error unsubscribing from channels");
        [_resGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:5]) {
        XCTFail(@"Timeout is fired. Didn't unsubscribing from channels");
        return NO;
    }
    
    _resGroup = nil;
    return YES;
    
}

@end

