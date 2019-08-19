/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNFetchUserAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNFetchUserAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNFetchUserAPICallBuilder * (^)(PNUserFields includeFields))includeFields {
    return ^PNFetchUserAPICallBuilder * (PNUserFields includeFields) {
        [self setValue:@(includeFields) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNFetchUserAPICallBuilder * (^)(NSString *userId))userId {
    return ^PNFetchUserAPICallBuilder * (NSString *userId) {
        if ([userId isKindOfClass:[NSString class]] && userId.length) {
            [self setValue:userId forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNFetchUserCompletionBlock block))performWithCompletion {
    return ^(PNFetchUserCompletionBlock block) {
        [super performWithBlock:block];
    };
}

#pragma mark -


@end
