//
//  PubNub+Suspend.h
//  pubnubTestBackground
//
//  Created by Valentin Tuller on 10/18/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import "PubNub.h"
#import "PNConnectionChannel.h"

@interface PubNub (Suspend)

-(void)warmUpConnection:(PNConnectionChannel *)connectionChannel;

-(BOOL)isAsyncLockingOperationInProgress;

-(void)handleLockingOperationComplete:(BOOL)shouldStartNext;


@end
