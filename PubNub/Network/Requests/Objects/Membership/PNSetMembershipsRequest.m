/**
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNBaseObjectsMembershipRequest+Private.h"
#import "PNBaseObjectsRequest+Private.h"
#import "PNSetMembershipsRequest.h"
#import "PNRequest+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNSetMembershipsRequest ()


#pragma mark - Initialization & Configuration

/**
 * @brief Initialize \c set \c UUID's memberships request.
 *
 * @discussion Request will set \c UUID's \c metadata associated with membership.
 *
 * @param uuid Identifier for which memberships information should be managed.
 *     Will be set to current \b PubNub configuration \c uuid if \a nil is set.
 * @param channels List of \c channels for which \c metadata associated with \c UUID should be set.
 *     Each entry is dictionary with \c channel and \b optional \c custom fields. \c custom should
 *     be dictionary with simple objects: \a NSString and \a NSNumber.
 *
 * @return Initialized and ready to use \c set \c UUID's memberships request.
 */
- (instancetype)initWithUUID:(nullable NSString *)uuid channels:(NSArray<NSDictionary *> *)channels;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNSetMembershipsRequest


#pragma mark - Information

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
