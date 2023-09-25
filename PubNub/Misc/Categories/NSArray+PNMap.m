#import "NSArray+PNMap.h"


#pragma mark - Interface implementation

@implementation NSArray (PNMap)


#pragma mark - Mapping

- (NSArray *)pn_mapWithBlock:(nullable id (^)(id object, NSUInteger index))block {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
    
    [self enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL * __unused stop) {
        id mapped = block(object, idx);
        if (mapped) [array addObject:mapped];
    }];
    
    return array;
}

#pragma mark -


@end
