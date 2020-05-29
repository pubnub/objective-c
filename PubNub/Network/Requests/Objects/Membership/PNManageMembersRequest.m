/**
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNBaseObjectsMembershipRequest+Private.h"
#import "PNBaseObjectsRequest+Private.h"
#import "PNManageMembersRequest.h"
#import "PNRequest+Private.h"


#pragma mark Interface implementation

@implementation PNManageMembersRequest


#pragma mark - Information

@dynamic includeFields;


- (PNOperationType)operation {
    return PNManageMembersOperation;
}

- (void)setSetMembers:(NSArray<NSDictionary *> *)setMembers {
    _setMembers = setMembers;

    [self setRelationToObjects:setMembers ofType:@"uuid"];
}

- (void)setRemoveMembers:(NSArray<NSString *> *)removeMembers {
    _removeMembers = removeMembers;
    
    [self removeRelationToObjects:removeMembers ofType:@"uuid"];
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
