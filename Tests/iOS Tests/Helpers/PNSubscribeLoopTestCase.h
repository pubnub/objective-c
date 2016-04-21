//
//  PNSubscribeLoopTestCase.h
//  PubNub Tests
//
//  Created by Jordan Zucker on 4/21/16.
//
//

#import "PNClientTestCase.h"

@interface PNSubscribeLoopTestCase : PNClientTestCase <PNObjectEventListener>

- (NSArray<NSString *> *)subscribedChannels;
- (NSArray<NSString *> *)subscribedChannelGroups;
- (BOOL)shouldSubscribeWithPresence;
- (BOOL)shouldRunSetUp;
- (BOOL)shouldRunTearDown;

@end
