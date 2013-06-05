//
//  NSArray+PNAdditions.m
//  pubnub
//
//  Created by Sergey Mamontov on 05/14/13.
//
//

#import "NSArray+PNAdditions.h"


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
