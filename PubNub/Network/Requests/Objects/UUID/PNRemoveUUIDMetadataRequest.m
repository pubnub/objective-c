/**
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNBaseObjectsRequest+Private.h"
#import "PNRemoveUUIDMetadataRequest.h"
#import "PNRequest+Private.h"


#pragma mark Interface implementation

@implementation PNRemoveUUIDMetadataRequest


#pragma mark - Information

- (PNOperationType)operation {
    return PNRemoveUUIDMetadataOperation;
}

- (NSString *)httpMethod {
    return @"DELETE";
}


#pragma mark - Initialization & Configuration

+ (instancetype)new {
    return [self requestWithUUID:nil];
}

+ (instancetype)requestWithUUID:(NSString *)uuid {
    return [[self alloc] initWithObject:@"UUID" identifier:uuid];
}

- (instancetype)init {
    [self throwUnavailableInitInterface];

    return nil;
}

#pragma mark -


@end
