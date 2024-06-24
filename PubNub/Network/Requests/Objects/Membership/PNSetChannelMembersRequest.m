#import "PNSetChannelMembersRequest.h"
#import "PNBaseObjectsMembershipRequest+Private.h"
#import "PNBaseObjectsRequest+Private.h"
#import "PNBaseRequest+Private.h"
#import "PNTransportRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Set channel's members` request private extension.
@interface PNSetChannelMembersRequest ()


#pragma mark - Initialization and Configuration

/// Initialize `Set channel's members` request.
///
///Request will set `UUID's metadata` associated with it in context of `channel`.
///
/// - Parameters:
///   - channel: Name of channel for which members `metadata` should be set.
///   - uuids: List of `UUIDs` for which `metadata` associated with each of them in context of `channel` should be set.
///   Each entry is dictionary with `uuid` and **optional** `custom` fields. `custom` should be dictionary with simple
///   objects: `NSString` and `NSNumber`.
/// - Returns: Initialized `set channel's members` request.
- (instancetype)initWithChannel:(NSString *)channel uuids:(NSArray<NSDictionary *> *)uuids;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNSetChannelMembersRequest


#pragma mark - Properties

@dynamic includeFields;


- (PNOperationType)operation {
    return PNSetChannelMembersOperation;
}


#pragma mark - Initialization and Configuration

+ (instancetype)requestWithChannel:(NSString *)channel uuids:(NSArray<NSDictionary *> *)uuids {
    return [[self alloc] initWithChannel:channel uuids:uuids];
}

- (instancetype)initWithChannel:(NSString *)channel uuids:(NSArray<NSDictionary *> *)uuids {
    if ((self = [super initWithObject:@"Channel" identifier:channel])) {
        self.includeFields = PNChannelMembersTotalCountField;
        [self setRelationToObjects:uuids ofType:@"uuid"];
    }
    
    return self;
}

- (instancetype)init {
    [self throwUnavailableInitInterface];
    
    return nil;
}

#pragma mark -


@end
