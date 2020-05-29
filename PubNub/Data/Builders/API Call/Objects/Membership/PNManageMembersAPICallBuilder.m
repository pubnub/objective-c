/**
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNManageMembersAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNManageMembersAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNManageMembersAPICallBuilder * (^)(PNMemberFields includeFields))includeFields {
    return ^PNManageMembersAPICallBuilder * (PNMemberFields includeFields) {
        [self setValue:@(includeFields) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNManageMembersAPICallBuilder * (^)(BOOL shouldIncludeCount))includeCount {
    return ^PNManageMembersAPICallBuilder * (BOOL shouldIncludeCount) {
        [self setValue:@(shouldIncludeCount) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNManageMembersAPICallBuilder * (^)(NSArray<NSDictionary *> *uuids))set {
    return ^PNManageMembersAPICallBuilder * (NSArray<NSDictionary *> *uuids) {
        if ([uuids isKindOfClass:[NSArray class]] && uuids.count) {
            [self setValue:uuids forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}

- (PNManageMembersAPICallBuilder * (^)(NSArray<NSString *> *uuids))remove {
    return ^PNManageMembersAPICallBuilder * (NSArray<NSString *> *uuids) {
        if ([uuids isKindOfClass:[NSArray class]] && uuids.count) {
            [self setValue:uuids forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}

- (PNManageMembersAPICallBuilder * (^)(NSArray<NSString *> *sort))sort {
    return ^PNManageMembersAPICallBuilder * (NSArray<NSString *> *sort) {
        if ([sort isKindOfClass:[NSArray class]] && sort.count) {
            [self setValue:sort forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNManageMembersAPICallBuilder * (^)(NSString *filter))filter {
    return ^PNManageMembersAPICallBuilder * (NSString *filter) {
        if ([filter isKindOfClass:[NSString class]] && filter.length) {
            [self setValue:filter forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNManageMembersAPICallBuilder * (^)(NSUInteger limit))limit {
    return ^PNManageMembersAPICallBuilder * (NSUInteger limit) {
        [self setValue:@(limit) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNManageMembersAPICallBuilder * (^)(NSString *name))start {
    return ^PNManageMembersAPICallBuilder * (NSString *start) {
        if ([start isKindOfClass:[NSString class]] && start.length) {
            [self setValue:start forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}

- (PNManageMembersAPICallBuilder * (^)(NSString *end))end {
    return ^PNManageMembersAPICallBuilder * (NSString *end) {
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
