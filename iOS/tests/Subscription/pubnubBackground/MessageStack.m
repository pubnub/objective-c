//
//  MessageStack.m
//  pubnubBackground
//
//  Created by rajat  on 26/09/13.
//  Copyright (c) 2013 pubnub. All rights reserved.
//

#import "MessageStack.h"

@implementation MessageStack

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

- (void)push:(id)anObject
{
    [m_array addObject:anObject];
    count = m_array.count;
}

- (id) peek {
    id item = nil;
    if ([self count] != 0) {
        item = [m_array lastObject];
    }
    return item;
}


- (id)pop
{
    id obj = nil;
    if(m_array.count > 0)
    {
        obj = [m_array lastObject];
        [m_array removeLastObject];
        count = m_array.count;
    }
    return obj;
}

- (void)clear
{
    [m_array removeAllObjects];
    count = 0;
}

@end
