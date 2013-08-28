//
//  NSArray+PNAdditions.m
//  pubnub
//
//  Created by Sergey Mamontov on 05/14/13.
//
//

#import "NSArray+PNAdditions.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub array category must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Public interface methods

@implementation NSArray (PNAdditions)


#pragma mark - Class methods

+ (NSArray *)arrayWithVarietyList:(va_list)list {

    NSMutableArray *array = [NSMutableArray array];
    id argument;
    while ((argument = va_arg(list, id))) {
        if (argument == nil)
            break;
        [array addObject:argument];
    }


    return array;
}

#pragma mark -


@end
