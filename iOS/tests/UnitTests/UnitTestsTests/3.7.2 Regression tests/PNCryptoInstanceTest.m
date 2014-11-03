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

    // 1. First user
    PNConfiguration *_firstUserConfiguration;
    PNCryptoHelper *_firstUserCryptoHelper;
    PubNub *_firstUserPubNub;
    
    // 2. Second user
    PNConfiguration *_secondUserConfiguration;
    PNCryptoHelper *_secondUserCryptoHelper;
    PubNub *_secondUserPubNub;
    
    // 3. Array of messages
    NSMutableArray *_arrayMessages;
    
}
@end


@implementation PNCryptoInstanceTest {
     dispatch_group_t _resGroup;
}

- (void)setUp {
    
    [super setUp];
    
    
    [_firstUserPubNub disconnect];
    [_secondUserPubNub disconnect];
    
    // Configuration
    _firstUserConfiguration = [PNConfiguration configurationForOrigin:kOriginPath
                                                           publishKey:kPublishKey
                                                         subscribeKey:kSubscribeKey
                                                            secretKey:kSecretKey
                                                            cipherKey:@"enigma"];
    // Connection 
    _firstUserPubNub = [PubNub clientWithConfiguration:_firstUserConfiguration andDelegate:self];
    
    // Configuration
    _secondUserConfiguration = [PNConfiguration configurationForOrigin:kOriginPath
                                                            publishKey:kPublishKey
                                                          subscribeKey:kSubscribeKey
                                                             secretKey:kSecretKey
                                                            cipherKey:@"enigma"];
    
    _secondUserPubNub = [PubNub clientWithConfiguration:_secondUserConfiguration andDelegate:self];
    
    
    // test data
    _arrayMessages = [[NSMutableArray alloc] init];
    
    [_arrayMessages addObject:@""];
    [_arrayMessages addObject:@"Hello World"];
    [_arrayMessages addObject:[NSString stringWithFormat:@"%@", [NSDate date]]];
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
    
    [_firstUserPubNub connect];
    
    _resGroup =  dispatch_group_create();
    
    dispatch_group_enter(_resGroup);
    
    [_secondUserPubNub connectWithSuccessBlock:^(NSString *origin) {
        dispatch_group_leave(_resGroup);
    } errorBlock:^(PNError *error) {
        XCTFail(@"Cannot connect to PubNub the second instance");
        
        dispatch_group_leave(_resGroup);
        _resGroup = NULL;
        return;
    }];
    
    if ([GCDWrapper isGroup:_resGroup timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Cannot connect to PubNub the second instance.");
        dispatch_group_leave(_resGroup);
        _resGroup = NULL;
        
        return;
    }
    
    _resGroup =  dispatch_group_create();
    
    // Subscribing
    PNChannel *testChannel = [PNChannel channelWithName:@"iosdev"];
    
    dispatch_group_enter(_resGroup);
    
    [_firstUserPubNub subscribeOn:@[testChannel] withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
        
        switch (state) {
            case PNSubscriptionProcessSubscribedState:
            {
                dispatch_group_leave(_resGroup);
            }
                break;
                
            default:
                break;
        }
    }];
    
    if ([GCDWrapper isGroup:_resGroup timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Cannot subscribe with first instance of PubNub.");
        dispatch_group_leave(_resGroup);
        _resGroup = NULL;
        
        return;
    }
    
    dispatch_group_enter(_resGroup);
    
    [_secondUserPubNub subscribeOn:@[[PNChannel channelWithName:@"iosdev"]]];
    
    if ([GCDWrapper isGroup:_resGroup timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Cannot subscribe to second instance of PubNub.");
        dispatch_group_leave(_resGroup);
        _resGroup = NULL;
        
        return;
    }
    
    _resGroup =  dispatch_group_create();
    
    dispatch_group_enter(_resGroup);
    dispatch_group_enter(_resGroup);
    
    // Send message
    NSString *encryptedMessage = @"Hello World";
    
    [_firstUserPubNub sendMessage:encryptedMessage
                        toChannel:testChannel
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
                          NSLog(@"Sending message %@, %@",encryptedMessage, message);
                          dispatch_group_leave(_resGroup);
                          break;
                      }
                  }
                  
              }];
    
    if ([GCDWrapper isGroup:_resGroup timeoutFiredValue:10]) {
       XCTFail(@"Cannot send/receive message.");
        
        NSLog(@"Subscribed channels: %@", [_secondUserPubNub subscribedObjectsList]);
    }
}


#pragma mark - PubNub Delegate

- (void)pubnubClient:(PubNub *)client didSubscribeOn:(NSArray *)channelObjects {
    if ([client isEqual:_secondUserPubNub]) {
        if (_resGroup != NULL) {
            dispatch_group_leave(_resGroup);
        }
    }
}

- (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
    XCTFail(@"Did fail subscription on channel: %@", error);
}

- (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)_encryptedMessage withError:(PNError *)error {
    XCTFail(@"Did fail encrypted message send: %@", error);
}

- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)encryptedMessage {
    
    if ([client isEqual:_secondUserPubNub]) {
        if (_resGroup != NULL) {
            dispatch_group_leave(_resGroup);
        }
    }
}

@end
