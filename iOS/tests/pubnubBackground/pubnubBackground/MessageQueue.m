//
//  MessageQueue.m
//  pubnubBackground
//
//  Created by rajat  on 30/09/13.
//  Copyright (c) 2013 pubnub. All rights reserved.
//

#import "MessageQueue.h"

@implementation MessageQueue

@synthesize count;

- (id)init
{
    if( self=[super init] )
    {
        m_array = [[NSMutableArray alloc] init];
        count = 0;
    }
    return self;
}

- (void) enqueue: (id)item {
    [m_array addObject:item];
	count = m_array.count;
}

- (id) dequeue {
    id item = nil;
	if(m_array.count > 0)
	{
        item = [m_array objectAtIndex:0];
        [m_array removeObjectAtIndex:0];
		count = m_array.count;
	}
	return item;
}

- (id) peek {
    id item = nil;
    if ([m_array count] != 0) {
        item = [m_array objectAtIndex:0];
    }
    return item;
}

- (void)clear
{
    [m_array removeAllObjects];
    count = 0;
}

@end
