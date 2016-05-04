//
//  XCTestCase+PNChannelGroup.h
//  PubNub Tests
//
//  Created by Jordan Zucker on 5/4/16.
//
//

#import <XCTest/XCTest.h>
#import <PubNub/PubNub.h>

@interface XCTestCase (PNChannelGroup)

- (PNChannelGroupChangeCompletionBlock)PN_channelGroupAdd;
- (PNChannelGroupChangeCompletionBlock)PN_channelGroupRemoveSomeChannels;
- (PNGroupChannelsAuditCompletionBlock)PN_channelGroupAudit;
- (PNChannelGroupChangeCompletionBlock)PN_channelGroupRemoveAllChannels;

@end
