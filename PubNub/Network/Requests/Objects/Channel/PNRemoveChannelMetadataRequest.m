/**
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNBaseObjectsRequest+Private.h"
#import "PNRemoveChannelMetadataRequest.h"
#import "PNRequest+Private.h"


#pragma mark Interface implementation

@implementation PNRemoveChannelMetadataRequest


#pragma mark - Information

- (PNOperationType)operation {
    return PNRemoveChannelMetadataOperation;
}

- (NSString *)httpMethod {
    return @"DELETE";
}


#pragma mark - Initialization & Configuration

+ (instancetype)requestWithChannel:(NSString *)channel {
    return [[self alloc] initWithObject:@"Channel" identifier:channel];
}

- (instancetype)init {
    [self throwUnavailableInitInterface];

    return nil;
}

#pragma mark -


@end
