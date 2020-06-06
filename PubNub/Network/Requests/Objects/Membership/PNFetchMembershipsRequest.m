/**
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNBaseObjectsRequest+Private.h"
#import "PNFetchMembershipsRequest.h"
#import "PNRequest+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNFetchMembershipsRequest ()


#pragma mark - Initialization & Configuration

/**
 * @brief Initialize \c fetch \c UUID's memberships request.
 *
 * @param uuid Identifier for which memberships in \c channels should be fetched.
 * Will be set to current \b PubNub configuration \c uuid if \a nil is set.
 *
 * @return Initialized and ready to use \c fetch \c UUID's memberships request.
 */
- (instancetype)initWithUUID:(nullable NSString *)uuid;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNFetchMembershipsRequest


#pragma mark - Information

@dynamic includeFields;


- (PNOperationType)operation {
    return PNFetchMembershipsOperation;
}


#pragma mark - Initialization & Configuration

+ (instancetype)requestWithUUID:(NSString *)uuid {
    return [[self alloc] initWithUUID:uuid];
}

- (instancetype)initWithUUID:(NSString *)uuid {
    if ((self = [super initWithObject:@"UUID" identifier:uuid])) {
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
