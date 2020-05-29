/**
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNFetchAllChannelsMetadataAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNFetchAllChannelsMetadataAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNFetchAllChannelsMetadataAPICallBuilder * (^)(PNChannelFields includeFields))includeFields {
    return ^PNFetchAllChannelsMetadataAPICallBuilder * (PNChannelFields includeFields) {
        [self setValue:@(includeFields) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNFetchAllChannelsMetadataAPICallBuilder * (^)(BOOL shouldIncludeCount))includeCount {
    return ^PNFetchAllChannelsMetadataAPICallBuilder * (BOOL shouldIncludeCount) {
        [self setValue:@(shouldIncludeCount) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNFetchAllChannelsMetadataAPICallBuilder * (^)(NSArray<NSString*> *sort))sort {
    return ^PNFetchAllChannelsMetadataAPICallBuilder * (NSArray<NSString*> *sort) {
        if ([sort isKindOfClass:[NSArray class]] && sort.count) {
            [self setValue:sort forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNFetchAllChannelsMetadataAPICallBuilder * (^)(NSString *filter))filter {
    return ^PNFetchAllChannelsMetadataAPICallBuilder * (NSString *filter) {
        if ([filter isKindOfClass:[NSString class]] && filter.length) {
            [self setValue:filter forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNFetchAllChannelsMetadataAPICallBuilder * (^)(NSUInteger limit))limit {
    return ^PNFetchAllChannelsMetadataAPICallBuilder * (NSUInteger limit) {
        [self setValue:@(limit) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNFetchAllChannelsMetadataAPICallBuilder * (^)(NSString *name))start {
    return ^PNFetchAllChannelsMetadataAPICallBuilder * (NSString *start) {
        if ([start isKindOfClass:[NSString class]] && start.length) {
            [self setValue:start forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNFetchAllChannelsMetadataAPICallBuilder * (^)(NSString *end))end {
    return ^PNFetchAllChannelsMetadataAPICallBuilder * (NSString *end) {
        if ([end isKindOfClass:[NSString class]] && end.length) {
            [self setValue:end forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNFetchAllChannelsMetadataCompletionBlock block))performWithCompletion {
    return ^(PNFetchAllChannelsMetadataCompletionBlock block) {
        [super performWithBlock:block];
    };
}

#pragma mark -


@end
