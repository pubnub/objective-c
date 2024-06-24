#import "PNManageChannelMembersRequest.h"
#import "PNBaseObjectsMembershipRequest+Private.h"
#import "PNBaseObjectsRequest+Private.h"
#import "PNBaseRequest+Private.h"
#import "PNTransportRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Manage channel's memebers` request private extension.
@interface PNManageChannelMembersRequest ()


#pragma mark - Initialization and Configuration

/// Initialize `Manage channel's members` request.
///
/// - Parameter channel: Name of channel for which members list should be updated.
/// - Returns: Initialized `manage channel's members` request.
- (instancetype)initWithChannel:(NSString *)channel;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNManageChannelMembersRequest


#pragma mark - Properties

@dynamic includeFields;


- (PNOperationType)operation {
    return PNManageChannelMembersOperation;
}

- (void)setSetMembers:(NSArray<NSDictionary *> *)setMembers {
    _setMembers = setMembers;
    [self setRelationToObjects:setMembers ofType:@"uuid"];
}

- (void)setRemoveMembers:(NSArray<NSString *> *)removeMembers {
    _removeMembers = removeMembers;
    [self removeRelationToObjects:removeMembers ofType:@"uuid"];
}


#pragma mark - Initialization and Configuration

+ (instancetype)requestWithChannel:(NSString *)channel {
    return [[self alloc] initWithChannel:channel];
}

- (instancetype)initWithChannel:(NSString *)channel {
    if ((self = [super initWithObject:@"Channel" identifier:channel])) {
        self.includeFields = PNChannelMembersTotalCountField;
    }
    
    return self;
}

- (instancetype)init {
    [self throwUnavailableInitInterface];
    
    return nil;
}

#pragma mark -


@end
