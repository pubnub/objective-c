/**
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNSetMembershipsAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNSetMembershipsAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNSetMembershipsAPICallBuilder * (^)(PNMembershipFields includeFields))includeFields {
    return ^PNSetMembershipsAPICallBuilder * (PNMembershipFields includeFields) {
        [self setValue:@(includeFields) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNSetMembershipsAPICallBuilder * (^)(NSArray<NSDictionary *> *channels))channels {
    return ^PNSetMembershipsAPICallBuilder * (NSArray<NSDictionary *> *channels) {
        if ([channels isKindOfClass:[NSArray class]] && channels.count) {
            [self setValue:channels forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}

- (PNSetMembershipsAPICallBuilder * (^)(BOOL shouldIncludeCount))includeCount {
    return ^PNSetMembershipsAPICallBuilder * (BOOL shouldIncludeCount) {
        [self setValue:@(shouldIncludeCount) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNSetMembershipsAPICallBuilder * (^)(NSArray<NSString *> *sort))sort {
    return ^PNSetMembershipsAPICallBuilder * (NSArray<NSString *> *sort) {
        if ([sort isKindOfClass:[NSArray class]] && sort.count) {
            [self setValue:sort forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNSetMembershipsAPICallBuilder * (^)(NSString *filter))filter {
    return ^PNSetMembershipsAPICallBuilder * (NSString *filter) {
        if ([filter isKindOfClass:[NSString class]] && filter.length) {
            [self setValue:filter forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNSetMembershipsAPICallBuilder * (^)(NSUInteger limit))limit {
    return ^PNSetMembershipsAPICallBuilder * (NSUInteger limit) {
        [self setValue:@(limit) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNSetMembershipsAPICallBuilder * (^)(NSString *name))start {
    return ^PNSetMembershipsAPICallBuilder * (NSString *start) {
        if ([start isKindOfClass:[NSString class]] && start.length) {
            [self setValue:start forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}

- (PNSetMembershipsAPICallBuilder * (^)(NSString *uuid))uuid {
    return ^PNSetMembershipsAPICallBuilder * (NSString *uuid) {
        if ([uuid isKindOfClass:[NSString class]] && uuid.length) {
            [self setValue:uuid forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}

- (PNSetMembershipsAPICallBuilder * (^)(NSString *end))end {
    return ^PNSetMembershipsAPICallBuilder * (NSString *end) {
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
