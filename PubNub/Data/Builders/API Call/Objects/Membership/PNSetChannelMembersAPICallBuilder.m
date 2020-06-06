/**
 * @author Serhii Mamontov
 * @version 4.14.1
 * @since 4.14.1
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNSetChannelMembersAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNSetChannelMembersAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNSetChannelMembersAPICallBuilder * (^)(PNChannelMemberFields includeFields))includeFields {
    return ^PNSetChannelMembersAPICallBuilder * (PNChannelMemberFields includeFields) {
        [self setValue:@(includeFields) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNSetChannelMembersAPICallBuilder * (^)(BOOL shouldIncludeCount))includeCount {
    return ^PNSetChannelMembersAPICallBuilder * (BOOL shouldIncludeCount) {
        [self setValue:@(shouldIncludeCount) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNSetChannelMembersAPICallBuilder * (^)(NSArray<NSDictionary *> *uuids))uuids {
    return ^PNSetChannelMembersAPICallBuilder * (NSArray<NSDictionary *> *uuids) {
        if ([uuids isKindOfClass:[NSArray class]] && uuids.count) {
            [self setValue:uuids forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}

- (PNSetChannelMembersAPICallBuilder * (^)(NSArray<NSString *> *sort))sort {
    return ^PNSetChannelMembersAPICallBuilder * (NSArray<NSString *> *sort) {
        if ([sort isKindOfClass:[NSArray class]] && sort.count) {
            [self setValue:sort forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNSetChannelMembersAPICallBuilder * (^)(NSString *filter))filter {
    return ^PNSetChannelMembersAPICallBuilder * (NSString *filter) {
        if ([filter isKindOfClass:[NSString class]] && filter.length) {
            [self setValue:filter forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNSetChannelMembersAPICallBuilder * (^)(NSUInteger limit))limit {
    return ^PNSetChannelMembersAPICallBuilder * (NSUInteger limit) {
        [self setValue:@(limit) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNSetChannelMembersAPICallBuilder * (^)(NSString *name))start {
    return ^PNSetChannelMembersAPICallBuilder * (NSString *start) {
        if ([start isKindOfClass:[NSString class]] && start.length) {
            [self setValue:start forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}

- (PNSetChannelMembersAPICallBuilder * (^)(NSString *end))end {
    return ^PNSetChannelMembersAPICallBuilder * (NSString *end) {
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
