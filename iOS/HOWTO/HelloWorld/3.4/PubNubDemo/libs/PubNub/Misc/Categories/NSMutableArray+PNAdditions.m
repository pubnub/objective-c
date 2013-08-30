//
//  NSMutableArray+PNAdditions.m
//  pubnub
//
//  Created by Sergey Mamontov on 12/16/12.
//
//

#import "NSMutableArray+PNAdditions.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub mutable array category must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Public interface methods

@implementation NSMutableArray (PNAdditions)


#pragma mark - Class methods

+ (NSMutableArray *)arrayUsingWeakReferences {
    
    return [self arrayUsingWeakReferencesWithCapacity:0];
}

+ (NSMutableArray *)arrayUsingWeakReferencesWithCapacity:(NSUInteger)capacity {
    
    CFArrayCallBacks callbacks = {0, NULL, NULL, NULL, CFEqual};
    
    
    return (__bridge id)(CFArrayCreateMutable(0, capacity, &callbacks));
}

#pragma mark -


@end
