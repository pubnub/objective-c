//
//  MyPNRequestsQueue.h
//  pubnub
//
//  Created by Valentin Tuller on 2/28/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNRequestsQueue.h"

@interface MyPNRequestsQueue : PNRequestsQueue

- (PNBaseRequest *)dequeRequestWithIdentifier:(NSString *)requestIdentifier;

@end
