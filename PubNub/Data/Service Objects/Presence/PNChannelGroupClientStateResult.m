#import "PNChannelGroupClientStateResult+Private.h"
#import "PNOperationResult+Private.h"
#import "PNServiceData+Private.h"



#pragma mark - Private interface declaration

/// `Fetch user presence state for channel group` request processing result .
@interface PNChannelGroupClientStateData ()


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


#pragma mark - Interface implementation

@implementation PNChannelGroupClientStateData


#pragma mark - Properties

- (NSDictionary<NSString *, NSDictionary *> *)channels {
    return self.presenceData.channels;
}


#pragma mark - Initialization and Configuration

- (instancetype)initWithPresenceData:(PNPresenceUserStateFetchData *)presenceData {
    if ((self = [super init])) _presenceData = presenceData;
    return self;
}

#pragma mark -


@end

#pragma mark - Interface implementation

@implementation PNChannelGroupClientStateResult


#pragma mark - Initialization and Configuration

+ (instancetype)legacyPresenceFromPresence:(PNPresenceStateFetchResult *)presence {
    return [self objectWithOperation:PNStateForChannelGroupOperation
                            response:[[PNChannelGroupClientStateData alloc] initWithPresenceData:presence.responseData]];
}


#pragma mark - Information

- (PNChannelGroupClientStateData *)data {
    return self.responseData;
}

#pragma mark -


@end
