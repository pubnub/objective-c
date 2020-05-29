/**
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
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

- (PNManageMembershipsAPICallBuilder * (^)(NSArray<NSDictionary *> *channels))set {
    return ^PNManageMembershipsAPICallBuilder * (NSArray<NSDictionary *> *channels) {
        if ([channels isKindOfClass:[NSArray class]] && channels.count) {
            [self setValue:channels forParameter:NSStringFromSelector(_cmd)];
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

- (PNManageMembershipsAPICallBuilder * (^)(NSArray<NSString *> *channels))remove {
    return ^PNManageMembershipsAPICallBuilder * (NSArray<NSString *> *channels) {
        if ([channels isKindOfClass:[NSArray class]] && channels.count) {
            [self setValue:channels forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}

- (PNManageMembershipsAPICallBuilder * (^)(NSArray<NSString *> *sort))sort {
    return ^PNManageMembershipsAPICallBuilder * (NSArray<NSString *> *sort) {
        if ([sort isKindOfClass:[NSArray class]] && sort.count) {
            [self setValue:sort forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNManageMembershipsAPICallBuilder * (^)(NSString *filter))filter {
    return ^PNManageMembershipsAPICallBuilder * (NSString *filter) {
        if ([filter isKindOfClass:[NSString class]] && filter.length) {
            [self setValue:filter forParameter:NSStringFromSelector(_cmd)];
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

- (PNManageMembershipsAPICallBuilder *(^)(NSString *uuid))uuid {
    return ^PNManageMembershipsAPICallBuilder * (NSString *uuid) {
        if ([uuid isKindOfClass:[NSString class]] && uuid.length) {
            [self setValue:uuid forParameter:NSStringFromSelector(_cmd)];
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
