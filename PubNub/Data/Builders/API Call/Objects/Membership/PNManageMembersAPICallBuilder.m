/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
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

- (PNManageMembersAPICallBuilder * (^)(NSArray<NSDictionary *> *users))update {
    return ^PNManageMembersAPICallBuilder * (NSArray<NSDictionary *> *users) {
        if ([users isKindOfClass:[NSArray class]] && users.count) {
            [self setValue:users forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}

- (PNManageMembersAPICallBuilder * (^)(BOOL shouldIncludeCount))includeCount {
    return ^PNManageMembersAPICallBuilder * (BOOL shouldIncludeCount) {
        [self setValue:@(shouldIncludeCount) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNManageMembersAPICallBuilder * (^)(NSArray<NSDictionary *> *users))add {
    return ^PNManageMembersAPICallBuilder * (NSArray<NSDictionary *> *users) {
        if ([users isKindOfClass:[NSArray class]] && users.count) {
            [self setValue:users forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}

- (PNManageMembersAPICallBuilder * (^)(NSArray<NSString *> *users))remove {
    return ^PNManageMembersAPICallBuilder * (NSArray<NSString *> *users) {
        if ([users isKindOfClass:[NSArray class]] && users.count) {
            [self setValue:users forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}

- (PNManageMembersAPICallBuilder * (^)(NSString *spaceId))spaceId {
    return ^PNManageMembersAPICallBuilder * (NSString *spaceId) {
        if ([spaceId isKindOfClass:[NSString class]] && spaceId.length) {
            [self setValue:spaceId forParameter:NSStringFromSelector(_cmd)];
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
