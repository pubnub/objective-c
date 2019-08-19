/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNFetchUsersAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNFetchUsersAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNFetchUsersAPICallBuilder * (^)(PNUserFields includeFields))includeFields {
    return ^PNFetchUsersAPICallBuilder * (PNUserFields includeFields) {
        [self setValue:@(includeFields) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNFetchUsersAPICallBuilder * (^)(BOOL shouldIncludeCount))includeCount {
    return ^PNFetchUsersAPICallBuilder * (BOOL shouldIncludeCount) {
        [self setValue:@(shouldIncludeCount) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNFetchUsersAPICallBuilder * (^)(NSUInteger limit))limit {
    return ^PNFetchUsersAPICallBuilder * (NSUInteger limit) {
        [self setValue:@(limit) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNFetchUsersAPICallBuilder * (^)(NSString *name))start {
    return ^PNFetchUsersAPICallBuilder * (NSString *start) {
        if ([start isKindOfClass:[NSString class]] && start.length) {
            [self setValue:start forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNFetchUsersAPICallBuilder * (^)(NSString *end))end {
    return ^PNFetchUsersAPICallBuilder * (NSString *end) {
        if ([end isKindOfClass:[NSString class]] && end.length) {
            [self setValue:end forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNFetchUsersCompletionBlock block))performWithCompletion {
    return ^(PNFetchUsersCompletionBlock block) {
        [super performWithBlock:block];
    };
}

#pragma mark -


@end
