/**
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNBaseObjectsMembershipRequest+Private.h"
#import "PNBaseObjectsRequest+Private.h"
#import "PNSetMembersRequest.h"
#import "PNRequest+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNSetMembersRequest ()


#pragma mark - Initialization & Configuration

/**
 * @brief Initialize \c set \c channel's members request.
 *
 * @discussion Request will set \c UUID's \c metadata associated with it in context of \c channel.
 *
 * @param channel Name of channel for which members should be added.
 * @param uuids List of \c UUIDs for which \c metadata associated with each of them in context of
 *     \c channel should be set.
 *     Each entry is dictionary with \c channel and \b optional \c custom fields. \c custom should
 *     be dictionary with simple objects: \a NSString and \a NSNumber.
 *
 * @return Initialized and ready to use \c set \c channel's members request.
 */
- (instancetype)initWithChannel:(NSString *)channel uuids:(NSArray<NSString *> *)uuids;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNSetMembersRequest


#pragma mark - Information

@dynamic includeFields;


- (PNOperationType)operation {
    return PNSetMembersOperation;
}


#pragma mark - Initialization & Configuration

+ (instancetype)requestWithChannel:(NSString *)channel uuids:(NSArray<NSDictionary *> *)uuids {
    return [[self alloc] initWithChannel:channel uuids:uuids];
}

- (instancetype)initWithChannel:(NSString *)channel uuids:(NSArray<NSDictionary *> *)uuids {
    if ((self = [super initWithObject:@"Channel" identifier:channel])) {
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
