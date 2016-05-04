//
//  PNChannelGroupTestCase.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 5/4/16.
//
//

#import "PNClientTestCase.h"
#import "XCTestCase+PNChannelGroup.h"

@interface PNChannelGroupTestCase : PNClientTestCase
@property (nonatomic, strong, readonly) NSString *channelGroup;
@end

@implementation PNChannelGroupTestCase

- (BOOL)isRecording {
    return NO;
}

- (NSString *)channelGroup {
    return @"test-group";
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [self.client removeChannelsFromGroup:self.channelGroup withCompletion:[self PN_channelGroupRemoveAllChannels]];
    [self waitFor:kPNChannelGroupChangeTimeout];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [self.client removeChannelsFromGroup:self.channelGroup withCompletion:[self PN_channelGroupRemoveAllChannels]];
    [self waitFor:kPNChannelGroupChangeTimeout];
    [super tearDown];
}

- (void)testAddChannelsToAChannelGroup {
    [self.client addChannels:@[@"a", @"c"] toGroup:self.channelGroup withCompletion:[self PN_channelGroupAdd]];
    [self waitFor:kPNChannelGroupChangeTimeout];
}

@end
