#import "PNPresenceChannelHereNowResult+Private.h"
#import "PNPresenceHereNowFetchData+Private.h"
#import "PNOperationResult+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// Channel presence response private extension.
@interface PNPresenceChannelHereNowData ()


#pragma mark - Properties

/// Channels presence information.
@property(strong, nonatomic, readonly) PNPresenceHereNowFetchData *presenceData;


#pragma mark - Initialization and Configuration

/// Initialize channel presence response object.
///
/// - Parameter presenceData: Channels presence information.
/// - Returns: Initialized channel presence response object.
- (instancetype)initWithPresenceData:(PNPresenceHereNowFetchData *)presenceData;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark Interface implementation

@implementation PNPresenceChannelHereNowData


#pragma mark - Properties

+ (NSArray<NSString *> *)ignoredKeys {
    return @[@"presenceData"];
}

- (id)uuids {
    PNPresenceChannelData *channel = self.presenceData.channels.allValues.firstObject;
    PNHereNowVerbosityLevel level = channel.verbosityLevel;

    if (level == PNHereNowUUID) return [channel.uuids valueForKey:@"uuid"];
    return [channel.uuids valueForKey:@"dictionaryRepresentation"];
}

- (NSDictionary<NSString *,NSDictionary *> *)channels {
    NSMutableDictionary *channels = [NSMutableDictionary dictionaryWithCapacity:self.presenceData.channels.count];
    [self.presenceData.channels enumerateKeysAndObjectsUsingBlock:^(NSString *channel,
                                                                    PNPresenceChannelData *data,
                                                                    __unused BOOL * stop) {
        channels[channel] = [data dictionaryRepresentation];
    }];

    return channels;
}

- (NSNumber *)totalOccupancy {
    return self.presenceData.totalOccupancy;
}

- (NSNumber *)occupancy {
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

@implementation PNPresenceChannelHereNowResult


#pragma mark - Initialization and Configuration

+ (instancetype)legacyPresenceFromPresence:(PNPresenceHereNowResult *)presence {
    return [self objectWithOperation:presence.operation
                            response:[[PNPresenceChannelHereNowData alloc] initWithPresenceData:presence.responseData]];
}


#pragma mark - Properties

- (PNPresenceChannelHereNowData *)data {
    return self.responseData;
}

#pragma mark -


@end
