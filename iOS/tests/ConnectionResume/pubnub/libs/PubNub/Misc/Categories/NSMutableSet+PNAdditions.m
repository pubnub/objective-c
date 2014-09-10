//
//  NSMutableSet+PNAdditions.m
//  pubnub
//
//  Created by Sergey Mamontov on 8/28/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "NSMutableSet+PNAdditions.h"


#pragma mark Public interface methods

@implementation NSMutableSet (PNAdditions)


#pragma mark - Instance methods

- (NSString *)logDescription {
    
    __block NSString *logDescription = @"<[";
    __block NSUInteger entryIdx = 0;
    [self enumerateObjectsUsingBlock:^(id entry, BOOL *entryEnumeratorStop) {
        
        // Check whether parameter can be transformed for log or not
        if ([entry respondsToSelector:@selector(logDescription)]) {
            
            entry = [entry performSelector:@selector(logDescription)];
            entry = (entry ? entry : @"");
        }
        logDescription = [logDescription stringByAppendingFormat:@"%@%@", entry, (entryIdx + 1 != [self count] ? @"|" : @"]>")];
        
        entryIdx++;
    }];
    
    
    return logDescription;
}

#pragma mark -


@end
