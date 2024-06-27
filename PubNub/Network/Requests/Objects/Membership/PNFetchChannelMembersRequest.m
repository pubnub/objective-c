#import "PNFetchChannelMembersRequest.h"
#import "PNBaseObjectsRequest+Private.h"
#import "PNBaseRequest+Private.h"
#import "PNTransportRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Fetch channel's members` request private extension.
@interface PNFetchChannelMembersRequest ()


#pragma mark - Initialization and Configuration

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


#pragma mark - Properties

@dynamic includeFields;


- (PNOperationType)operation {
    return PNFetchChannelMembersOperation;
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
