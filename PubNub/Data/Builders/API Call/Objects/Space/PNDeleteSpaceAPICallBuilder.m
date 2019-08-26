/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNDeleteSpaceAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNDeleteSpaceAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNDeleteSpaceAPICallBuilder * (^)(NSString *spaceId))spaceId {
    return ^PNDeleteSpaceAPICallBuilder * (NSString *spaceId) {
        if ([spaceId isKindOfClass:[NSString class]] && spaceId.length) {
            [self setValue:spaceId forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNDeleteSpaceCompletionBlock block))performWithCompletion {
    return ^(PNDeleteSpaceCompletionBlock block) {
        [super performWithBlock:block];
    };
}


#pragma mark -


@end
