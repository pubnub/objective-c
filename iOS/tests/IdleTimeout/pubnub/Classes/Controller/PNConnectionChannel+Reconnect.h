//
//  PNConnectionChannel+Reconnect.h
//  pubnub
//
//  Created by Valentin Tuller on 11/11/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import "PNConnectionChannel.h"

@interface PNConnectionChannel (Reconnect)

-(void)setState:(unsigned long)state;

@end
