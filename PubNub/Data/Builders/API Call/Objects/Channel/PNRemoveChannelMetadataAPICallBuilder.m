/**
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNRemoveChannelMetadataAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNRemoveChannelMetadataAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Execution

- (void(^)(PNRemoveChannelMetadataCompletionBlock block))performWithCompletion {
    return ^(PNRemoveChannelMetadataCompletionBlock block) {
        [super performWithBlock:block];
    };
}

#pragma mark -


@end
