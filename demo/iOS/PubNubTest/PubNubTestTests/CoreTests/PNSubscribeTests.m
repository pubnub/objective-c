//
//  PNSubscribeTests.m
//  PubNubTest
//
//  Created by Sergey Kazanskiy on 5/18/15.
//  Copyright (c) 2015 PubNub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "PubNub.h"

#import "GCDGroup.h"
#import "GCDWrapper.h"

#import "TestConfigurator.h"

@interface PNSubscribeTests : XCTestCase <PNObjectEventListener>

@end

@implementation PNSubscribeTests {
    
    PubNub *_pubNub;
    PubNub *_pubNub2;
    BOOL _clientListening;
    
    XCTestExpectation *_receiveStatusExpectation;
    XCTestExpectation *_receiveMessageExpectation;
}

- (void)setUp {
    [super setUp];
    
    _pubNub = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
    _pubNub.uuid = @"testUUID";
    
    _pubNub2 = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
    _pubNub2.uuid = @"testUUID2";
}

- (void)tearDown {
    
    _pubNub = nil;
    _pubNub2 = nil;
    [super tearDown];
}

- (void)testReturnSubscribedChannels {
    
    XCTestExpectation *_subscribeExpectation = [self expectationWithDescription:@"Subscribing"];
    
    [_pubNub subscribeToChannels:@[@"testChannel1", @"testChannel2"] withPresence:YES
                     clientState:nil andCompletion:^(PNStatus *status) {
                         
                         if (status.error) {
                             
                             XCTFail(@"Error");
                         }
                         [_subscribeExpectation fulfill];
                     }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
    }];
    
    NSArray *channels = [_pubNub channels];
    NSLog(@"!!!%@", channels);
}

- (void)testReturnSubscribedGroups {
    
    XCTestExpectation *_subscribeExpectation = [self expectationWithDescription:@"Subscribing"];
    
    [_pubNub subscribeToChannelGroups:@[@"testGroup1", @"testGroup2"] withPresence:YES clientState:nil andCompletion:^(PNStatus *status) {
        
                         if (status.error) {
                             
                             XCTFail(@"Error");
                         }
                         [_subscribeExpectation fulfill];
                     }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
    }];
    
    NSArray *groups = [_pubNub channelGroups];
    NSLog(@"!!!%@", groups);
}

- (void)testReturnChannelsWithEventPresence {
    
    XCTestExpectation *_subscribeExpectation = [self expectationWithDescription:@"Subscribing"];
    
    [_pubNub subscribeToChannels:@[@"testChannel1", @"testChannel2"] withPresence:YES
                     clientState:nil andCompletion:^(PNStatus *status) {
                         
                         if (status.error) {
                             
                             XCTFail(@"Error");
                         }
                         [_subscribeExpectation fulfill];
                     }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
    }];
    
    NSArray *channels = [_pubNub presenceChannels];
    NSLog(@"!!!%@", channels);
}

- (void)testCheckIsSubscribeOn {
    
    XCTestExpectation *_subscribeExpectation = [self expectationWithDescription:@"Subscribing"];
    
    [_pubNub subscribeToChannels:@[@"testChannel1", @"testChannel2"] withPresence:YES
                     clientState:nil andCompletion:^(PNStatus *status) {
                         
                         if (status.error) {
                             
                             XCTFail(@"Error");
                         }
                         [_subscribeExpectation fulfill];
                     }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
    }];
    
    BOOL isSubscribe = [_pubNub isSubscribedOn:@"testChannel1"];
    NSLog(@"!!!%d", isSubscribe);
}

- (void)testSubscribeUnsubscribeFromChannels {
    
    XCTestExpectation *_subscribeExpectation = [self expectationWithDescription:@"Subscribing"];
    
    [_pubNub subscribeToChannels:@[@"testChannel1", @"testChannel2"] withPresence:YES
                     clientState:nil andCompletion:^(PNStatus *status) {
                         
                         if (status.error) {
                             
                             XCTFail(@"Error");
                         }
                         [_subscribeExpectation fulfill];
                     }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
    }];
    
    XCTestExpectation *_unsubscribeExpectation = [self expectationWithDescription:@"Unsubscribing"];
    
    [_pubNub unsubscribeFromChannels:@[@"testChannel1", @"testChannel2"] withPresence:YES andCompletion:^(PNStatus *status) {
        
                         if (status.error) {
                             
                             XCTFail(@"Error");
                         }
                         [_unsubscribeExpectation fulfill];
                         
                     }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
    }];
 }

- (void)testSubscribeUnsubscribeFromGroups {
    
    XCTestExpectation *_subscribeExpectation = [self expectationWithDescription:@"Subscribing"];
    
    [_pubNub subscribeToChannelGroups:@[@"testGroup1", @"testGroup2"] withPresence:YES clientState:nil andCompletion:^(PNStatus *status) {
        
        if (status.error) {
            
            XCTFail(@"Error");
        }
        [_subscribeExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
    }];
    
    XCTestExpectation *_unsubscribeExpectation = [self expectationWithDescription:@"Unsubscribing"];
    
    [_pubNub unsubscribeFromChannelGroups:@[@"testGroup1", @"testGroup2"] withPresence:YES andCompletion:^(PNStatus *status) {

        if (status.error) {
            
            XCTFail(@"Error");
        }
        [_unsubscribeExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
    }];
}

- (void)testSubscribeUnsubscribeFromPresenceChannels {
    
     XCTestExpectation *_subscribeExpectation = [self expectationWithDescription:@"Subscribing"];
    
    [_pubNub subscribeToPresenceChannels:@[@"testChannel1", @"testChannel2"] withCompletion:^(PNStatus *status) {
        if (status.error) {
            
            XCTFail(@"Error");
        }
        [_subscribeExpectation fulfill];
    }];
     
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
    }];
    
    XCTestExpectation *_unsubscribeExpectation = [self expectationWithDescription:@"Unsubscribing"];
    
    [_pubNub unsubscribeFromPresenceChannels:@[@"testChannel1", @"testChannel2"] andCompletion:^(PNStatus *status) {
        
        if (status.error) {
            
            XCTFail(@"Error");
        }
        [_unsubscribeExpectation fulfill];
        
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
    }];
    
}

- (void)testAddRemoveListeners {
    
    //      Add listeners
    [_pubNub addListeners:@[self]];
    _clientListening = YES;
    
    XCTestExpectation *_subscribeExpectation = [self expectationWithDescription:@"Subscribing"];
    _receiveStatusExpectation = [self expectationWithDescription:@"Delegate:'ReceiveStatus'"];
    
    XCTestExpectation *_publishExpectation = [self expectationWithDescription:@"Send message"];
    _receiveMessageExpectation = [self expectationWithDescription:@"Delegate:'ReceiveMessage'"];
    
    // Delegate:"ReceiveStatus" have to invoked
    [_pubNub subscribeToChannels:@[@"testChannel1", @"testChannel2"] withPresence:YES clientState:nil andCompletion:^(PNStatus *status) {
                         
                         if (status.error) {
                             
                             XCTFail(@"Error");
                         }
                         [_subscribeExpectation fulfill];
                     }];
    
    // Delegate:"ReceivePresenceEvent" have to invoked
//    [_pubNub2 subscribeToChannels:@[@"testChannel1"] withPresence:YES clientState:nil andCompletion:^(PNStatus *status) {
//        
//        if (status.error) {
//            
//            XCTFail(@"Error");
//        }
//        [_resGroup leave];
//        
//    }];
    
    // Delegate:"ReceiveMessage" have to invoked
    [_pubNub publish:@"Hello world" toChannel:@"testChannel1" storeInHistory:YES withCompletion:^(PNStatus *status) {
     
        if (status.error) {
            
            XCTFail(@"Error");
        }
        [_publishExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
    }];
    

    //      Remove listeners
    [_pubNub removeListeners:@[self]];
    _clientListening = NO;
    
    
    XCTestExpectation *_unsubscribeExpectation = [self expectationWithDescription:@"Unsubscribing"];
    
    // Delegate:"ReceiveStatus" have not be invoked
    [_pubNub unsubscribeFromChannels:@[@"testChannel1", @"testChannel2"] withPresence:YES andCompletion:^(PNStatus *status) {
        
        if (status.error) {
            
            XCTFail(@"Error");
        }
        [_unsubscribeExpectation fulfill];
    }];
    
    
    // Delegate:"ReceivePresenceEvent" have not be invoked
//    [_pubNub2 unsubscribeFromChannels:@[@"testChannel1", @"testChannel2"] withPresence:YES andCompletion:^(PNStatus *status) {
//        
//        if (status.error) {
//            
//            XCTFail(@"Error");
//        }
//        [_resGroup leave];
//        
//    }];

    _publishExpectation = [self expectationWithDescription:@"Send message"];
    
    // Delegate:"ReceiveMessage" have not be invoked
    [_pubNub publish:@"Hello world" toChannel:@"testChannel1" storeInHistory:YES withCompletion:^(PNStatus *status) {
        
        if (status.error) {
            
            XCTFail(@"Error");
        }
        [_publishExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
    }];
}


#pragma mark - Delegate methods


- (void)client:(PubNub *)client didReceiveStatus:(PNStatus *)status {
    
    if (_receiveStatusExpectation && _clientListening) {
        
        [_receiveStatusExpectation fulfill];
    } else if (_receiveStatusExpectation && !_clientListening) {
        
        XCTFail(@"Error");
    }
}

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNResult *)event {
    
//    if (_resGroup && _clientListening) {
//        
//        [_resGroup leave];
//    } else if ((_resGroup && !_clientListening) ) {
//        
//        XCTFail(@"Error");
//    }
}

- (void)client:(PubNub *)client didReceiveMessage:(PNResult *)message {
    
    if (_receiveMessageExpectation && _clientListening) {
        
        [_receiveMessageExpectation fulfill];
    } else if ((_receiveMessageExpectation && !_clientListening) ) {
        
        XCTFail(@"Error");
    }
}

@end
