/**
 * @author Serhii Mamontov
 * @version 4.14.1
 * @since 4.14.1
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNFetchChannelMembersAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNFetchChannelMembersAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNFetchChannelMembersAPICallBuilder * (^)(PNChannelMemberFields includeFields))includeFields {
    return ^PNFetchChannelMembersAPICallBuilder * (PNChannelMemberFields includeFields) {
        [self setValue:@(includeFields) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNFetchChannelMembersAPICallBuilder * (^)(BOOL shouldIncludeCount))includeCount {
    return ^PNFetchChannelMembersAPICallBuilder * (BOOL shouldIncludeCount) {
        [self setValue:@(shouldIncludeCount) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNFetchChannelMembersAPICallBuilder * (^)(NSArray<NSString *> *sort))sort {
    return ^PNFetchChannelMembersAPICallBuilder * (NSArray<NSString *> *sort) {
        if ([sort isKindOfClass:[NSArray class]] && sort.count) {
            [self setValue:sort forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNFetchChannelMembersAPICallBuilder * (^)(NSString *filter))filter {
    return ^PNFetchChannelMembersAPICallBuilder * (NSString *filter) {
        if ([filter isKindOfClass:[NSString class]] && filter.length) {
            [self setValue:filter forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNFetchChannelMembersAPICallBuilder * (^)(NSUInteger limit))limit {
    return ^PNFetchChannelMembersAPICallBuilder * (NSUInteger limit) {
        [self setValue:@(limit) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNFetchChannelMembersAPICallBuilder * (^)(NSString *name))start {
    return ^PNFetchChannelMembersAPICallBuilder * (NSString *start) {
        if ([start isKindOfClass:[NSString class]] && start.length) {
            [self setValue:start forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNFetchChannelMembersAPICallBuilder * (^)(NSString *end))end {
    return ^PNFetchChannelMembersAPICallBuilder * (NSString *end) {
        if ([end isKindOfClass:[NSString class]] && end.length) {
            [self setValue:end forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNFetchChannelMembersCompletionBlock block))performWithCompletion {
    return ^(PNFetchChannelMembersCompletionBlock block) {
        [super performWithBlock:block];
    };
}

#pragma mark -


@end
