//
//  PNCryptoHistoryTest.m
//  UnitTests
//
//  Created by Vadim Osovets on 10/30/14.
//  Copyright (c) 2014 Vadim Osovets. All rights reserved.
//

/**
 Scenario:
  - connect and use encrypted messaging;
  - try to read history.
 */

#import <XCTest/XCTest.h>

@interface PNCryptoHistoryTest : XCTestCase

<PNDelegate>

@end

@implementation PNCryptoHistoryTest {
    PubNub *_pubNub;
    
    PNConfiguration *_configuration;
    PNChannel *_channel;
    
    id _message;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    [PubNub disconnect];
    
    _configuration = [PNConfiguration configurationForOrigin:kTestPNOriginHost
                                                                  publishKey:kTestPNPublishKey subscribeKey:kTestPNSubscriptionKey secretKey:kTestPNSecretKey cipherKey:kTestPNCipherKey];
    
    _pubNub = [PubNub clientWithConfiguration:_configuration andDelegate:self];
    _channel = [PNChannel channelWithName:@"test_history_crypto"];
    
    _message = @{@"test": @"test"};
}

- (void)tearDown
{
    [PubNub disconnect];
    
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCryptoMessages {
    dispatch_group_t resGroup = dispatch_group_create();
    
    [_pubNub connect];
    
    dispatch_group_enter(resGroup);
    
    [_pubNub sendMessage:_message
               toChannel:_channel
              compressed:YES
     withCompletionBlock:^(PNMessageState messageState, id message) {
         switch (messageState) {
             case PNMessageSent:
                 dispatch_group_leave(resGroup);
                 break;
             default:
                 break;
         }
     }];
    
    if ([GCDWrapper isGroup:resGroup timeoutFiredValue:20]) {
        XCTFail(@"Cannot send a message to group.");
        
        dispatch_group_leave(resGroup);
        resGroup = NULL;
        return;
    }
    
    // read message from history
    
    dispatch_group_enter(resGroup);
    
    [_pubNub requestFullHistoryForChannel:_channel
                      withCompletionBlock:^(NSArray *messages, PNChannel *channel, PNDate *startDate, PNDate *endDate, PNError *error) {
                          if (error) {
                              XCTFail(@"Error during request history.");
                          }
                          
                          // check if we receive the same message we've got
                          id message = [[messages lastObject] message];
                          
                          if (!([message isKindOfClass:[NSDictionary class]] && [_message isEqualToDictionary:message])) {
                              XCTFail(@"Messages are not equal.");
                          }
                          
                          dispatch_group_leave(resGroup);
                      }];
    
    if ([GCDWrapper isGroup:resGroup timeoutFiredValue:20]) {
        XCTFail(@"Cannot request history from channel: %@", _channel.name);
        
        dispatch_group_leave(resGroup);
        resGroup = NULL;
        return;
    }
}

@end
