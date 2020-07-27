/**
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNFileDownloadURLAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNFileDownloadURLAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Execution

- (void(^)(PNFileDownloadURLCompletionBlock block))performWithCompletion {
    return ^(PNFileDownloadURLCompletionBlock block) {
        [super performWithBlock:block];
    };
}

#pragma mark -


@end
