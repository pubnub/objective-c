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

@interface PNSubscribeTests : XCTestCase <PNObjectEventListener>

@end

@implementation PNSubscribeTests {
    
    PubNub *_pubNub;
    PubNub *_pubNub2;
    GCDGroup *_resGroup;
    BOOL _clientListening;
    
}

- (void)setUp {
    [super setUp];
    
    _pubNub = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
    _pubNub.uuid = @"testUUID";
    _pubNub.callbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    _pubNub2 = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
    _pubNub2.uuid = @"testUUID2";
    _pubNub2.callbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}

- (void)tearDown {
    
    _pubNub = nil;
    _pubNub2 = nil;
    [super tearDown];
}

- (void)testReturnSubscribedChannels {
    
    _resGroup = [GCDGroup group];
    [_resGroup enter];
    
    [_pubNub subscribeToChannels:@[@"testChannel1", @"testChannel2"] withPresence:YES
                     clientState:nil andCompletion:^(PNStatus *status) {
                         
                         if (status.error) {
                             
                             XCTFail(@"Error");
                         }
                         [_resGroup leave];
                     }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:30]) {
        
        XCTFail(@"Timeout fired during subscribing");
    }
    
    NSArray *channels = [_pubNub channels];
    NSLog(@"!!!%@", channels);
}

- (void)testReturnSubscribedGroups {
    
    _resGroup = [GCDGroup group];
    [_resGroup enter];
    
    [_pubNub subscribeToChannelGroups:@[@"testGroup1", @"testGroup2"] withPresence:YES clientState:nil andCompletion:^(PNStatus *status) {
        
                         if (status.error) {
                             
                             XCTFail(@"Error");
                         }
                         [_resGroup leave];
                     }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:30]) {
        
        XCTFail(@"Timeout fired during subscribing");
    }
    
    NSArray *groups = [_pubNub channelGroups];
    NSLog(@"!!!%@", groups);
}

- (void)testReturnChannelsWithEventPresence {
    
    _resGroup = [GCDGroup group];
    [_resGroup enter];
    
    [_pubNub subscribeToChannels:@[@"testChannel1", @"testChannel2"] withPresence:YES
                     clientState:nil andCompletion:^(PNStatus *status) {
                         
                         if (status.error) {
                             
                             XCTFail(@"Error");
                         }
                         [_resGroup leave];
                     }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:30]) {
        
        XCTFail(@"Timeout fired during subscribing");
    }
    
    NSArray *channels = [_pubNub presenceChannels];
    NSLog(@"!!!%@", channels);
}

- (void)testCheckIsSubscribeOn {
    
    _resGroup = [GCDGroup group];
    [_resGroup enter];
    
    [_pubNub subscribeToChannels:@[@"testChannel1", @"testChannel2"] withPresence:YES
                     clientState:nil andCompletion:^(PNStatus *status) {
                         
                         if (status.error) {
                             
                             XCTFail(@"Error");
                         }
                         [_resGroup leave];
                     }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:30]) {
        
        XCTFail(@"Timeout fired during subscribing");
    }
    
    BOOL isSubscribe = [_pubNub isSubscribedOn:@"testChannel1"];
    NSLog(@"!!!%d", isSubscribe);
}

- (void)testSubscribeUnsubscribeFromChannels {
    
    _resGroup = [GCDGroup group];
    [_resGroup enter];
    
    [_pubNub subscribeToChannels:@[@"testChannel1", @"testChannel2"] withPresence:YES
                     clientState:nil andCompletion:^(PNStatus *status) {
                         
                         if (status.error) {
                             
                             XCTFail(@"Error");
                         }
                         [_resGroup leave];
                         
                     }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:30]) {
        
        XCTFail(@"Timeout fired during subscribing");
    }
    
    [_resGroup enter];
    
    [_pubNub unsubscribeFromChannels:@[@"testChannel1", @"testChannel2"] withPresence:YES andCompletion:^(PNStatus *status) {
        
                         if (status.error) {
                             
                             XCTFail(@"Error");
                         }
                         [_resGroup leave];
                         
                     }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:30]) {
        
        XCTFail(@"Timeout fired during unsubscribing");
    }
 }

- (void)testSubscribeUnsubscribeFromGroups {
    
    _resGroup = [GCDGroup group];
    [_resGroup enter];
    
    [_pubNub subscribeToChannelGroups:@[@"testGroup1", @"testGroup2"] withPresence:YES clientState:nil andCompletion:^(PNStatus *status) {
        
        if (status.error) {
            
            XCTFail(@"Error");
        }
        [_resGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:30]) {
        
        XCTFail(@"Timeout fired during subscribing");
    }
    
    [_resGroup enter];
    
    [_pubNub unsubscribeFromChannelGroups:@[@"testGroup1", @"testGroup2"] withPresence:YES andCompletion:^(PNStatus *status) {

        if (status.error) {
            
            XCTFail(@"Error");
        }
        [_resGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:30]) {
        
        XCTFail(@"Timeout fired during unsubscribing");
    }
    
}

- (void)testSubscribeUnsubscribeFromPresenceChannels {
    
    _resGroup = [GCDGroup group];
    [_resGroup enter];
    
    [_pubNub subscribeToPresenceChannels:@[@"testChannel1", @"testChannel2"] withCompletion:^(PNStatus *status) {
        if (status.error) {
            
            XCTFail(@"Error");
        }
        [_resGroup leave];
    }];
     
     if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:30]) {
        
        XCTFail(@"Timeout fired during subscribing");
    }
    
    [_resGroup enter];
    
    [_pubNub unsubscribeFromPresenceChannels:@[@"testChannel1", @"testChannel2"] andCompletion:^(PNStatus *status) {
        
        if (status.error) {
            
            XCTFail(@"Error");
        }
        [_resGroup leave];
        
    }];
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:30]) {
        
        XCTFail(@"Timeout fired during unsubscribing");
    }
    
}

- (void)testAddRemoveListeners {
    
    //      Add listeners
    [_pubNub addListeners:@[self]];
    _clientListening = YES;
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:4];
    
    // Delegate:"ReceiveStatus" have to invoked
    [_pubNub subscribeToChannels:@[@"testChannel1", @"testChannel2"] withPresence:YES clientState:nil andCompletion:^(PNStatus *status) {
                         
                         if (status.error) {
                             
                             XCTFail(@"Error");
                         }
                         [_resGroup leave];
                         
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
          
        [_resGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:30]) {
        
        XCTFail(@"Timeout fired during subscribing");
    }
    

    //      Remove listeners
    [_pubNub removeListeners:@[self]];
    _clientListening = NO;
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:2];
    
    // Delegate:"ReceiveStatus" have not be invoked
    [_pubNub unsubscribeFromChannels:@[@"testChannel1", @"testChannel2"] withPresence:YES andCompletion:^(PNStatus *status) {
        
        if (status.error) {
            
            XCTFail(@"Error");
        }
        [_resGroup leave];
        
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

    
    // Delegate:"ReceiveMessage" have not be invoked
    [_pubNub publish:@"Hello world" toChannel:@"testChannel1" storeInHistory:YES withCompletion:^(PNStatus *status) {
        
        if (status.error) {
            
            XCTFail(@"Error");
        }
        
        [_resGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:30]) {
        
        XCTFail(@"Timeout fired during subscribing");
    }
}


#pragma mark - Delegate methods


- (void)client:(PubNub *)client didReceiveStatus:(PNStatus *)status {
    
    if (_resGroup && _clientListening) {
        
        [_resGroup leave];
    } else if ((_resGroup && !_clientListening) ) {
        
        XCTFail(@"Error");
    }
}

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNResult *)event {
    
    if (_resGroup && _clientListening) {
        
        [_resGroup leave];
    } else if ((_resGroup && !_clientListening) ) {
        
        XCTFail(@"Error");
    }
}

- (void)client:(PubNub *)client didReceiveMessage:(PNResult *)message {
    
    if (_resGroup && _clientListening) {
        
        [_resGroup leave];
    } else if ((_resGroup && !_clientListening) ) {
        
        XCTFail(@"Error");
    }
}

@end
