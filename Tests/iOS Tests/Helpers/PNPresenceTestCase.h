//
//  PNPresenceTestCase.h
//  PubNub Tests
//
//  Created by Jordan Zucker on 12/10/15.
//
//

#import "PNBasicClientTestCase.h"

@interface PNPresenceTestCase : PNBasicClientTestCase

@property (nonatomic) PubNub *otherClient;
- (NSString *)otherClientChannelName;

@end
