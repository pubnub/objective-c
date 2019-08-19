/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNUpdateMembersAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNUpdateMembersAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNUpdateMembersAPICallBuilder * (^)(PNMemberFields includeFields))includeFields {
    return ^PNUpdateMembersAPICallBuilder * (PNMemberFields includeFields) {
        [self setValue:@(includeFields) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNUpdateMembersAPICallBuilder * (^)(NSArray<NSDictionary *> *users))update {
    return ^PNUpdateMembersAPICallBuilder * (NSArray<NSDictionary *> *users) {
        if ([users isKindOfClass:[NSArray class]] && users.count) {
            [self setValue:users forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}

- (PNUpdateMembersAPICallBuilder * (^)(BOOL shouldIncludeCount))includeCount {
    return ^PNUpdateMembersAPICallBuilder * (BOOL shouldIncludeCount) {
        [self setValue:@(shouldIncludeCount) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNUpdateMembersAPICallBuilder * (^)(NSArray<NSDictionary *> *users))add {
    return ^PNUpdateMembersAPICallBuilder * (NSArray<NSDictionary *> *users) {
        if ([users isKindOfClass:[NSArray class]] && users.count) {
            [self setValue:users forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}

- (PNUpdateMembersAPICallBuilder * (^)(NSArray<NSString *> *users))remove {
    return ^PNUpdateMembersAPICallBuilder * (NSArray<NSString *> *users) {
        if ([users isKindOfClass:[NSArray class]] && users.count) {
            [self setValue:users forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}

- (PNUpdateMembersAPICallBuilder * (^)(NSString *spaceId))spaceId {
    return ^PNUpdateMembersAPICallBuilder * (NSString *spaceId) {
        if ([spaceId isKindOfClass:[NSString class]] && spaceId.length) {
            [self setValue:spaceId forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNUpdateMembersAPICallBuilder * (^)(NSUInteger limit))limit {
    return ^PNUpdateMembersAPICallBuilder * (NSUInteger limit) {
        [self setValue:@(limit) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNUpdateMembersAPICallBuilder * (^)(NSString *name))start {
    return ^PNUpdateMembersAPICallBuilder * (NSString *start) {
        if ([start isKindOfClass:[NSString class]] && start.length) {
            [self setValue:start forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}

- (PNUpdateMembersAPICallBuilder * (^)(NSString *end))end {
    return ^PNUpdateMembersAPICallBuilder * (NSString *end) {
        if ([end isKindOfClass:[NSString class]] && end.length) {
            [self setValue:end forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNUpdateMembersCompletionBlock block))performWithCompletion {
    return ^(PNUpdateMembersCompletionBlock block) {
        [super performWithBlock:block];
    };
}

#pragma mark -


@end
