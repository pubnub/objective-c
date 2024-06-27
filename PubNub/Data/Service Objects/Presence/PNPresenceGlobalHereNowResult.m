#import "PNPresenceGlobalHereNowResult+Private.h"
#import "PNPresenceHereNowFetchData+Private.h"
#import "PNOperationResult+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// Global presence response private extension.
@interface PNPresenceGlobalHereNowData ()


#pragma mark - Properties

/// Channels presence information.
@property(strong, nonatomic, readonly) PNPresenceHereNowFetchData *presenceData;


#pragma mark - Initialization and Configuration

/// Initialize global presence response object.
///
/// - Parameter presenceData: Channels presence information.
/// - Returns: Initialized global presence response object.
- (instancetype)initWithPresenceData:(PNPresenceHereNowFetchData *)presenceData;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNPresenceGlobalHereNowData


#pragma mark - Properties

+ (NSArray<NSString *> *)ignoredKeys {
    return @[@"presenceData"];
}

- (NSDictionary<NSString *, NSDictionary *> *)channels {
    NSMutableDictionary *channels = [NSMutableDictionary dictionaryWithCapacity:self.presenceData.channels.count];
    [self.presenceData.channels enumerateKeysAndObjectsUsingBlock:^(NSString *channel,
                                                                    PNPresenceChannelData *data,
                                                                    __unused BOOL * stop) {
        channels[channel] = [data dictionaryRepresentation];
    }];

    return channels;
}

- (NSNumber *)totalChannels {
    return self.presenceData.totalChannels;
}

- (NSNumber *)totalOccupancy {
    return self.presenceData.totalOccupancy;
}


#pragma mark - Initialization and Condiguration

- (instancetype)initWithPresenceData:(PNPresenceHereNowFetchData *)presenceData {
    if ((self = [super init])) _presenceData = presenceData;
    return self;
}

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNPresenceGlobalHereNowResult


#pragma mark - Initialization and Configuration

+ (instancetype)legacyPresenceFromPresence:(PNPresenceHereNowResult *)presence {
    return [self objectWithOperation:presence.operation
                            response:[[PNPresenceGlobalHereNowData alloc] initWithPresenceData:presence.responseData]];
}


#pragma mark - Properties

- (PNPresenceGlobalHereNowData *)data {
    return self.responseData;
}

#pragma mark -


@end
