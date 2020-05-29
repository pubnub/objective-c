/**
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNRemoveUUIDMetadataAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNRemoveUUIDMetadataAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNRemoveUUIDMetadataAPICallBuilder * (^)(NSString *uuid))uuid {
    return ^PNRemoveUUIDMetadataAPICallBuilder * (NSString *uuid) {
        if ([uuid isKindOfClass:[NSString class]] && uuid.length) {
            [self setValue:uuid forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNRemoveUUIDMetadataCompletionBlock block))performWithCompletion {
    return ^(PNRemoveUUIDMetadataCompletionBlock block) {
        [super performWithBlock:block];
    };
}

#pragma mark -


@end
