//
//  PNCryptoInstanceTest.m
//  UnitTests
//
//  Created by Sergey on 10/27/14.
//  Copyright (c) 2014 Vadim Osovets. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "PNCryptoHelperTest.h"
#import "PNJSONSerialization.h"
#import "PNConfiguration.h"
#import "PNCryptoHelper.h"

static NSString *kOriginPath = @"pubsub.pubnub.com";
static NSString *kPublishKey = @"demo";
static NSString *kSubscribeKey = @"demo";
static NSString *kSecretKey = nil;

@interface PNCryptoInstanceTest : XCTestCase <PNDelegate> {

    // First user
    PNConfiguration *_firstUserConfiguration;
    PNCryptoHelper *_firstUserCryptoHelper;
    PubNub *_firstUserPubNub;
    
    // Second user
    PNConfiguration *_secondUserConfiguration;
    PNCryptoHelper *_secondUserCryptoHelper;
    PubNub *_secondUserPubNub;
    
     NSMutableArray *_arrayMessages;
    PNChannel *_testChannel;
    NSString *_testMessage;
    PNCryptoHelper *_cryptoHelper;
    NSInteger _numberMessage;
    NSString *_resultMessage;
}
@end


@implementation PNCryptoInstanceTest {
    dispatch_group_t _resGroup1;
    dispatch_group_t _resGroup2;
    dispatch_group_t _resGroup3;
    dispatch_group_t _resGroup4;
    dispatch_group_t _resGroup5;
}

- (void)setUp {
    [super setUp];
    [_firstUserPubNub disconnect];
    [_secondUserPubNub disconnect];
    
    // Configuration first user
    _firstUserConfiguration = [PNConfiguration configurationForOrigin:kOriginPath
                                                           publishKey:kPublishKey
                                                         subscribeKey:kSubscribeKey
                                                            secretKey:kSecretKey
                                                            cipherKey:@"enigma"];
    // Connection first user
    _firstUserPubNub = [PubNub clientWithConfiguration:_firstUserConfiguration andDelegate:self];
    
    
    // Configuration second user
    _secondUserConfiguration = [PNConfiguration configurationForOrigin:kOriginPath
                                                            publishKey:kPublishKey
                                                          subscribeKey:kSubscribeKey
                                                             secretKey:kSecretKey
                                                            cipherKey:@"enigma"];
    // Connection second user
    _secondUserPubNub = [PubNub clientWithConfiguration:_secondUserConfiguration andDelegate:self];
    
    // Crypto helper
    PNError *helperInitializationError = nil;
    _cryptoHelper = [PNCryptoHelper helperWithConfiguration:_secondUserConfiguration error:&helperInitializationError];
    
    if (helperInitializationError) {
        NSLog(@"%@ setup error: %@", self.name, helperInitializationError);
    }
    
    // Test data
    _arrayMessages = nil;
    _arrayMessages = [[NSMutableArray alloc] init];
    
    [_arrayMessages addObject:@"Hello World 1"];
    [_arrayMessages addObject:@"Hello World 2"];
//    [_arrayMessages addObject:@""];
//    [_arrayMessages addObject:[NSString stringWithFormat:@"%@", [NSDate date]]];
    
    // Test channel
    _testChannel = [PNChannel channelWithName:@"iosdev"];
}

- (void)tearDown {
    _firstUserConfiguration = nil;
    _firstUserCryptoHelper = nil;
    _secondUserConfiguration = nil;
    _secondUserCryptoHelper = nil;
    _arrayMessages = nil;
    
    [_firstUserPubNub disconnect];
    [_secondUserPubNub disconnect];
    
    [PubNub setDelegate:nil];
    [super tearDown];
}

- (void)testCryptoInstance {
    
    // First user connection
    _resGroup1 =  dispatch_group_create();
    dispatch_group_enter(_resGroup1);
    
    [_firstUserPubNub connectWithSuccessBlock:^(NSString *origin) {
        dispatch_group_leave(_resGroup1);
    } errorBlock:^(PNError *error) {
        XCTFail(@"First user cannot connect to PubNub, error: %@", error);
        dispatch_group_leave(_resGroup1);
        _resGroup1 = NULL;
    }];
    
    if ([GCDWrapper isGroup:_resGroup1 timeoutFiredValue:5]) {
        XCTFail(@"Timeout is fired. First user cannot connect to PubNub");
        dispatch_group_leave(_resGroup1);
        _resGroup1 = NULL;
        return;
    }
    
    // First user subscription
    _resGroup2 =  dispatch_group_create();
    dispatch_group_enter(_resGroup2);
    
    [_firstUserPubNub subscribeOn:@[_testChannel]
      withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
          
        XCTAssertNil(error, @"First user cannot subscribe on _testChannel, error: %@", error);
        
        switch (state) {
            case PNSubscriptionProcessSubscribedState:
            {
                dispatch_group_leave(_resGroup2);
                _resGroup2 = NULL;
            }
                break;
                
            default:
                break;
        }
    }];
    
    if ([GCDWrapper isGroup:_resGroup2 timeoutFiredValue:5]) {
        XCTFail(@"Timeout is fired. First user cannot subscribe on _testChannel");
        dispatch_group_leave(_resGroup2);
        _resGroup2 = NULL;
        return;
    }
    
    // Second user connection
    _resGroup3 =  dispatch_group_create();
    dispatch_group_enter(_resGroup3);
    
    [_secondUserPubNub connectWithSuccessBlock:^(NSString *origin) {
        dispatch_group_leave(_resGroup3);
    } errorBlock:^(PNError *error) {
        XCTFail(@"Second user cannot connect to PubNub, error: %@", error);
        dispatch_group_leave(_resGroup3);
        _resGroup3 = NULL;
    }];
    
    if ([GCDWrapper isGroup:_resGroup3 timeoutFiredValue:5]) {
        XCTFail(@"Timeout is fired. Second user cannot connect to PubNub");
        dispatch_group_leave(_resGroup3);
        _resGroup3 = NULL;
        return;
     }

    // Second user subscription
    _resGroup4 =  dispatch_group_create();
    dispatch_group_enter(_resGroup4);
    
    [_secondUserPubNub subscribeOn:@[_testChannel]
       withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
        
        XCTAssertNil(error, @"Second user cannot subscribe on _testChannel, error: %@", error);
        
        switch (state) {
            case PNSubscriptionProcessSubscribedState:
            {
                dispatch_group_leave(_resGroup4);
                _resGroup4 = NULL;
            }
                break;

            default:
                break;
        }
    }];

    if ([GCDWrapper isGroup:_resGroup4 timeoutFiredValue:5]) {
        XCTFail(@"Timeout is fired. Second user cannot subscribe on _testChannel");
        dispatch_group_leave(_resGroup4);
        _resGroup4 = NULL;
        return;
    }
    
    
    // First user sends messages to second user
    _resGroup5 = dispatch_group_create();
    _numberMessage = 0;
    
    for (int j=0; j< _arrayMessages.count; j++ ) {
        _testMessage = _arrayMessages[j];
        
        dispatch_group_enter(_resGroup5);
        
        PNError *processingError = nil;
        NSString *encryptedMessage = [_cryptoHelper encryptedStringFromString:_testMessage error: &processingError];
    
        [_firstUserPubNub sendMessage:encryptedMessage
                            toChannel:_testChannel
                           compressed:YES
                       storeInHistory:YES
                  withCompletionBlock:^(PNMessageState state, id message) {
                      
                      switch (state) {
                          case PNMessageSending:
                              NSLog(@"Message sending");
                              break;
                          case PNMessageSendingError:
                              XCTFail(@"Error during sending massege occured: PNMessageSendingError");
                              break;
                          case PNMessageSent: {
                              NSLog(@"Sent message %@, %@",encryptedMessage, message);
                              dispatch_group_leave(_resGroup5);
                              break;
                          }
                      }
                      
                  }];
    }

#warning Does not send second message
    
    if ([GCDWrapper isGroup:_resGroup5 timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Not all messages were sent");
        dispatch_group_leave(_resGroup5);
     }

    if (_numberMessage < _arrayMessages.count) {
        XCTFail(@"Not all messages decoded");
    }
    else {
        _resGroup5 = NULL;
    }
}


#pragma mark - PubNub Delegate

- (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)encryptedMessage withError:(PNError *)error {
    XCTFail(@"Did fail encrypted message send: %@", error);
}

- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)encryptedMessage {

    if ([client isEqual:_secondUserPubNub]) {
        
        PNError *processingError = nil;
        NSString *decodeString = [_cryptoHelper decryptedStringFromString:encryptedMessage.message
                                                             error:&processingError];
        if ([_arrayMessages containsObject:decodeString]) {
            _numberMessage = _numberMessage + 1;        }
        else {
            XCTFail(@"Such message: %@ is not contained in the test array", decodeString);
        }
    }
    
}

@end
