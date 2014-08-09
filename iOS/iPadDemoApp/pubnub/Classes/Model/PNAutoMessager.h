//
//  PNAutoMessager.h
//  pubnub
//
//  Created by Vadim Osovets on 8/10/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PNAutoMessager : NSObject

@property (nonatomic, copy) void (^presendMessageBlock)(NSString *message);

+ (instancetype)sharedManager;

- (void)start;
- (void)stop;

@end
