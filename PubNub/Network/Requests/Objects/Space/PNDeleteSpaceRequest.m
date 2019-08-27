/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNBaseObjectsRequest+Private.h"
#import "PNDeleteSpaceRequest.h"
#import "PNRequest+Private.h"


#pragma mark Interface implementation

@implementation PNDeleteSpaceRequest


#pragma mark - Information

- (PNOperationType)operation {
    return PNDeleteSpaceOperation;
}

- (NSString *)httpMethod {
    return @"DELETE";
}


#pragma mark - Initialization & Configuration

+ (instancetype)requestWithSpaceID:(NSString *)identifier {
    return [[self alloc] initWithObject:@"Space" identifier:identifier];
}

- (instancetype)init {
    [self throwUnavailableInitInterface];

    return nil;
}

#pragma mark -


@end
