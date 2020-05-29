/**
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNFetchAllUUIDMetadataAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNFetchAllUUIDMetadataAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNFetchAllUUIDMetadataAPICallBuilder * (^)(PNUUIDFields includeFields))includeFields {
    return ^PNFetchAllUUIDMetadataAPICallBuilder * (PNUUIDFields includeFields) {
        [self setValue:@(includeFields) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNFetchAllUUIDMetadataAPICallBuilder * (^)(BOOL shouldIncludeCount))includeCount {
    return ^PNFetchAllUUIDMetadataAPICallBuilder * (BOOL shouldIncludeCount) {
        [self setValue:@(shouldIncludeCount) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNFetchAllUUIDMetadataAPICallBuilder * (^)(NSArray<NSString *> *sort))sort {
    return ^PNFetchAllUUIDMetadataAPICallBuilder * (NSArray<NSString *> *sort) {
        if ([sort isKindOfClass:[NSArray class]] && sort.count) {
            [self setValue:sort forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNFetchAllUUIDMetadataAPICallBuilder * (^)(NSString *filter))filter {
    return ^PNFetchAllUUIDMetadataAPICallBuilder * (NSString *filter) {
        if ([filter isKindOfClass:[NSString class]] && filter.length) {
            [self setValue:filter forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNFetchAllUUIDMetadataAPICallBuilder * (^)(NSUInteger limit))limit {
    return ^PNFetchAllUUIDMetadataAPICallBuilder * (NSUInteger limit) {
        [self setValue:@(limit) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNFetchAllUUIDMetadataAPICallBuilder * (^)(NSString *name))start {
    return ^PNFetchAllUUIDMetadataAPICallBuilder * (NSString *start) {
        if ([start isKindOfClass:[NSString class]] && start.length) {
            [self setValue:start forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNFetchAllUUIDMetadataAPICallBuilder * (^)(NSString *end))end {
    return ^PNFetchAllUUIDMetadataAPICallBuilder * (NSString *end) {
        if ([end isKindOfClass:[NSString class]] && end.length) {
            [self setValue:end forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNFetchAllUUIDMetadataCompletionBlock block))performWithCompletion {
    return ^(PNFetchAllUUIDMetadataCompletionBlock block) {
        [super performWithBlock:block];
    };
}

#pragma mark -


@end
