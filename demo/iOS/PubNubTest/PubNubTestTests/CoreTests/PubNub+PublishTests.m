//
//  PubNub+PublishTests.m
//  PubNubTest
//
//  Created by Vadim Osovets on 5/27/15.
//  Copyright (c) 2015 Vadim Osovets. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import <PubNub/PubNub.h>

#import "TestConfigurator.h"

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

@interface PubNub_PublishTests : XCTestCase

@end

@implementation PubNub_PublishTests {
    PubNub *_pubNub;
}

- (void)setUp {
    
    [super setUp];
    _pubNub = [PubNub clientWithPublishKey:[[TestConfigurator shared] mainPubKey]
                           andSubscribeKey:[[TestConfigurator shared] mainSubKey]];
}

- (void)tearDown {
    
    _pubNub = nil;
    [super tearDown];
}

#pragma mark - Tests Messages (compressed:NO)

- (void)testPublishNilMessage {
    
    [_pubNub publish:nil
           toChannel:[TestConfigurator uniqueString]
   mobilePushPayload:nil
      storeInHistory:NO
          compressed:NO
      withCompletion:^(PNStatus *status) {
          
       }];
}

- (void)testPublishEmptyMessage {
    
    [_pubNub publish:@""
           toChannel:[TestConfigurator uniqueString]
   mobilePushPayload:nil
      storeInHistory:NO
          compressed:NO
      withCompletion:^(PNStatus *status) {
          
      }];
}

- (void)testPublishHugeMessage {
    
    [_pubNub publish:[self randomStringWithLength:40000]
           toChannel:[TestConfigurator uniqueString]
   mobilePushPayload:nil
      storeInHistory:NO
          compressed:NO
      withCompletion:^(PNStatus *status) {
          
      }];
}

- (void)testPublishWeirdMessage {
    
    [_pubNub publish:@"WeirdMessage: /?#[]@!$&’()*+,;="
           toChannel:[TestConfigurator uniqueString]
   mobilePushPayload:nil
      storeInHistory:NO
          compressed:NO
      withCompletion:^(PNStatus *status) {
          
      }];
}


#pragma mark - Tests Messages (compressed:YES)

- (void)testPublishCompressedNilMessage {
    
    [_pubNub publish:nil
           toChannel:[TestConfigurator uniqueString]
   mobilePushPayload:nil
      storeInHistory:NO
          compressed:YES
      withCompletion:^(PNStatus *status) {
          
      }];
}

- (void)testPublishCompressedEmptyMessage {
    
    [_pubNub publish:@""
           toChannel:[TestConfigurator uniqueString]
   mobilePushPayload:nil
      storeInHistory:NO
          compressed:YES
      withCompletion:^(PNStatus *status) {
          
      }];
}

- (void)testPublishCompressedHugeMessage {
    
    [_pubNub publish:[self randomStringWithLength:40000]
           toChannel:[TestConfigurator uniqueString]
   mobilePushPayload:nil
      storeInHistory:NO
          compressed:YES
      withCompletion:^(PNStatus *status) {
          
      }];
}

- (void)testPublishCompressedWeirdMessage {
    
    [_pubNub publish:@"WeirdMessage: /?#[]@!$&’()*+,;="
           toChannel:[TestConfigurator uniqueString]
   mobilePushPayload:nil
      storeInHistory:NO
          compressed:YES
      withCompletion:^(PNStatus *status) {
          
      }];
}
#pragma mark - Tests Channels

- (void)testPublishMessageToNilChannel {
    
    [_pubNub publish:[TestConfigurator uniqueString]
           toChannel:nil
   mobilePushPayload:nil
      storeInHistory:NO
          compressed:NO
      withCompletion:^(PNStatus *status) {
          
      }];
}

- (void)testPublishMessageToNotStringChannels {
    
    NSNumber *number = @5;
    
    [_pubNub publish:[TestConfigurator uniqueString]
           toChannel:(NSString *)number
   mobilePushPayload:nil
      storeInHistory:NO
          compressed:NO
      withCompletion:^(PNStatus *status) {
          
      }];
}

- (void)testPublishMessageToNotValidChannel {
    
    [_pubNub publish:[TestConfigurator uniqueString]
           toChannel:@""
   mobilePushPayload:nil
      storeInHistory:NO
          compressed:NO
      withCompletion:^(PNStatus *status) {
          
      }];
}

- (void)testPublishMessageToChannelWithLongName {
    
    [_pubNub publish:@""
           toChannel:[self randomStringWithLength:1000]
   mobilePushPayload:nil
      storeInHistory:NO
          compressed:NO
      withCompletion:^(PNStatus *status) {
          
      }];
}

- (void)testPublishMessageToChannels {
    
    [_pubNub publish:[TestConfigurator uniqueString]
           toChannel:[NSString stringWithFormat:@"%@,%@", [TestConfigurator uniqueString], [TestConfigurator uniqueString]]
   mobilePushPayload:nil
      storeInHistory:NO
          compressed:NO
      withCompletion:^(PNStatus *status) {
          
      }];
}


#pragma mark - Private methods

-(NSString *)randomStringWithLength:(int)length {
    
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    
    for (int i = 0; i < length; i++) {
        
        [randomString appendFormat: @"%C",[letters characterAtIndex:(NSUInteger)arc4random_uniform((u_int32_t)[letters length])]];
    }
    return randomString;
}

@end
