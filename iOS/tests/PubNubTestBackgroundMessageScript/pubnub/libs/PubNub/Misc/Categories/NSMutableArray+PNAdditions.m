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

+ (NSMutableArray *)pn_arrayUsingWeakReferences {
    
    return [self pn_arrayUsingWeakReferencesWithCapacity:0];
}

+ (NSMutableArray *)pn_arrayUsingWeakReferencesWithCapacity:(NSUInteger)capacity {
    
    CFArrayCallBacks callbacks = {0, NULL, NULL, NULL, CFEqual};
    
    
    return (__bridge id)(CFArrayCreateMutable(0, capacity, &callbacks));
}


#pragma mark - Instance methods


- (NSString *)logDescription {
    
    __block NSString *logDescription = @"<[";
    
    [self enumerateObjectsUsingBlock:^(id entry, NSUInteger entryIdx, BOOL *entryEnumeratorStop) {
        
        // Check whether parameter can be transformed for log or not
        if ([entry respondsToSelector:@selector(logDescription)]) {
            
            entry = [entry performSelector:@selector(logDescription)];
            entry = (entry ? entry : @"");
        }
        logDescription = [logDescription stringByAppendingFormat:@"%@%@", entry, (entryIdx + 1 != [self count] ? @"|" : @"]>")];
    }];
    
    
    return logDescription;
}

#pragma mark -


@end
