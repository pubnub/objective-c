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
    NSLog(@"Start %@ test", self.name);
    [_firstUserPubNub disconnect];
    [_secondUserPubNub disconnect];
    
    
// 1. First user
    
    // Configuration
    _firstUserConfiguration = [PNConfiguration configurationForOrigin:kOriginPath
                                                           publishKey:kPublishKey
                                                         subscribeKey:kSubscribeKey
                                                            secretKey:kSecretKey
                                                            cipherKey:@"enigma"];
    
    // CryptoHelper
//    PNError *helperInitializationError = nil;
//    _firstUserCryptoHelper = [PNCryptoHelper helperWithConfiguration:_firstUserConfiguration error:&helperInitializationError];
//    if (helperInitializationError) {
//        NSLog(@"%@ setup first user error: %@", self.name, helperInitializationError);
//    }
    
    // Connection 
    _firstUserPubNub = [PubNub clientWithConfiguration:_firstUserConfiguration andDelegate:self];
        
// 2. Second user
    
    // Configuration
    _secondUserConfiguration = [PNConfiguration configurationForOrigin:kOriginPath
                                                            publishKey:kPublishKey
                                                          subscribeKey:kSubscribeKey
                                                             secretKey:kSecretKey
                                                            cipherKey:@"enigma"];
    
    // 2.2 CryptoHelper
//    helperInitializationError = nil;
//    _secondUserCryptoHelper = [PNCryptoHelper helperWithConfiguration:_secondUserConfiguration error:&helperInitializationError];
//    if (helperInitializationError) {
//        NSLog(@"%@ setup second user error: %@", self.name, helperInitializationError);
//    }
    
    // 2.3 Connection
    _secondUserPubNub = [PubNub clientWithConfiguration:_firstUserConfiguration andDelegate:self];
    
// 3. Array of messages
    _arrayMessages = [[NSMutableArray alloc] init];
    
    [_arrayMessages addObject:@""];
    [_arrayMessages addObject:@"Hello World"];
//    [_arrayMessages addObject:@[@"seven", @"eight", @{@"food": @"Cheeseburger", @"drink": @"Coffee"}]];
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


// Sending crypto messages
//- (void)tes1CryptoInstance {
//    
//    // Subscribing
//    PNChannel *_testChannel = [PNChannel channelWithName:@"iosdev"];
//    [_firstUserPubNub subscribeOn:@[_testChannel]];
//    [_secondUserPubNub subscribeOn:@[_testChannel]];
//    _resGroup =  dispatch_group_create();
//    
//    // Cycle messages
//    for( int i=0; i<_arrayMessages.count; i++ ) {
//        
//        // Encrypting message
//        PNError *processingError = nil;
//        NSString *_encryptedMessage = [_firstUserCryptoHelper encryptedStringFromString:_arrayMessages[i] error:&processingError];
//        XCTAssertNil( processingError, @"Error during encryption process %@", processingError);
//        processingError = nil;
//        
//       // Sending message
//        dispatch_group_enter(_resGroup);
//        dispatch_group_enter(_resGroup);
//        
//        [_firstUserPubNub sendMessage:_encryptedMessage
//                   toChannel:_testChannel
//                  compressed:YES
//              storeInHistory:YES
//         withCompletionBlock:^(PNMessageState state, id message) {
//             
//             switch (state) {
//                 case PNMessageSending:
//                     NSLog(@"Message sending");
//                 case PNMessageSendingError:
//                     XCTFail(@"Error during sending massege occured: PNMessageSendingError");
//                     dispatch_group_leave(_resGroup);
//                     break;
//                 case PNMessageSent:
//                     NSLog(@"Sending message %@, %@",_arrayMessages[i], message);
//                     _numberMassege = i;
//                     dispatch_group_leave(_resGroup);
//                     break;
//             }
//
//         }];
//        
//        if ([GCDWrapper isGroup:_resGroup timeoutFiredValue:10]) {
//            XCTFail(@"Cannot send message.");
//        }
//
//        
//    }
//}

- (void)testCryptoInstance {
    
    [_firstUserPubNub connect];
    [_secondUserPubNub connect];
    
    _resGroup =  dispatch_group_create();
    
    // Subscribing
    PNChannel *testChannel = [PNChannel channelWithName:@"iosdev"];
    
    [_firstUserPubNub subscribeOn:@[testChannel]];
    [_secondUserPubNub subscribeOn:@[[PNChannel channelWithName:@"iosdev"]]];
    
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
    
    if ([GCDWrapper isGroup:_resGroup timeoutFiredValue:5]) {
       XCTFail(@"Cannot send/receive message.");
        
        NSLog(@"Subscribed channels: %@", [_secondUserPubNub subscribedObjectsList]);
    }
}


#pragma mark - PubNub Delegate

- (void)pubnubClient:(PubNub *)client didSubscribeOn:(NSArray *)channelObjects {
    NSLog(@"Client subscribed on channel");
}

- (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
    XCTFail(@"Did fail subscription on channel: %@", error);
}


- (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)_encryptedMessage withError:(PNError *)error {
    XCTFail(@"Did fail encrypted message send: %@", error);
}

- (void)pubnubClient:(PubNub *)client didReceivedMessage:(PNMessage *)encryptedMessage {
   
    
    dispatch_group_leave(_resGroup);
    return;
    
    // Decoding message
//    PNError *processingError = nil;
//    NSString *_decodedMessage = [_secondUserCryptoHelper decryptedStringFromString:_arrayMessages[_numberMassege] error:&processingError];
//    XCTAssertNil(processingError, @"Error during decoding process %@", processingError);
//    
//   
//    processingError = nil;
//    
//    // Testing for equality sended and geted messages
//    XCTAssertEqualObjects(_decodedMessage, encryptedMessage, @"Encrypted and decoded messages are not equal: %@", encryptedMessage);
//    NSLog(@"Message %ld, %@", _numberMassege, encryptedMessage);
//    
}

@end
