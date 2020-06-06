/**
 * @author Serhii Mamontov
 * @version 4.14.1
 * @since 4.14.1
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNRemoveChannelMembersAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNRemoveChannelMembersAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNRemoveChannelMembersAPICallBuilder * (^)(PNChannelMemberFields includeFields))includeFields {
    return ^PNRemoveChannelMembersAPICallBuilder * (PNChannelMemberFields includeFields) {
        [self setValue:@(includeFields) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNRemoveChannelMembersAPICallBuilder * (^)(BOOL shouldIncludeCount))includeCount {
    return ^PNRemoveChannelMembersAPICallBuilder * (BOOL shouldIncludeCount) {
        [self setValue:@(shouldIncludeCount) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNRemoveChannelMembersAPICallBuilder * (^)(NSArray<NSString *> *uuids))uuids {
    return ^PNRemoveChannelMembersAPICallBuilder * (NSArray<NSString *> *uuids) {
        if ([uuids isKindOfClass:[NSArray class]] && uuids.count) {
            [self setValue:uuids forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}

- (PNRemoveChannelMembersAPICallBuilder * (^)(NSArray<NSString *> *sort))sort {
    return ^PNRemoveChannelMembersAPICallBuilder * (NSArray<NSString *> *sort) {
        if ([sort isKindOfClass:[NSArray class]] && sort.count) {
            [self setValue:sort forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNRemoveChannelMembersAPICallBuilder * (^)(NSString *filter))filter {
    return ^PNRemoveChannelMembersAPICallBuilder * (NSString *filter) {
        if ([filter isKindOfClass:[NSString class]] && filter.length) {
            [self setValue:filter forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNRemoveChannelMembersAPICallBuilder * (^)(NSUInteger limit))limit {
    return ^PNRemoveChannelMembersAPICallBuilder * (NSUInteger limit) {
        [self setValue:@(limit) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNRemoveChannelMembersAPICallBuilder * (^)(NSString *name))start {
    return ^PNRemoveChannelMembersAPICallBuilder * (NSString *start) {
        if ([start isKindOfClass:[NSString class]] && start.length) {
            [self setValue:start forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}

- (PNRemoveChannelMembersAPICallBuilder * (^)(NSString *end))end {
    return ^PNRemoveChannelMembersAPICallBuilder * (NSString *end) {
        if ([end isKindOfClass:[NSString class]] && end.length) {
            [self setValue:end forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNManageChannelMembersCompletionBlock block))performWithCompletion {
    return ^(PNManageChannelMembersCompletionBlock block) {
        [super performWithBlock:block];
    };
}

#pragma mark -


@end
