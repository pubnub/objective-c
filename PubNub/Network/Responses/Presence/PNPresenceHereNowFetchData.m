#import "PNPresenceHereNowFetchData+Private.h"
#import <PubNub/PNJSONDecoder.h>
#import <PubNub/PNStructures.h>
#import <PubNub/PNCodable.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// User presence information private extension.
@interface PNPresenceUUIDData () <PNCodable>


#pragma mark - Properties

/// Presence information details level.
@property(assign, nonatomic) PNHereNowVerbosityLevel verbosityLevel;

/// State which has been associated with user while he is active in specific channel.
@property(strong, nonatomic, nullable) id state;

/// Unique user identifier.
@property(strong, nonatomic) NSString *uuid;


#pragma mark - Initialization and Configuration

/// Initialize user presence information object.
///
/// - Parameters:
///   - uuid: Unique user identifier.
///   - state: State associated with user at channel.
/// - Returns: Initialized user presence information object.
- (instancetype)initWithUUID:(NSString *)uuid state:(nullable id)state;


#pragma mark - Helpers

/// Represent presence information as dictionary.
///
/// - Returns: Dictionary representation which depends from presence information details level.
- (NSDictionary *)dictionaryRepresentation;

#pragma mark -


@end


#pragma mark - Private interface declaration

/// Channel presence information private extension.
@interface PNPresenceChannelData () <PNCodable>


#pragma mark - Properties

/// List of active users.
@property(strong, nonatomic, nullable) NSArray<PNPresenceUUIDData *> *uuids;

/// Presence information details level.
@property(assign, nonatomic) PNHereNowVerbosityLevel verbosityLevel;

/// Number of active users in channel.
@property(strong, nonatomic) NSNumber *occupancy;


#pragma mark - Initialization and Configuration

/// Initialize channel presence information object.
///
/// - Parameters:
///   - uuids: Active channel users presence information.
///   - occupancy: Number of active users.
/// - Returns: Initialized channel presence information object.
- (instancetype)initWithUsers:(nullable NSArray<PNPresenceUUIDData *> *)uuids occupancy:(NSNumber *)occupancy;

#pragma mark -


@end


#pragma mark - Private interface declaration

/// Here now presence request response private extension.
@interface PNPresenceHereNowFetchData () <PNCodable>


#pragma mark - Properties

/// Active channels list.
///
/// Each dictionary key represent channel name and it's value is presence information for it.
@property(strong, nonatomic) NSDictionary<NSString *, PNPresenceChannelData *> *channels;

/// Presence information details level.
@property(assign, nonatomic) PNHereNowVerbosityLevel verbosityLevel;

/// Total number of subscribers.
@property(strong, nonatomic) NSNumber *totalOccupancy;

/// Total number of active channels.
@property(strong, nonatomic) NSNumber *totalChannels;


#pragma mark - Initialization and Configuration

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNPresenceUUIDData


#pragma mark - Properties

+ (NSArray<NSString *> *)ignoredKeys {
    return @[@"verbosityLevel"];
}


#pragma mark - Initialization and Configuration

- (instancetype)initWithUUID:(NSString *)uuid state:(id)state {
    if ((self = [super init])) {
        _verbosityLevel = PNHereNowUUID;
        _uuid = [uuid copy];
        _state = state;
    }

    return self;
}

- (instancetype)initObjectWithCoder:(id<PNDecoder>)coder {
    NSDictionary *responseWithState = [coder decodeObjectOfClass:[NSDictionary class]];
    PNHereNowVerbosityLevel level = PNHereNowUUID;
    NSString *uuid;
    id state;

    if (responseWithState) {
        state = responseWithState[@"state"];
        uuid = responseWithState[@"uuid"];
        level = PNHereNowState;
    } else uuid = [coder decodeObjectOfClass:[NSString class]];

    if (!uuid) return nil;

    PNPresenceUUIDData *data = [self initWithUUID:uuid state:state];
    data.verbosityLevel = level;

    return data;
}


#pragma mark - Helpers

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [@{ @"uuid": self.uuid ?: @"not set" } mutableCopy];
    if (self.state) dictionary[@"state"] = self.state;

    return dictionary;
}

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNPresenceChannelData


#pragma mark - Properties

+ (NSArray<NSString *> *)ignoredKeys {
    return @[@"verbosityLevel"];
}


#pragma mark - Initialization and Configuration

- (instancetype)initWithUsers:(nullable NSArray<PNPresenceUUIDData *> *)uuids occupancy:(NSNumber *)occupancy {
    if ((self = [super init])) {
        _uuids = uuids.count ? uuids : nil;
        _occupancy = occupancy;
    }

    return self;
}

- (instancetype)initObjectWithCoder:(id<PNDecoder>)coder {
    __block NSMutableArray<PNPresenceUUIDData *> *usersPresence = [NSMutableArray new];
    NSDictionary *response = [coder decodeObjectOfClass:[NSDictionary class]];
    __block PNHereNowVerbosityLevel level = PNHereNowOccupancy;
    NSNumber *occupancy = response[@"occupancy"];

    if (response[@"uuids"]) {
        NSArray *array = response[@"uuids"];
        if (![array isKindOfClass:[NSArray class]]) return nil;

        [array enumerateObjectsUsingBlock:^(id data, __unused NSUInteger idx, BOOL *stop) {
            PNPresenceUUIDData *userPresence = [PNJSONDecoder decodedObjectOfClass:[PNPresenceUUIDData class]
                                                                    fromDictionary:data
                                                                         withError:nil];

            if (userPresence) {
                [usersPresence addObject:userPresence];
                level = userPresence.verbosityLevel;
            } else usersPresence = nil;
            *stop = usersPresence == nil;
        }];
    }

    if (!usersPresence) return nil;

    PNPresenceChannelData *channelPresence = [self initWithUsers:usersPresence occupancy:occupancy];
    channelPresence.verbosityLevel = level;

    return channelPresence;
}


#pragma mark - Helpers

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [@{ @"occupancy": self.occupancy ?: @"not set" } mutableCopy];

    if (self.uuids.count) {
        if (self.verbosityLevel == PNHereNowUUID) dictionary[@"uuids"] = [self.uuids valueForKey:@"uuid"];
        else dictionary[@"uuids"] = [self.uuids valueForKey:@"dictionaryRepresentation"];
    }

    return dictionary;
}

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNPresenceHereNowFetchData


#pragma mark - Properties

+ (NSArray<NSString *> *)ignoredKeys {
    return @[@"verbosityLevel"];
}


#pragma mark - Initialization and Configuration

- (instancetype)initWithChannels:(NSDictionary<NSString *, PNPresenceChannelData *> *)channels totalOccupancy:(NSNumber *)totalOccupancy totalChannels:(NSNumber *)totalChannels {
    if ((self = [super init])) {
        _channels = channels.count ? channels : nil;
        _totalOccupancy = totalOccupancy;
        _totalChannels = totalChannels;
    }

    return self;
}

- (instancetype)initObjectWithCoder:(id<PNDecoder>)coder {
    NSDictionary *response = [coder decodeObjectOfClass:[NSDictionary class]];
    if (!response) return nil;

    __block NSMutableDictionary<NSString *, PNPresenceChannelData *> *channelsPresence = [NSMutableDictionary new];
    __block PNHereNowVerbosityLevel level = PNHereNowOccupancy;
    NSArray<NSString *> *keys = [coder keys];
    NSNumber *totalOccupancy;
    NSNumber *totalChannels;

    if ([keys containsObject:@"payload"]) {
        NSDictionary *dictionary = response[@"payload"];
        if (![dictionary isKindOfClass:[NSDictionary class]] || !dictionary[@"channels"]) return nil;

        NSDictionary *channels = dictionary[@"channels"];
        totalOccupancy = dictionary[@"total_occupancy"];
        totalChannels = dictionary[@"total_channels"];

        if (![channels isKindOfClass:[NSDictionary class]]) return nil;

        [channels enumerateKeysAndObjectsUsingBlock:^(NSString *channel, NSDictionary *data, BOOL *stop) {
            PNPresenceChannelData *channelPresence = [PNJSONDecoder decodedObjectOfClass:[PNPresenceChannelData class]
                                                                          fromDictionary:data 
                                                                               withError:nil];
            if (channelPresence) {
                channelsPresence[channel] = channelPresence;
                level = channelPresence.verbosityLevel;
            } else channelsPresence = nil;
            *stop = channelsPresence == nil;
        }];
    } else if ([keys containsObject:@"uuids"] || [keys containsObject:@"occupancy"]) {
        PNPresenceChannelData *channelPresence = [PNJSONDecoder decodedObjectOfClass:[PNPresenceChannelData class]
                                                                      fromDictionary:response
                                                                           withError:nil];
        if (channelPresence){
            totalOccupancy = channelPresence.occupancy;
            channelsPresence[@""] = channelPresence;
            totalChannels = @1;
        } else channelsPresence = nil;
    }

    if (!channelsPresence) return nil;
    
    PNPresenceHereNowFetchData *presence = [self initWithChannels:channelsPresence
                                              totalOccupancy:totalOccupancy
                                               totalChannels:totalChannels];
    presence.verbosityLevel = level;

    return presence;
}


#pragma mark - Helpers

- (void)setPresenceChannel:(NSString *)channelName {
    if (self.channels[@""]) self.channels = @{ channelName: self.channels[@""] };
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [@{
        @"totalOccupancy": self.totalOccupancy ?: @"not set", @"totalChannels": self.totalChannels ?: @"not set"
    } mutableCopy];

    if (self.channels.count) {
        NSMutableDictionary *channels = [NSMutableDictionary dictionaryWithCapacity:self.channels.count];
        [self.channels enumerateKeysAndObjectsUsingBlock:^(NSString *channel, PNPresenceChannelData *data, BOOL *stop) {
            channels[channel] = [data dictionaryRepresentation];
        }];
        dictionary[@"channels"] = channels;
    }

    return dictionary;
}

#pragma mark -


@end
