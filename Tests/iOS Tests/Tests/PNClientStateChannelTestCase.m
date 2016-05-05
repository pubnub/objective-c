//
//  PNClientStateChannelTestCase.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 4/21/16.
//
//

#import "PNSubscribeLoopTestCase.h"
#import "XCTestCase+PNClientState.h"

@interface PNClientStateChannelTestCase : PNSubscribeLoopTestCase

@end

@implementation PNClientStateChannelTestCase

- (BOOL)isRecording {
    return NO;
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (NSArray<NSString *> *)subscribedChannels {
    return @[@"a"];
}

- (BOOL)shouldSubscribeWithPresence {
    return YES;
}

- (void)testSetClientStateOnSubscribedChannel {
    NSDictionary *state = @{
                            @"test" : @"test"
                            };
    [self.client setState:state forUUID:self.client.uuid onChannel:self.subscribedChannels.firstObject withCompletion:[self PN_successfulSetClientState:state]];
    [self waitFor:kPNSetClientStateTimeout];
}

@end
