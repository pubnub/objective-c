//
//  XCTestCase+PNAdditions.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 4/21/16.
//
//

#import <PubNub/PubNub.h>
#import "XCTestCase+PNAdditions.h"

@implementation XCTestCase (PNAdditions)

#pragma mark - Channels

- (void)PN_client:(PubNub *)client subscribeToChannels:(NSArray<NSString *> *)channels withPresence:(BOOL)presence usingTimeToken:(NSNumber *)timeToken {
    
}

- (void)PN_client:(PubNub *)client unsubscribeFromChannels:(NSArray<NSString *> *)channels withPresence:(BOOL)presence {
    
}

#pragma mark - Channel Groups

- (void)PN_client:(PubNub *)client subscribeToChannelGroups:(NSArray<NSString *> *)channelGroups withPresence:(BOOL)presence usingTimeToken:(NSNumber *)timeToken {
    
}

- (void)PN_client:(PubNub *)client unsubscribeFromChannelGroups:(NSArray<NSString *> *)channelGroups withPresence:(BOOL)presence {
    
}

#pragma mark - Presence

- (void)PN_client:(PubNub *)client subscribeToPresenceChannels:(NSArray<NSString *> *)presenceChannels {
    
}

- (void)PN_client:(PubNub *)client unsubscribeToPresenceChannels:(NSArray<NSString *> *)presenceChannels {
    
}

#pragma mark - Other

- (void)PN_clientUnsubscribeFromAll:(PubNub *)client {
    [client unsubscribeFromAll];
}

@end
