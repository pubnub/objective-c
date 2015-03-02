//
//  PNLeaveUsubscribeBlock.m
//  pubnub
//
//  Created by Vadim Osovets on 6/10/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

/*
 Leave operation should never block unsubscribe operation
 
 
 PubNub client use one of presence API to explicitly inform that it leaved one or set of the channels and then proceed with subscription to the rest of the channels. Sometimes presence services may not respond and user end up with report, that client were unable to unsubscribe because of error (timeout, malformed response).
 
 Idea for this adjustment is in ignoring of leave request response (success/ failure) and keep with other requests. So if user request for unsubscribed from one of the channels in set: a, b, c (let it be “b”) and “leave” API will fail (malformed response or timeout) client will continue with further action to subscribe to the rest of the channels: a and c.
 
 Presence services is less durable then pub/sub.
 
 Scenario:
 - connect to pubsub; For configuration we setup 20 sec as a presence heartbeat timeout;
 - grant all access rights;
 - subscribe to channes a, b, c with observing events
 - check that we receive two Presence events: join for all channels.
 - unsubscribe from channel b.
 - as soon as due to using long-poll request operation unsubscribe request represented by:
 leave and subscribe request. We need to stuck leave request here.
 - after that we need to confirm that other channels: a and c are not effected and subscribed again correctly.

 */

#import <XCTest/XCTest.h>
#import "GCDWrapper.h"

#import "PNMessagingChannel.h"
#import "PNConnection.h"

#import "Swizzler.h"

@interface PNMessagingChannel ()

- (void)connection:(PNConnection *)connection didReceiveResponse:(PNResponse *)response;

@end

@interface PubNub ()

// Reference on channels which is used to communicate with PubNub service
@property (nonatomic, strong) PNMessagingChannel *messagingChannel;

@end

@interface PNLeaveUsubscribeBlock : XCTestCase

@end

@implementation PNLeaveUsubscribeBlock

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testLeaveSubscribe
{
	[PubNub disconnect];

    PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo" subscribeKey:@"demo" secretKey: nil cipherKey: nil];
    configuration.presenceHeartbeatTimeout = 30;
    configuration.presenceHeartbeatInterval = 7;
    [PubNub setConfiguration:configuration];
    
    dispatch_group_t resGroup = dispatch_group_create();
    dispatch_group_enter(resGroup);
        
    [PubNub connectWithSuccessBlock:^(NSString *origin) {
        dispatch_group_leave(resGroup);
    } errorBlock:^(PNError *connectionError) {
                             dispatch_group_leave(resGroup);                             XCTFail(@"connectionError %@", connectionError);
                         }];
    
    [GCDWrapper waitGroup:resGroup];
    
	BOOL isConnect = [[PubNub sharedInstance] isConnected];
	XCTAssertTrue( isConnect, @"Does't connected");
    
    NSArray *channels = [PNChannel channelsWithNames:@[@"test_a", @"test_b", @"test_c"]];
    
    
    dispatch_group_enter(resGroup);
    
    [PubNub subscribeOn:channels
    withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
        switch (state) {
            case PNSubscriptionProcessSubscribedState:
            {
                NSLog(@"Subscribed channel: %d", (int)[channels count]);
                
                dispatch_group_leave(resGroup);
            }
                break;
                
            default:
                break;
        }
    }];
    
    [GCDWrapper waitGroup:resGroup];
    
    // Here we need to break leave request
//    __block SwizzleReceipt *receipt = [Swizzler swizzleSelector:@selector(connection: didReceiveResponse:) forInstancesOfClass:[PNMessagingChannel class]
//                                                      withBlock:^(id self, SEL sel){
//                                                          [Swizzler unswizzleFromReceipt:receipt];
//                                                      }];
//
    dispatch_group_enter(resGroup);
    
    [PubNub unsubscribeFrom:@[channels[1]]
       withCompletionHandlingBlock:^(NSArray *channels, PNError *error) {
           
           NSLog(@"Channels: %@", channels);
           dispatch_group_leave(resGroup);
       }];
    
    [GCDWrapper waitGroup:resGroup];
    
    channels = [PubNub subscribedObjectsList];
    
    XCTAssertTrue([channels count] == 2, @"Subscribed on channels: %lu", (unsigned long)[channels count]);
}

@end
