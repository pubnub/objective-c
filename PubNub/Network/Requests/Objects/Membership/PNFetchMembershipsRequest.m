/**
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNBaseObjectsRequest+Private.h"
#import "PNFetchMembershipsRequest.h"
#import "PNRequest+Private.h"


#pragma mark Interface implementation

@implementation PNFetchMembershipsRequest


#pragma mark - Information

@dynamic includeFields;


- (PNOperationType)operation {
    return PNFetchMembershipsOperation;
}


#pragma mark - Initialization & Configuration

+ (instancetype)requestWithUUID:(NSString *)uuid {
    return [[self alloc] initWithObject:@"UUID" identifier:uuid];
}

- (instancetype)init {
    [self throwUnavailableInitInterface];
    
    return nil;
}

#pragma mark -


@end
