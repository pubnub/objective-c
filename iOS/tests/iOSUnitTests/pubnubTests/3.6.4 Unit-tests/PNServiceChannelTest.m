//
//  PNServiceChannelTest.m
//  UnitTestSample
//
//  Created by Vadim Osovets on 5/5/13.
//  Copyright (c) 2013 Micro-B. All rights reserved.
//

#import "PNServiceChannelTest.h"
#import "PNServiceChannel.h"

#import "PNMessage.h"
#import "PNChannel.h"
#import "PNMessagePostRequest.h"

#import "NSData+PNAdditions.h"

#import <OCMock/OCMock.h>

@interface PNServiceChannelTest ()

<PNDelegate,
PNConnectionChannelDelegate>

@end

@implementation PNServiceChannelTest {
    PNConfiguration *_configuration;
}

- (void)setUp
{
    [super setUp];
    
    _configuration = [PNConfiguration defaultConfiguration];
}

- (void)tearDown
{
    // Tear-down code here.
    [super tearDown];
}

#pragma mark - States tests

- (void)testServiceChannelWithDelegate {
    /*
     Test scenario:
      - initService with some delegate object
      - check service is ready to work
     */
    
    PNServiceChannel *channel = [PNServiceChannel serviceChannelWithConfiguration:_configuration andDelegate:self];
    
    STAssertNotNil(channel, @"Channel is not available");
}

- (void)testInitWithTypeAndDelegate {
    /*
     Test scenario:
     - initService with type: service and some delegate object
     - check service is ready to work
     
     - initService with type: messaging and some delegate object
     - check service is ready to work
     */
    
    PNServiceChannel *channel = [[PNServiceChannel alloc] initWithConfiguration:_configuration type:PNConnectionChannelService andDelegate:self];
    
    STAssertNotNil(channel, @"Channel is not available");
    
    
    channel = [[PNServiceChannel alloc] initWithConfiguration:_configuration type:PNConnectionChannelMessaging andDelegate:self];
    STAssertNotNil(channel, @"Channel is not available");
}

#pragma mark - Interaction tests

- (void)testSendMessage {
    /*
     Test scenario:
     - initService with some delegate object
     - send a message
     - expect scheduleRequest method of channel ivoked
    */
    
    PNServiceChannel *channel = [PNServiceChannel serviceChannelWithConfiguration:_configuration andDelegate:self];
    
    id mock = [OCMockObject partialMockForObject:channel];
    
    [[[[mock expect] ignoringNonObjectArgs] andReturn:nil] sendMessage: [OCMArg any] toChannel:[OCMArg any] compressed:NO storeInHistory:NO];

    [mock sendMessage:[PNMessage new]];
    
    [mock verify];
}

- (void)testSendMessageToChannel {
    /*
     Test scenario:
     - initService with some delegate object
     - send a message to specific channel
     - expect scheduleRequest method of channel ivoked
     */
    PNServiceChannel *channel = [PNServiceChannel serviceChannelWithConfiguration:_configuration andDelegate:self];
    
    id mockChannel = [OCMockObject partialMockForObject:channel];
    
    [[[mockChannel expect] ignoringNonObjectArgs] sendMessage:[OCMArg any] toChannel:[OCMArg any]
                                                   compressed:NO storeInHistory:NO];
    
    [mockChannel sendMessage:[PNMessage new]
                   toChannel:mockChannel
                  compressed:NO
     storeInHistory:NO];
    [mockChannel verify];
}

@end
