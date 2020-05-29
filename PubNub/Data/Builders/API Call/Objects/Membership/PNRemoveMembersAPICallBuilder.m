/**
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNRemoveMembersAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNRemoveMembersAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNRemoveMembersAPICallBuilder * (^)(PNMemberFields includeFields))includeFields {
    return ^PNRemoveMembersAPICallBuilder * (PNMemberFields includeFields) {
        [self setValue:@(includeFields) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNRemoveMembersAPICallBuilder * (^)(BOOL shouldIncludeCount))includeCount {
    return ^PNRemoveMembersAPICallBuilder * (BOOL shouldIncludeCount) {
        [self setValue:@(shouldIncludeCount) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNRemoveMembersAPICallBuilder * (^)(NSArray<NSString *> *uuids))uuids {
    return ^PNRemoveMembersAPICallBuilder * (NSArray<NSString *> *uuids) {
        if ([uuids isKindOfClass:[NSArray class]] && uuids.count) {
            [self setValue:uuids forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}

- (PNRemoveMembersAPICallBuilder * (^)(NSArray<NSString *> *sort))sort {
    return ^PNRemoveMembersAPICallBuilder * (NSArray<NSString *> *sort) {
        if ([sort isKindOfClass:[NSArray class]] && sort.count) {
            [self setValue:sort forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNRemoveMembersAPICallBuilder * (^)(NSString *filter))filter {
    return ^PNRemoveMembersAPICallBuilder * (NSString *filter) {
        if ([filter isKindOfClass:[NSString class]] && filter.length) {
            [self setValue:filter forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNRemoveMembersAPICallBuilder * (^)(NSUInteger limit))limit {
    return ^PNRemoveMembersAPICallBuilder * (NSUInteger limit) {
        [self setValue:@(limit) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNRemoveMembersAPICallBuilder * (^)(NSString *name))start {
    return ^PNRemoveMembersAPICallBuilder * (NSString *start) {
        if ([start isKindOfClass:[NSString class]] && start.length) {
            [self setValue:start forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}

- (PNRemoveMembersAPICallBuilder * (^)(NSString *end))end {
    return ^PNRemoveMembersAPICallBuilder * (NSString *end) {
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
