/**
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNBaseObjectsMembershipRequest+Private.h"
#import "PNBaseObjectsRequest+Private.h"
#import "PNManageMembershipsRequest.h"
#import "PNRequest+Private.h"


#pragma mark Interface implementation

@implementation PNManageMembershipsRequest


#pragma mark - Information

@dynamic includeFields;


- (PNOperationType)operation {
    return PNManageMembershipsOperation;
}

- (void)setSetChannels:(NSArray<NSDictionary *> *)setChannels {
    _setChannels = setChannels;
    
    [self setRelationToObjects:setChannels ofType:@"channel"];
}

- (void)setRemoveChannels:(NSArray<NSString *> *)removeChannels {
    _removeChannels = removeChannels;
    
    [self removeRelationToObjects:removeChannels ofType:@"channel"];
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
