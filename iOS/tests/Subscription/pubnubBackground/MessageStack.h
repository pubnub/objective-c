//
//  MessageStack.h
//  pubnubBackground
//
//  Created by rajat  on 26/09/13.
//  Copyright (c) 2013 pubnub. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageStack : NSObject {
    NSMutableArray* m_array;
    int count;
}

- (void)push:(id)anObject;

- (id)pop;

- (void)clear;

- (id) peek;

@property (nonatomic, readonly) int count;

@end
