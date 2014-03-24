//
//  PNMessagingChannel+Test.h
//  pubnub
//
//  Created by Valentin Tuller on 3/21/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNMessagingChannel.h"

@interface PNMessagingChannel (Test)

@property (nonatomic, assign) unsigned long messagingState;
- (void)reconnect;

@end
