#import "PNManageMembershipsRequest.h"
#import "PNBaseObjectsMembershipRequest+Private.h"
#import "PNBaseObjectsRequest+Private.h"
#import "PNBaseRequest+Private.h"
#import "PNTransportRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Manage UUID's memberships` request private extension.
@interface PNManageMembershipsRequest ()


#pragma mark - Initialization and Configuration

/// Initialize `Manage UUID's memberships` request.
 ///
 /// - Parameter uuid: Identifier for which memberships should be managed. Will be set to current **PubNub**
 /// configuration `uuid` if `nil` is set.
/// - Returns: Initialized `manage UUID's memberships` request.
- (instancetype)initWithUUID:(nullable NSString *)uuid;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNManageMembershipsRequest


#pragma mark - Properties

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


#pragma mark - Initialization and Configuration

+ (instancetype)requestWithUUID:(NSString *)uuid {
    return [[self alloc] initWithUUID:uuid];
}

- (instancetype)initWithUUID:(NSString *)uuid {
    if ((self = [super initWithObject:@"UUID" identifier:uuid])) {
        self.includeFields |= PNMembershipsTotalCountField|PNMembershipStatusField|PNMembershipTypeField;
    }
    
    return self;
}

- (instancetype)init {
    [self throwUnavailableInitInterface];
    
    return nil;
}

#pragma mark -


@end
