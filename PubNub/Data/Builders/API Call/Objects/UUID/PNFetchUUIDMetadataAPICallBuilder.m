/**
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNFetchUUIDMetadataAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNFetchUUIDMetadataAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNFetchUUIDMetadataAPICallBuilder * (^)(PNUUIDFields includeFields))includeFields {
    return ^PNFetchUUIDMetadataAPICallBuilder * (PNUUIDFields includeFields) {
        [self setValue:@(includeFields) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNFetchUUIDMetadataAPICallBuilder * (^)(NSString *uuid))uuid {
    return ^PNFetchUUIDMetadataAPICallBuilder * (NSString *uuid) {
        if ([uuid isKindOfClass:[NSString class]] && uuid.length) {
            [self setValue:uuid forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNFetchUUIDMetadataCompletionBlock block))performWithCompletion {
    return ^(PNFetchUUIDMetadataCompletionBlock block) {
        [super performWithBlock:block];
    };
}

#pragma mark -


@end
