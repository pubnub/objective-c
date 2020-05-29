/**
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNBaseObjectsMembershipRequest+Private.h"
#import "PNBaseObjectsRequest+Private.h"
#import "PNRemoveMembershipsRequest.h"
#import "PNRequest+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNRemoveMembershipsRequest ()


#pragma mark - Initialization & Configuration

/**
 * @brief Initialize \c remove \c UUID's memberships request.
 *
 * @param uuid Identifier for which memberships information should be removed.
 *   Will be set to current \b PubNub configuration \c uuid if \a nil is set.
 * @param channels List of \c channels from which \c UUID should be removed as \c member.
 *
 * @return Initialized and ready to use \c remove \c UUID's memberships request.
 */
- (instancetype)initWithUUID:(nullable NSString *)uuid channels:(NSArray<NSString *> *)channels;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNRemoveMembershipsRequest


#pragma mark - Information

@dynamic includeFields;


- (PNOperationType)operation {
    return PNRemoveMembershipsOperation;
}


#pragma mark - Initialization & Configuration

+ (instancetype)requestWithUUID:(NSString *)uuid channels:(NSArray<NSString *> *)channels {
    return [[self alloc] initWithUUID:uuid channels:channels];
}

- (instancetype)initWithUUID:(NSString *)uuid channels:(NSArray<NSString *> *)channels {
    if ((self = [super initWithObject:@"UUID" identifier:uuid])) {
        [self removeRelationToObjects:channels ofType:@"channel"];
    }
    
    return self;
}

- (instancetype)init {
    [self throwUnavailableInitInterface];
    
    return nil;
}

#pragma mark -


@end
