#import "PNRemoveMembershipsRequest.h"
#import "PNBaseObjectsMembershipRequest+Private.h"
#import "PNBaseObjectsRequest+Private.h"
#import "PNBaseRequest+Private.h"
#import "PNTransportRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Remove UUID's memberships` request private extension.
@interface PNRemoveMembershipsRequest ()


#pragma mark - Initialization and Configuration

/// Initialize `Remove UUID's memberships` request.
///
/// - Parameters:
///   - uuid: Identifier for which memberships information should be removed.  Will be set to current **PubNub**
///   configuration `uuid` if `nil` is set.
///   - channels: List of`channels` from which `UUID` should be removed as `member`.
/// - Returns: Initialized `remove UUID's memberships` request.
- (instancetype)initWithUUID:(nullable NSString *)uuid channels:(NSArray<NSString *> *)channels;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNRemoveMembershipsRequest


#pragma mark - Properties

@dynamic includeFields;


- (PNOperationType)operation {
    return PNRemoveMembershipsOperation;
}


#pragma mark - Initialization and Configuration

+ (instancetype)requestWithUUID:(NSString *)uuid channels:(NSArray<NSString *> *)channels {
    return [[self alloc] initWithUUID:uuid channels:channels];
}

- (instancetype)initWithUUID:(NSString *)uuid channels:(NSArray<NSString *> *)channels {
    if ((self = [super initWithObject:@"UUID" identifier:uuid])) {
        [self removeRelationToObjects:channels ofType:@"channel"];
        self.includeFields = PNMembershipsTotalCountField;
    }
    
    return self;
}

- (instancetype)init {
    [self throwUnavailableInitInterface];
    
    return nil;
}

#pragma mark -


@end
