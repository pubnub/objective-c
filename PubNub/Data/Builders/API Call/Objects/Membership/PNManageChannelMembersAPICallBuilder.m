/**
 * @author Serhii Mamontov
 * @version 4.14.1
 * @since 4.14.1
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNManageChannelMembersAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNManageChannelMembersAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNManageChannelMembersAPICallBuilder * (^)(PNChannelMemberFields includeFields))includeFields {
    return ^PNManageChannelMembersAPICallBuilder * (PNChannelMemberFields includeFields) {
        [self setValue:@(includeFields) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNManageChannelMembersAPICallBuilder * (^)(BOOL shouldIncludeCount))includeCount {
    return ^PNManageChannelMembersAPICallBuilder * (BOOL shouldIncludeCount) {
        [self setValue:@(shouldIncludeCount) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNManageChannelMembersAPICallBuilder * (^)(NSArray<NSDictionary *> *uuids))set {
    return ^PNManageChannelMembersAPICallBuilder * (NSArray<NSDictionary *> *uuids) {
        if ([uuids isKindOfClass:[NSArray class]] && uuids.count) {
            [self setValue:uuids forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}

- (PNManageChannelMembersAPICallBuilder * (^)(NSArray<NSString *> *uuids))remove {
    return ^PNManageChannelMembersAPICallBuilder * (NSArray<NSString *> *uuids) {
        if ([uuids isKindOfClass:[NSArray class]] && uuids.count) {
            [self setValue:uuids forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}

- (PNManageChannelMembersAPICallBuilder * (^)(NSArray<NSString *> *sort))sort {
    return ^PNManageChannelMembersAPICallBuilder * (NSArray<NSString *> *sort) {
        if ([sort isKindOfClass:[NSArray class]] && sort.count) {
            [self setValue:sort forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNManageChannelMembersAPICallBuilder * (^)(NSString *filter))filter {
    return ^PNManageChannelMembersAPICallBuilder * (NSString *filter) {
        if ([filter isKindOfClass:[NSString class]] && filter.length) {
            [self setValue:filter forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNManageChannelMembersAPICallBuilder * (^)(NSUInteger limit))limit {
    return ^PNManageChannelMembersAPICallBuilder * (NSUInteger limit) {
        [self setValue:@(limit) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNManageChannelMembersAPICallBuilder * (^)(NSString *name))start {
    return ^PNManageChannelMembersAPICallBuilder * (NSString *start) {
        if ([start isKindOfClass:[NSString class]] && start.length) {
            [self setValue:start forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}

- (PNManageChannelMembersAPICallBuilder * (^)(NSString *end))end {
    return ^PNManageChannelMembersAPICallBuilder * (NSString *end) {
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
