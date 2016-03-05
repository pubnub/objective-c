/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
#import "PNArray.h"


#pragma mark Interface implementation

@implementation PNArray


#pragma mark - Data mapping

+ (NSArray *)mapObjects:(NSArray *)objects usingBlock:(id(^)(id object))mappingBlock {
    
    NSMutableArray *mappedObjects = nil;
    if (objects.count) {
        
        mappedObjects = [[NSMutableArray alloc] initWithCapacity:objects.count];
        objects = [objects sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        [objects enumerateObjectsUsingBlock:^(id object, __unused NSUInteger objectIdx,
                                              __unused BOOL *objectEnumeratorStop) {
            
            id mappedObject = mappingBlock(object);
            if (mappedObject) { [mappedObjects addObject:mappedObject]; }
        }];
    }
    
    return [mappedObjects copy];
}

#pragma mark -


@end
