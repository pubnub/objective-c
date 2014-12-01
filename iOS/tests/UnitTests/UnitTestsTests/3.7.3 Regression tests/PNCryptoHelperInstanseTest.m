//
//  PNCryptoHelperInstanseTest.m
//  UnitTests
//
//  Created by Sergey Kazanskiy on 11/27/14.
//  Copyright (c) 2014 PubNub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "PNCryptoHelper.h"

@interface PNCryptoHelperInstanseTest : XCTestCase <PNDelegate> {
    dispatch_group_t _resGroup;
    
    PNConfiguration *_clientConfiguration;
    PNCryptoHelper *_cryptoHelper;
    PNChannel *_testChannel;
    PubNub *_pubNubClient1;
    PubNub *_pubNubClient2;
    NSString *_decodeString;
    
    id _message;
}

@end

@implementation PNCryptoHelperInstanseTest

- (void)setUp {
    [super setUp];
    [PubNub disconnect];
    _decodeString = nil;
    
    _clientConfiguration = [PNConfiguration configurationForOrigin:kTestPNOriginHost
                                                        publishKey:kTestPNPublishKey
                                                      subscribeKey:kTestPNSubscriptionKey
                                                         secretKey:nil
                                                         cipherKey:@"enigma"];
    _testChannel = [PNChannel channelWithName:@"iosdev"];
}

- (void)tearDown {
    _clientConfiguration = nil;
    _pubNubClient1= nil;
    _pubNubClient2= nil;
    _decodeString=nil;
    [PubNub disconnect];
    [super tearDown];
}

- (id)connectClientToPubNub:(PubNub *)client clientConfiguration:(PNConfiguration *)configuration {
    
    _resGroup = dispatch_group_create();
    dispatch_group_enter(_resGroup);
    dispatch_group_enter(_resGroup);
    
    client = [PubNub connectingClientWithConfiguration:configuration delegate:self andSuccessBlock:^(NSString *res) {
        dispatch_group_leave(_resGroup);
    } errorBlock:^(PNError *error) {
        XCTFail(@"Error occurs during connection: %@", error);
    }];
    
    if ([GCDWrapper isGroup:_resGroup timeoutFiredValue:5]) {
        dispatch_group_leave(_resGroup);
        _resGroup= NULL;
        XCTFail(@"Timeout is fired. PubNub client does't connected");
        return nil;
    } else {
        _resGroup= NULL;
        return client;
    }
}

- (BOOL)subscribeClientOnChannels:(PubNub *)client toChannel:(NSArray *)сhannel {

    _resGroup = dispatch_group_create();
    dispatch_group_enter(_resGroup);
    
    [client subscribeOn:сhannel withClientState:nil andCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
        XCTAssertNil(error,@"Error when subscribing on channels");
        switch (state) {
            case PNSubscriptionProcessSubscribedState: {
                dispatch_group_leave(_resGroup);
                _resGroup = NULL;
            }
                break;
            default:
                break;
        }
    }];

    if ([GCDWrapper isGroup:_resGroup timeoutFiredValue:5]) {
        dispatch_group_leave(_resGroup);
        _resGroup = NULL;
        XCTFail(@"Timeout is fired. Didn't subscribe on channels");
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)sendClientEncryptingMessage:(PubNub *)client
                  encryptingMessage:(NSString *)message {
    
    _resGroup = dispatch_group_create();
    dispatch_group_enter(_resGroup);
    dispatch_group_enter(_resGroup);
    
    PNError *processingError = nil;
    NSString *encryptedMessage = [_cryptoHelper encryptedStringFromString:message error:&processingError];
    
//    [client setDelegate:self];
    [client sendMessage:encryptedMessage
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
                          dispatch_group_leave(_resGroup);
                          break;
                      }
                  }
                  
              }];
    
    if ([GCDWrapper isGroup:_resGroup timeoutFiredValue:15]) {
        dispatch_group_leave(_resGroup);
        _resGroup = NULL;
        XCTFail(@"Timeout is fired. Not all messages were sent");
        return NO;
    }  else {
        _resGroup = NULL;
        return YES;
    }
}


#pragma mark - PubNub Delegate

- (void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin {
    if (_resGroup) {
        dispatch_group_leave(_resGroup);
    }
}


- (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)encryptedMessage withError:(PNError *)error {
    XCTFail(@"Did fail encrypted message send: %@", error);
}

- (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)encryptedMessage {
    dispatch_group_leave(_resGroup);
}

- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)encryptedMessage {
 
    if ([client isEqual:_pubNubClient2]) {
        PNError *processingError = nil;
        _decodeString = [_cryptoHelper decryptedStringFromString:encryptedMessage.message
                                                                    error:&processingError];
        
        if (processingError) {
            XCTFail(@"Failed to decrypt message \"%@\" with error: %@", _message, [processingError localizedDescription]);
        }
        
    }

}


#pragma mark - Scenario

- (void)testScenario {
    
    PNError *helperInitializationError = nil;
    _cryptoHelper = [PNCryptoHelper helperWithConfiguration:_clientConfiguration
                                                      error:&helperInitializationError];
    if (helperInitializationError || !_cryptoHelper) {
        XCTFail(@"%@ setup error: %@", self.name, helperInitializationError);
        return;
    }
 
    // Client1 connects and subscribes on channel @[_testChannel]
    _pubNubClient1 = [self connectClientToPubNub:_pubNubClient1 clientConfiguration:_clientConfiguration];
    XCTAssertTrue(([_pubNubClient1 isConnected]));
    XCTAssertTrue(([self subscribeClientOnChannels:_pubNubClient1 toChannel:@[_testChannel]]));
    
    // Client2 connects and subscribes on channel
    _pubNubClient2 = [self connectClientToPubNub:_pubNubClient2 clientConfiguration:_clientConfiguration];
    XCTAssertTrue(([_pubNubClient1 isConnected]));
    XCTAssertTrue(([self subscribeClientOnChannels:_pubNubClient2 toChannel:@[_testChannel]]));
    
// Message1
    // Client1 sends encrypting message to channel, Client2 receive and decodes message, then we comparison with the original
    XCTAssertTrue(([self sendClientEncryptingMessage:_pubNubClient1 encryptingMessage:@"Hello world"]));
    XCTAssertEqualObjects(_decodeString, @"Hello world", @"wrong decoding %@", _decodeString);

// Message2
    // Client1 sends encrypting message to channel, Client2 receive and decodes message, then we comparison with the original
    XCTAssertTrue(([self sendClientEncryptingMessage:_pubNubClient1 encryptingMessage:@"123456687"]));
    XCTAssertEqualObjects(_decodeString, @"123456687", @"wrong decoding %@", _decodeString);
    
// Message3
    // Client1 sends encrypting message to channel, Client2 receive and decodes message, then we comparison with the original
    XCTAssertTrue(([self sendClientEncryptingMessage:_pubNubClient1 encryptingMessage:@" "]));
    XCTAssertEqualObjects(_decodeString, @" ", @"wrong decoding %@", _decodeString);
    
// Message4
    NSString *tMessage = [NSString stringWithFormat:@"%@", [NSDate date]];
    // Client1 sends encrypting message to channel, Client2 receive and decodes message, then we comparison with the original
    XCTAssertTrue(([self sendClientEncryptingMessage:_pubNubClient1 encryptingMessage:tMessage]));
    XCTAssertEqualObjects(_decodeString, tMessage, @"wrong decoding %@", _decodeString);
    
// Message5 !!! @"" -  does not work
    // Client1 sends encrypting message to channel, Client2 receive and decodes message, then we comparison with the original
    XCTAssertTrue(([self sendClientEncryptingMessage:_pubNubClient1 encryptingMessage:@""]));
    XCTAssertEqualObjects(_decodeString, @"", @"wrong decoding %@", _decodeString);


}

@end

