/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNFetchSpacesAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNFetchSpacesAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNFetchSpacesAPICallBuilder * (^)(PNSpaceFields includeFields))includeFields {
    return ^PNFetchSpacesAPICallBuilder * (PNSpaceFields includeFields) {
        [self setValue:@(includeFields) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNFetchSpacesAPICallBuilder * (^)(BOOL shouldIncludeCount))includeCount {
    return ^PNFetchSpacesAPICallBuilder * (BOOL shouldIncludeCount) {
        [self setValue:@(shouldIncludeCount) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNFetchSpacesAPICallBuilder * (^)(NSUInteger limit))limit {
    return ^PNFetchSpacesAPICallBuilder * (NSUInteger limit) {
        [self setValue:@(limit) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNFetchSpacesAPICallBuilder * (^)(NSString *name))start {
    return ^PNFetchSpacesAPICallBuilder * (NSString *start) {
        if ([start isKindOfClass:[NSString class]] && start.length) {
            [self setValue:start forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNFetchSpacesAPICallBuilder * (^)(NSString *end))end {
    return ^PNFetchSpacesAPICallBuilder * (NSString *end) {
        if ([end isKindOfClass:[NSString class]] && end.length) {
            [self setValue:end forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNFetchSpacesCompletionBlock block))performWithCompletion {
    return ^(PNFetchSpacesCompletionBlock block) {
        [super performWithBlock:block];
    };
}

#pragma mark -


@end
