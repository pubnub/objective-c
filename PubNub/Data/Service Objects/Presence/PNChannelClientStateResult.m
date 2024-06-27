#import "PNChannelClientStateResult+Private.h"
#import "PNOperationResult+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `User presence state for channel` response.
@interface PNChannelClientStateData ()


#pragma mark - Properties

/// Channels presence information.
@property(strong, nonatomic, readonly) PNPresenceUserStateFetchData *presenceData;


#pragma mark - Initialization and Configuration

/// Initialize global presence response object.
///
/// - Parameter presenceData: Channels presence information.
/// - Returns: Initialized global presence response object.
- (instancetype)initWithPresenceData:(PNPresenceUserStateFetchData *)presenceData;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNChannelClientStateData


#pragma mark - Properties

- (NSDictionary<NSString *,id> *)state {
    return self.presenceData.state;
}


#pragma mark - Initialization and Configuration

- (instancetype)initWithPresenceData:(PNPresenceUserStateFetchData *)presenceData {
    if ((self = [super init])) _presenceData = presenceData;
    return self;
}

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNChannelClientStateResult


#pragma mark - Initialization and Configuration

+ (instancetype)legacyPresenceFromPresence:(PNPresenceStateFetchResult *)presence {
    return [self objectWithOperation:PNStateForChannelOperation
                            response:[[PNChannelClientStateData alloc] initWithPresenceData:presence.responseData]];
}


#pragma mark - Properties

- (PNChannelClientStateData *)data {
    return self.responseData;
}

#pragma mark -


@end
