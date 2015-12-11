//
//  PNBasicPresenceTestCase.h
//  PubNub Tests
//
//  Created by Jordan Zucker on 12/10/15.
//
//

#import <PubNub/PubNub.h>
#import "PNBasicSubscribeTestCase.h"

@interface PNBasicPresenceTestCase : PNBasicSubscribeTestCase <PNObjectEventListener>
@property (nonatomic) PubNub *otherClient;
- (NSString *)otherClientChannelName;
@end
