#import "PNFetchMembershipsRequest.h"
#import "PNBaseObjectsRequest+Private.h"
#import "PNBaseRequest+Private.h"
#import "PNTransportRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

/// `Fetch UUID memberships` request private extension.
@interface PNFetchMembershipsRequest ()


#pragma mark - Initialization and Configuration

///Initialize `Fetch UUID's memberships` request.
///
/// - Parameter uuid: Identifier for which memberships in `channels` should be fetched. Will be set to current
/// **PubNub** configuration `uuid` if `nil` is set.
/// - Returns: Initialized `fetch UUID's memberships` request.
- (instancetype)initWithUUID:(nullable NSString *)uuid;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNFetchMembershipsRequest


#pragma mark - Properties

@dynamic includeFields;


- (PNOperationType)operation {
    return PNFetchMembershipsOperation;
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
