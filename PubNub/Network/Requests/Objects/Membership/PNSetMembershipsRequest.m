#import "PNSetMembershipsRequest.h"
#import "PNBaseObjectsMembershipRequest+Private.h"
#import "PNBaseObjectsRequest+Private.h"
#import "PNBaseRequest+Private.h"
#import "PNTransportRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Set UUID's memberships` request private extension.
@interface PNSetMembershipsRequest ()


#pragma mark - Initialization and Configuration

/// Initialize `Set UUID's memberships` request.
///
/// Request will set \c UUID's \c metadata associated with membership.
///
/// - Parameters:
///   - uuid: Identifier for which memberships `metadata` should be set. Will be set to current **PubNub** configuration
///   `uuid` if `nil` is set.
///   - channels: List of `channels` for which `metadata` associated with `UUID` should be set. Each entry is dictionary
///   with `channel` and **optional** `custom` fields. `custom` should be dictionary with simple objects: `NSString` and
///   `NSNumber`
/// - Returns: Initialized `set UUID's memberships` request.
- (instancetype)initWithUUID:(nullable NSString *)uuid channels:(NSArray<NSDictionary *> *)channels;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNSetMembershipsRequest


#pragma mark - Properties

@dynamic includeFields;


- (PNOperationType)operation {
    return PNSetMembershipsOperation;
}


#pragma mark - Initialization & Configuration

+ (instancetype)requestWithUUID:(NSString *)uuid channels:(NSArray<NSDictionary *> *)channels {
    return [[self alloc] initWithUUID:uuid channels:channels];
}

- (instancetype)initWithUUID:(NSString *)uuid channels:(NSArray<NSDictionary *> *)channels {
    if ((self = [super initWithObject:@"UUID" identifier:uuid])) {
        [self setRelationToObjects:channels ofType:@"channel"];
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
