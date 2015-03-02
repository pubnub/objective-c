//
//  PNSizeOfMessageTest.m
//  UnitTests
//
//  Created by Sergey Kazanskiy on 2/26/15.
//  Copyright (c) 2015 PubNub. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

static const NSUInteger kMaxAmoutOfMessages = 10000;

@interface PNSizeOfMessageTest : XCTestCase

<
PNDelegate
>

@end

@implementation PNSizeOfMessageTest {
    GCDGroup *_resGroup;
    PubNub *_pubNub;
    NSString *_testMessage;
    NSMutableDictionary *_dictionaryMessages;
}

- (void)setUp {
    [super setUp];
    
    [PubNub disconnect];
    [PubNub setDelegate:self];
    
 }

- (void)tearDown {
    [PubNub disconnect];
    [super tearDown];
}


#pragma mark - Tests

- (void)testEqualitySizeTheSameMessages {
    
//    Connect
    _resGroup = [GCDGroup group];
    [_resGroup enter];
    
    _pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
    [_pubNub connect];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Didn't connect to PubNub");
        _resGroup = nil;
        return;
    }

//    Preparing an array of random size messages
    _dictionaryMessages = [NSMutableDictionary dictionaryWithCapacity:5];
    
    for (int i = 1; i < 5; i++) {
        NSString *value = [self creatMessageOfSize:i * kMaxAmoutOfMessages];
        NSString *key = [NSString stringWithFormat:@"Message %d", i];
        
        [_dictionaryMessages setValue:value forKey:key];
    }

//    Sending an array of messages 2 times
    __block NSUInteger messageSize1 = 0;
    __block NSUInteger messageSize2 = 0;
    PNChannel *testChannel = [PNChannel channelWithName:@"iosdev"];

    [_resGroup enterTimes:8];
    
    for (int j = 0; j < 2; j++) {
        
        NSUInteger count = _dictionaryMessages.count + 1;
        for (int i = 1; i < count; i++) {
            
            NSString *key = [NSString stringWithFormat:@"Message %d", i];
            NSString *testMessage = [_dictionaryMessages objectForKey:key];
            
            [_pubNub sizeOfMessage:testMessage toChannel:testChannel compressed:YES storeInHistory:YES withCompletionBlock:^(NSUInteger size) {
                [_resGroup leave];
                
                if (j == 0) {
                    messageSize1 = messageSize1 + size;
                } else if (j == 1) {
                    messageSize2 = messageSize2 + size;
                }
            }];
        }
    }
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:30]) {
        XCTFail(@"Timeout is fired. Didn't receive size of message");
        _resGroup = nil;
        return;
    }
    
//    Size comparison of two arrays of messages
    XCTAssertTrue(messageSize1 == messageSize2);
}


- (void)testSizeEmptyMessage {
    
    //    Connect
    _resGroup = [GCDGroup group];
    [_resGroup enter];
    
    _pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
    [_pubNub connect];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Didn't connect to PubNub");
        _resGroup = nil;
        return;
    }
    
    //    Size  measurement
    PNChannel *testChannel = [PNChannel channelWithName:@"iosdev"];
    NSString *testMessage = @"";
    __block NSUInteger messageSize = 0;
    
    [_resGroup enter];
    
    [_pubNub sizeOfMessage:testMessage toChannel:testChannel compressed:YES storeInHistory:YES withCompletionBlock:^(NSUInteger size) {
        [_resGroup leave];
        messageSize = size;
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:30]) {
        XCTFail(@"Timeout is fired. Didn't receive size of message");
        _resGroup = nil;
        return;
    }
    
    XCTAssertTrue(messageSize == 312);
}

- (void)testSaveMesssageInHistory {
    
    // Connect
    _resGroup = [GCDGroup group];
    [_resGroup enter];
    
    _pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
    [_pubNub connect];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Didn't connect to PubNub");
        _resGroup = nil;
        return;
    }
    
    // Size  measurement
    PNChannel *testChannel = [PNChannel channelWithName:@"iosdev"];
    NSString *testMessage = [self creatMessageOfSize:10];
    
    __block NSUInteger messageSize = 0;
    
    [_resGroup enter];
    
    [_pubNub sizeOfMessage:testMessage toChannel:testChannel compressed:YES storeInHistory:YES withCompletionBlock:^(NSUInteger size) {
        [_resGroup leave];
        messageSize = size;
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Didn't receive size of message");
        _resGroup = nil;
        return;
    }
    
    // Request last message from history
    __block NSString *lastMessage;
    
    [_resGroup enter];
    
    [_pubNub requestFullHistoryForChannel:testChannel withCompletionBlock:^(NSArray *messages, PNChannel *channel, PNDate *startDate, PNDate *endDate, PNError *error) {
        
        if (error) {
            XCTFail(@"Error request history");
        } else {
            [_resGroup leave];
            lastMessage = [[messages lastObject] message];
        }
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Didn't receive size of message");
        _resGroup = nil;
        return;
    }
    
    // Test message should not be in the history
    XCTAssertFalse(testMessage == lastMessage);
}

//NSUInteger sizeOfMessage = 0;
//if (self.clientConfiguration) self.cryptoHelper.ready encryptionError != nil

- (void)testUnit {
    
    _resGroup = [GCDGroup group];
    
    NSString *testMessage = @"Hello world";
    PNChannel *testChannel = [PNChannel channelWithName:@"iosdev"];
 
    //  Client - incorrect publishKey
    PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@" .pubnub.co"
                                                                   publishKey:nil
                                                                 subscribeKey:nil
                                                                    secretKey:nil
                                                                    cipherKey:nil];
    
    [_pubNub setConfiguration:configuration];
    [_pubNub connect];
    
    [_resGroup enter];
    
    [_pubNub sizeOfMessage:testMessage toChannel:testChannel compressed:YES storeInHistory:YES withCompletionBlock:^(NSUInteger size) {
                [_resGroup leave];
                XCTAssertTrue(size == 0);
            }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:10]) {
//        XCTFail(@"Timeout is fired. Didn't receive size of message");
        _resGroup = nil;
        return;
    }
    _resGroup = nil;
    
    // CryptoHelper ready
    [_resGroup enter];
    
    _pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
    [_pubNub connect];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Didn't connect to PubNub");
        [_resGroup leave];
        _resGroup = nil;
        return;
    }
    
    [_resGroup enter];
    
    [_pubNub sizeOfMessage:testMessage toChannel:testChannel compressed:YES storeInHistory:YES withCompletionBlock:^(NSUInteger size) {
        [_resGroup leave];
        
        
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Didn't receive size of message");
        _resGroup = nil;
        return;
    }

   
}


#pragma mark - Private methods

- (NSString *)creatMessageOfSize:(int)size {
    
    _testMessage = [NSString new];
    
    for (int i = 1; i < size; i++) {
        _testMessage = [_testMessage stringByAppendingString:[NSString stringWithFormat:@"%d", arc4random() % 10]];
    }
    return _testMessage;
}

#pragma mark - PubNub Delegate

// Connect did
- (void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin {
    if (_resGroup) {
        [_resGroup leave];
    }
}

// Connect fail
- (void)pubnubClient:(PubNub *)client connectionDidFailWithError:(PNError *)error {
    XCTFail(@"Did fail connection: %@", error);
    
    if (_resGroup) {
        [_resGroup leave];
    }
}

// Send message did
- (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
    if (_resGroup) {
        [_resGroup leave];
    }
}

// Send message fail
- (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
    XCTFail(@"Did fail message send: %@", error);
    
    if (_resGroup) {
        [_resGroup leave];
    }
}


@end


//__block NSMutableDictionary *_dictionarySizeMessages = [[NSMutableDictionary alloc] init];
//    NSString *testMessage = [NSString stringWithFormat:@"Hello"];
//                NSString *value = [NSString stringWithFormat:@"%lu", (unsigned long)size];
//                [_dictionarySizeMessages setObject:value forKey:key];

