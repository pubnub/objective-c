#import "PNRemoveChannelMembersRequest.h"
#import "PNBaseObjectsMembershipRequest+Private.h"
#import "PNBaseObjectsRequest+Private.h"
#import "PNBaseRequest+Private.h"
#import "PNTransportRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Remove channel's members` request private extension.
@interface PNRemoveChannelMembersRequest ()


#pragma mark - Initialization and Configuration

/// Initialize `Remove channel's members` request.
///
/// - Parameters:
///   - channel: Name of channel from which members should be removed.
///   - uuids: List of `UUIDs` which should be removed from `channel's` list.
/// - Returns: Initialized `remove channel's members` request.
- (instancetype)initWithChannel:(NSString *)channel uuids:(NSArray<NSString *> *)uuids;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNRemoveChannelMembersRequest


#pragma mark - Properties

@dynamic includeFields;


- (PNOperationType)operation {
    return PNRemoveChannelMembersOperation;
}


#pragma mark - Initialization and Configuration

+ (instancetype)requestWithChannel:(NSString *)channel uuids:(NSArray<NSString *> *)uuids {
    return [[self alloc] initWithChannel:channel uuids:uuids];
}

- (instancetype)initWithChannel:(NSString *)channel uuids:(NSArray<NSString *> *)uuids {
    if ((self = [super initWithObject:@"Channel" identifier:channel])) {
        self.includeFields = PNChannelMembersTotalCountField;
        [self removeRelationToObjects:uuids ofType:@"uuid"];
    }
    
    return self;
}

- (instancetype)init {
    [self throwUnavailableInitInterface];
    
    return nil;
}

#pragma mark -


@end
