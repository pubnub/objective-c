/**
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNSetMembersAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNSetMembersAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNSetMembersAPICallBuilder * (^)(PNMemberFields includeFields))includeFields {
    return ^PNSetMembersAPICallBuilder * (PNMemberFields includeFields) {
        [self setValue:@(includeFields) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNSetMembersAPICallBuilder * (^)(BOOL shouldIncludeCount))includeCount {
    return ^PNSetMembersAPICallBuilder * (BOOL shouldIncludeCount) {
        [self setValue:@(shouldIncludeCount) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNSetMembersAPICallBuilder * (^)(NSArray<NSDictionary *> *uuids))uuids {
    return ^PNSetMembersAPICallBuilder * (NSArray<NSDictionary *> *uuids) {
        if ([uuids isKindOfClass:[NSArray class]] && uuids.count) {
            [self setValue:uuids forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}

- (PNSetMembersAPICallBuilder * (^)(NSArray<NSString *> *sort))sort {
    return ^PNSetMembersAPICallBuilder * (NSArray<NSString *> *sort) {
        if ([sort isKindOfClass:[NSArray class]] && sort.count) {
            [self setValue:sort forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNSetMembersAPICallBuilder * (^)(NSString *filter))filter {
    return ^PNSetMembersAPICallBuilder * (NSString *filter) {
        if ([filter isKindOfClass:[NSString class]] && filter.length) {
            [self setValue:filter forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNSetMembersAPICallBuilder * (^)(NSUInteger limit))limit {
    return ^PNSetMembersAPICallBuilder * (NSUInteger limit) {
        [self setValue:@(limit) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNSetMembersAPICallBuilder * (^)(NSString *name))start {
    return ^PNSetMembersAPICallBuilder * (NSString *start) {
        if ([start isKindOfClass:[NSString class]] && start.length) {
            [self setValue:start forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}

- (PNSetMembersAPICallBuilder * (^)(NSString *end))end {
    return ^PNSetMembersAPICallBuilder * (NSString *end) {
        if ([end isKindOfClass:[NSString class]] && end.length) {
            [self setValue:end forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNManageMembersCompletionBlock block))performWithCompletion {
    return ^(PNManageMembersCompletionBlock block) {
        [super performWithBlock:block];
    };
}

#pragma mark -


@end
