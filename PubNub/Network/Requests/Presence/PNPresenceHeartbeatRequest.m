#import "PNPresenceHeartbeatRequest.h"
#import "PNBaseRequest+Private.h"
#import "PNFunctions.h"
#import "PNHelpers.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Heartbeat` request private extension.
@interface PNPresenceHeartbeatRequest ()


#pragma mark - Properties

/// List of channel group names from which client should try to unsubscribe.
@property(copy, nullable, nonatomic) NSArray<NSString *> *channelGroups;

/// List of channel names from which client should try to unsubscribe.
@property(copy, nullable, nonatomic) NSArray<NSString *> *channels;

/// User presence timeout interval.
@property(assign, nonatomic) NSInteger presenceHeartbeatValue;


#pragma mark - Initialization and Configuration

/// Initialize `Heartbeat` request.
///
/// - Parameters:
///   - heartbeat: User presence timeout interval. 
///   - channels: List of channel names for which user's presence should be announced.
///   - channelGroups: List of channel group names for which user's presence should be announced.
/// - Returns: Initialized `Heartbeat` request.
- (instancetype)initWithHeartbeat:(NSInteger)heartbeat
                         channels:(nullable NSArray<NSString *> *)channels
                    channelGroups:(nullable NSArray<NSString *> *)channelGroups;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNPresenceHeartbeatRequest


#pragma mark - Properties

- (PNOperationType)operation {
    return PNHeartbeatOperation;
}

- (NSDictionary *)query {
    NSMutableDictionary *query = [([super query] ?: @{}) mutableCopy];

    query[@"heartbeat"] = @(self.presenceHeartbeatValue).stringValue;
    NSString *state = [PNJSON JSONStringFrom:self.state withError:NULL];
    if (state.length > 0) query[@"state"] = state;

    if (self.channelGroups.count) query[@"channel-group"] = [self.channelGroups componentsJoinedByString:@","];

    return query;
}

- (NSString *)path {
    return PNStringFormat(@"/v2/presence/sub-key/%@/channel/%@/heartbeat",
                          self.subscribeKey,
                          [PNChannel namesForRequest:self.channels defaultString:@","]);
}


#pragma mark - Initialization and Configuration

+ (instancetype)requestWithHeartbeat:(NSInteger)heartbeat
                            channels:(NSArray<NSString *> *)channels
                       channelGroups:(NSArray<NSString *> *)channelGroups {
    return [[self alloc] initWithHeartbeat:heartbeat channels:channels channelGroups:channelGroups];
}

- (instancetype)initWithHeartbeat:(NSInteger)heartbeat
                         channels:(NSArray<NSString *> *)channels
                    channelGroups:(NSArray<NSString *> *)channelGroups {
    if ((self = [super init])) {
        _channelGroups = [channelGroups copy];
        _presenceHeartbeatValue = heartbeat;
        _channels = [channels copy];
    }

    return self;
}

- (instancetype)init {
    [self throwUnavailableInitInterface];
    return nil;
}


#pragma mark - Prepare

- (PNError *)validate {
    if (self.channels.count == 0 && self.channelGroups.count == 0) {
        return [self missingParameterError:@"channels" forObjectRequest:@"Heartbeat request"];
    }

    return nil;
}


#pragma mark - Misc

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{
        @"presenceHeartbeatValue": @(self.presenceHeartbeatValue),
        @"channels": self.channels.count ? self.channels : @","
    }];
    
    if (self.channelGroups) dictionary[@"channelGroups"] = self.channelGroups;
    if (self.state) dictionary[@"state"] = self.state;
    
    return dictionary;
}

#pragma mark -


@end
