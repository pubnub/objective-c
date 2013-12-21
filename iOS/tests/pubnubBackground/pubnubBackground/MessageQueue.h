//
//  MessageQueue.h
//  pubnubBackground
//
//  Created by rajat  on 30/09/13.
//  Copyright (c) 2013 pubnub. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageQueue : NSObject {
    NSMutableArray* m_array;
    int count;
}

- (void) enqueue: (id)item;

- (id) dequeue;

- (id) peek;

- (void)clear;

@property (nonatomic, readonly) int count;

@end
