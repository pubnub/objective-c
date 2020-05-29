/**
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNFetchChannelMetadataAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNFetchChannelMetadataAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNFetchChannelMetadataAPICallBuilder * (^)(PNChannelFields includeFields))includeFields {
    return ^PNFetchChannelMetadataAPICallBuilder * (PNChannelFields includeFields) {
        [self setValue:@(includeFields) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNFetchChannelMetadataCompletionBlock block))performWithCompletion {
    return ^(PNFetchChannelMetadataCompletionBlock block) {
        [super performWithBlock:block];
    };
}

#pragma mark -


@end
