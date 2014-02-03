//
//  PNHeartbeatRequest+Reset.h
//  pubnubTestBackground
//
//  Created by Valentin Tuller on 2/3/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNHeartbeatRequest.h"

@interface PNHeartbeatRequest (Reset)

@property (nonatomic, assign) NSUInteger retryCount;

@end
