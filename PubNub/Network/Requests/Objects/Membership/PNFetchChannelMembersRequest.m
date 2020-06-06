/**
 * @author Serhii Mamontov
 * @version 4.14.1
 * @since 4.14.1
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNBaseObjectsRequest+Private.h"
#import "PNFetchChannelMembersRequest.h"
#import "PNRequest+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNFetchChannelMembersRequest ()


#pragma mark - Initialization & Configuration

/**
 * @brief Initialize \c fetch \c channel's members request.
 *
 * @param channel Name of channel for which members list should be fetched.
 *
 * @return Initialized and ready to use \c fetch \c channel's members request.
 */
- (instancetype)initWithChannel:(NSString *)channel;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNFetchChannelMembersRequest


#pragma mark - Information

@dynamic includeFields;


- (PNOperationType)operation {
    return PNFetchChannelMembersOperation;
}


#pragma mark - Initialization & Configuration

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
