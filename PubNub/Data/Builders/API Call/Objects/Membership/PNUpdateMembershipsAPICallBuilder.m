/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNUpdateMembershipsAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNUpdateMembershipsAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNUpdateMembershipsAPICallBuilder * (^)(PNMembershipFields includeFields))includeFields {
    return ^PNUpdateMembershipsAPICallBuilder * (PNMembershipFields includeFields) {
        [self setValue:@(includeFields) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNUpdateMembershipsAPICallBuilder * (^)(NSArray<NSDictionary *> *spaces))update {
    return ^PNUpdateMembershipsAPICallBuilder * (NSArray<NSDictionary *> *spaces) {
        if ([spaces isKindOfClass:[NSArray class]] && spaces.count) {
            [self setValue:spaces forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}

- (PNUpdateMembershipsAPICallBuilder * (^)(BOOL shouldIncludeCount))includeCount {
    return ^PNUpdateMembershipsAPICallBuilder * (BOOL shouldIncludeCount) {
        [self setValue:@(shouldIncludeCount) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNUpdateMembershipsAPICallBuilder * (^)(NSArray<NSDictionary *> *spaces))add {
    return ^PNUpdateMembershipsAPICallBuilder * (NSArray<NSDictionary *> *spaces) {
        if ([spaces isKindOfClass:[NSArray class]] && spaces.count) {
            [self setValue:spaces forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}

- (PNUpdateMembershipsAPICallBuilder * (^)(NSArray<NSString *> *spaces))remove {
    return ^PNUpdateMembershipsAPICallBuilder * (NSArray<NSString *> *spaces) {
        if ([spaces isKindOfClass:[NSArray class]] && spaces.count) {
            [self setValue:spaces forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}

- (PNUpdateMembershipsAPICallBuilder * (^)(NSString *userId))userId {
    return ^PNUpdateMembershipsAPICallBuilder * (NSString *userId) {
        if ([userId isKindOfClass:[NSString class]] && userId.length) {
            [self setValue:userId forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNUpdateMembershipsAPICallBuilder * (^)(NSUInteger limit))limit {
    return ^PNUpdateMembershipsAPICallBuilder * (NSUInteger limit) {
        [self setValue:@(limit) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNUpdateMembershipsAPICallBuilder * (^)(NSString *name))start {
    return ^PNUpdateMembershipsAPICallBuilder * (NSString *start) {
        if ([start isKindOfClass:[NSString class]] && start.length) {
            [self setValue:start forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}

- (PNUpdateMembershipsAPICallBuilder * (^)(NSString *end))end {
    return ^PNUpdateMembershipsAPICallBuilder * (NSString *end) {
        if ([end isKindOfClass:[NSString class]] && end.length) {
            [self setValue:end forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNUpdateMembershipsCompletionBlock block))performWithCompletion {
    return ^(PNUpdateMembershipsCompletionBlock block) {
        [super performWithBlock:block];
    };
}

#pragma mark -

@end
