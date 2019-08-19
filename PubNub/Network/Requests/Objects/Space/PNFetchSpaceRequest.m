/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNBaseObjectsRequest+Private.h"
#import "PNFetchSpaceRequest.h"
#import "PNRequest+Private.h"


#pragma mark Interface implementation

@implementation PNFetchSpaceRequest


#pragma mark - Information

@dynamic includeFields;


- (PNOperationType)operation {
    return PNFetchSpaceOperation;
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
