//
//  NSError+PNAdditions.m
//  pubnub
//
//  Created by Sergey Mamontov on 8/28/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "NSError+PNAdditions.h"


// ARC check
#if !__has_feature(objc_arc)
    #error PubNub error category must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark - Private interface methods

@implementation NSError (PNAdditions)


#pragma mark - Instance methods

- (NSString *)logDescription {
    
    return [NSString stringWithFormat:@"<%@|%ld>", self.domain, (long)self.code];
}

#pragma mark -


@end
