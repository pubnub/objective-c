/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNFetchMembersAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNFetchMembersAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNFetchMembersAPICallBuilder * (^)(PNMemberFields includeFields))includeFields {
    return ^PNFetchMembersAPICallBuilder * (PNMemberFields includeFields) {
        [self setValue:@(includeFields) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNFetchMembersAPICallBuilder * (^)(BOOL shouldIncludeCount))includeCount {
    return ^PNFetchMembersAPICallBuilder * (BOOL shouldIncludeCount) {
        [self setValue:@(shouldIncludeCount) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNFetchMembersAPICallBuilder * (^)(NSString *spaceId))spaceId {
    return ^PNFetchMembersAPICallBuilder * (NSString *spaceId) {
        if ([spaceId isKindOfClass:[NSString class]] && spaceId.length) {
            [self setValue:spaceId forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNFetchMembersAPICallBuilder * (^)(NSUInteger limit))limit {
    return ^PNFetchMembersAPICallBuilder * (NSUInteger limit) {
        [self setValue:@(limit) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNFetchMembersAPICallBuilder * (^)(NSString *name))start {
    return ^PNFetchMembersAPICallBuilder * (NSString *start) {
        if ([start isKindOfClass:[NSString class]] && start.length) {
            [self setValue:start forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNFetchMembersAPICallBuilder * (^)(NSString *end))end {
    return ^PNFetchMembersAPICallBuilder * (NSString *end) {
        if ([end isKindOfClass:[NSString class]] && end.length) {
            [self setValue:end forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNFetchMembersCompletionBlock block))performWithCompletion {
    return ^(PNFetchMembersCompletionBlock block) {
        [super performWithBlock:block];
    };
}

#pragma mark -


@end
