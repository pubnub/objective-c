/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNBaseObjectsRequest+Private.h"
#import "PNFetchMembershipsRequest.h"
#import "PNRequest+Private.h"
#import "PNErrorCodes.h"


#pragma mark Interface implementation

@implementation PNFetchMembershipsRequest


#pragma mark - Information

@dynamic includeFields;


- (PNOperationType)operation {
    return PNFetchMembershipsOperation;
}


#pragma mark - Initialization & Configuration

+ (instancetype)requestWithUserID:(NSString *)identifier {
    return [[self alloc] initWithObject:@"User" identifier:identifier];
}

- (instancetype)init {
    [self throwUnavailableInitInterface];
    
    return nil;
}

#pragma mark -


@end
