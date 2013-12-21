//
//  FakeStub.h
//  pubnub
//
//  Created by Valentin Tuller on 10/2/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FakeStub : NSObject

@property (nonatomic, assign) unsigned long state;

- (void)handleStreamError:(CFErrorRef)error;

@end
