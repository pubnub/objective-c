//
//  PNBasicPresenceTestCase.h
//  PubNub Tests
//
//  Created by Jordan Zucker on 12/10/15.
//
//

#import "PNBasicSubscribeTestCase.h"

@interface PNBasicPresenceTestCase : PNBasicSubscribeTestCase
@property (nonatomic) PubNub *otherClient;
- (NSString *)otherClientChannelName;
@end
