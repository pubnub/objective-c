/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNManageMembershipsAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNManageMembershipsAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNManageMembershipsAPICallBuilder * (^)(PNMembershipFields includeFields))includeFields {
    return ^PNManageMembershipsAPICallBuilder * (PNMembershipFields includeFields) {
        [self setValue:@(includeFields) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNManageMembershipsAPICallBuilder * (^)(NSArray<NSDictionary *> *spaces))update {
    return ^PNManageMembershipsAPICallBuilder * (NSArray<NSDictionary *> *spaces) {
        if ([spaces isKindOfClass:[NSArray class]] && spaces.count) {
            [self setValue:spaces forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}

- (PNManageMembershipsAPICallBuilder * (^)(BOOL shouldIncludeCount))includeCount {
    return ^PNManageMembershipsAPICallBuilder * (BOOL shouldIncludeCount) {
        [self setValue:@(shouldIncludeCount) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNManageMembershipsAPICallBuilder * (^)(NSArray<NSDictionary *> *spaces))add {
    return ^PNManageMembershipsAPICallBuilder * (NSArray<NSDictionary *> *spaces) {
        if ([spaces isKindOfClass:[NSArray class]] && spaces.count) {
            [self setValue:spaces forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}

- (PNManageMembershipsAPICallBuilder * (^)(NSArray<NSString *> *spaces))remove {
    return ^PNManageMembershipsAPICallBuilder * (NSArray<NSString *> *spaces) {
        if ([spaces isKindOfClass:[NSArray class]] && spaces.count) {
            [self setValue:spaces forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}

- (PNManageMembershipsAPICallBuilder * (^)(NSString *userId))userId {
    return ^PNManageMembershipsAPICallBuilder * (NSString *userId) {
        if ([userId isKindOfClass:[NSString class]] && userId.length) {
            [self setValue:userId forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNManageMembershipsAPICallBuilder * (^)(NSUInteger limit))limit {
    return ^PNManageMembershipsAPICallBuilder * (NSUInteger limit) {
        [self setValue:@(limit) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNManageMembershipsAPICallBuilder * (^)(NSString *name))start {
    return ^PNManageMembershipsAPICallBuilder * (NSString *start) {
        if ([start isKindOfClass:[NSString class]] && start.length) {
            [self setValue:start forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}

- (PNManageMembershipsAPICallBuilder * (^)(NSString *end))end {
    return ^PNManageMembershipsAPICallBuilder * (NSString *end) {
        if ([end isKindOfClass:[NSString class]] && end.length) {
            [self setValue:end forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNManageMembershipsCompletionBlock block))performWithCompletion {
    return ^(PNManageMembershipsCompletionBlock block) {
        [super performWithBlock:block];
    };
}

#pragma mark -

@end
