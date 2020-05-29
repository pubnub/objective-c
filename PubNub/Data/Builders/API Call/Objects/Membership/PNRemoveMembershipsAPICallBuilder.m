/**
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNRemoveMembershipsAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNRemoveMembershipsAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNRemoveMembershipsAPICallBuilder * (^)(PNMembershipFields includeFields))includeFields {
    return ^PNRemoveMembershipsAPICallBuilder * (PNMembershipFields includeFields) {
        [self setValue:@(includeFields) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNRemoveMembershipsAPICallBuilder * (^)(NSArray<NSString *> *channels))channels {
    return ^PNRemoveMembershipsAPICallBuilder * (NSArray<NSString *> *channels) {
        if ([channels isKindOfClass:[NSArray class]] && channels.count) {
            [self setValue:channels forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}

- (PNRemoveMembershipsAPICallBuilder * (^)(BOOL shouldIncludeCount))includeCount {
    return ^PNRemoveMembershipsAPICallBuilder * (BOOL shouldIncludeCount) {
        [self setValue:@(shouldIncludeCount) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNRemoveMembershipsAPICallBuilder * (^)(NSArray<NSString *> *sort))sort {
    return ^PNRemoveMembershipsAPICallBuilder * (NSArray<NSString *> *sort) {
        if ([sort isKindOfClass:[NSArray class]] && sort.count) {
            [self setValue:sort forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNRemoveMembershipsAPICallBuilder * (^)(NSString *filter))filter {
    return ^PNRemoveMembershipsAPICallBuilder * (NSString *filter) {
        if ([filter isKindOfClass:[NSString class]] && filter.length) {
            [self setValue:filter forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNRemoveMembershipsAPICallBuilder * (^)(NSUInteger limit))limit {
    return ^PNRemoveMembershipsAPICallBuilder * (NSUInteger limit) {
        [self setValue:@(limit) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNRemoveMembershipsAPICallBuilder * (^)(NSString *name))start {
    return ^PNRemoveMembershipsAPICallBuilder * (NSString *start) {
        if ([start isKindOfClass:[NSString class]] && start.length) {
            [self setValue:start forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}

- (PNRemoveMembershipsAPICallBuilder * (^)(NSString *uuid))uuid {
    return ^PNRemoveMembershipsAPICallBuilder * (NSString *uuid) {
        if ([uuid isKindOfClass:[NSString class]] && uuid.length) {
            [self setValue:uuid forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}

- (PNRemoveMembershipsAPICallBuilder * (^)(NSString *end))end {
    return ^PNRemoveMembershipsAPICallBuilder * (NSString *end) {
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
