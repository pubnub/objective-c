/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNFetchSpaceAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNFetchSpaceAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNFetchSpaceAPICallBuilder * (^)(PNSpaceFields includeFields))includeFields {
    return ^PNFetchSpaceAPICallBuilder * (PNSpaceFields includeFields) {
        [self setValue:@(includeFields) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNFetchSpaceAPICallBuilder * (^)(NSString *spaceId))spaceId {
    return ^PNFetchSpaceAPICallBuilder * (NSString *spaceId) {
        if ([spaceId isKindOfClass:[NSString class]] && spaceId.length) {
            [self setValue:spaceId forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNFetchSpaceCompletionBlock block))performWithCompletion {
    return ^(PNFetchSpaceCompletionBlock block) {
        [super performWithBlock:block];
    };
}

#pragma mark -


@end
