#import "PNSubscribeRequest+Private.h"
#import "PNBaseRequest+Private.h"
#import "PNTransportRequest.h"
#import "PNFunctions.h"
#import "PNHelpers.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private extension declaration

/// `Subscribe` request private extension.
@interface PNSubscribeRequest ()


#pragma mark - Properties

/// List of channel group names on which client should try to subscribe.
@property(copy, nullable, nonatomic) NSArray<NSString *> *channelGroups;

/// List of channel names on which client should try to subscribe.
@property(copy, nullable, nonatomic) NSArray<NSString *> *channels;

/// String representation of filtering expression which should be applied to decide which updates should reach client.
@property(strong, nullable, nonatomic) NSString *filterExpression;

/// Number of seconds which is used by server to track whether client still subscribed on remote data objects live feed
/// or not.
@property(assign, nonatomic) NSInteger presenceHeartbeatValue;

/// Whether real-time updates should be received for both regular and presence events or only for presence.
@property(assign, nonatomic) BOOL presenceOnly;


#pragma mark - Initialization and Configuration

/// Initialize `Subscribe` request.
///
/// - Parameters:
///   - channels: List of channel names on which client should try to subscribe.
///   - channelGroups: List of channel group names on which client should try to subscribe.
///   - presenceOnly: Whether real-time updates should be received for both regular and presence events or only for
///   presence.
/// - Returns: Initialized `Subscribe` request.
- (instancetype)initWithChannels:(nullable NSArray<NSString *> *)channels
                   channelGroups:(nullable NSArray<NSString *> *)channelGroups
                    presenceOnly:(BOOL)presenceOnly;

#pragma mark -


@end

NS_ASSUME_NONNULL_END



#pragma mark - Interface implementation

@implementation PNSubscribeRequest


#pragma mark - Properties

- (PNTransportRequest *)request {
    PNTransportRequest *request = super.request;
    request.timeout = self.subscribeMaximumIdleTime;
    request.cancellable = YES;
    request.retriable = NO;

    return request;
}

- (PNOperationType)operation {
    return PNSubscribeOperation;
}

- (NSDictionary *)query {
    NSMutableDictionary *query = [([super query] ?: @{}) mutableCopy];

    if (self.channelGroups.count) query[@"channel-group"] = [self.channelGroups componentsJoinedByString:@","];
    if (self.state.count) query[@"state"] = [PNJSON JSONStringFrom:self.state withError:nil];
    if (self.filterExpression.length) query[@"filter-expr"] = self.filterExpression;
    if (self.presenceHeartbeatValue > 0) query[@"heartbeat"] = @(self.presenceHeartbeatValue).stringValue;
    if (self.timetoken) query[@"tt"] = self.timetoken.stringValue;
    if (self.region) query[@"tr"] = self.region.stringValue;
    
    return query;
}

- (NSString *)path {
    return PNStringFormat(@"/v2/subscribe/%@/%@/0",
                          self.subscribeKey,
                          [PNChannel namesForRequest:self.channels defaultString:@","]);
}


#pragma mark - Initialization and Configurtion

+ (instancetype)requestWithChannels:(NSArray<NSString *> *)channels channelGroups:(NSArray<NSString *> *)channelGroups {
    return [[self alloc] initWithChannels:channels channelGroups:channelGroups presenceOnly:NO];
}

+ (instancetype)requestWithPresenceChannels:(NSArray<NSString *> *)channels 
                              channelGroups:(NSArray<NSString *> *)channelGroups {
    NSMutableArray *presenceChannelGroups = nil;
    NSMutableArray *presenceChannels = nil;
    
    if (channels.count) {
        presenceChannels = [NSMutableArray arrayWithCapacity:channels.count];
        for(NSString *name in channels) {
            if ([name hasSuffix:@"-pnpres"]) [presenceChannels addObject:name];
            else [presenceChannels addObject:[name stringByAppendingString:@"-pnpres"]];
        }
    }
    
    if (channelGroups.count) {
        presenceChannelGroups = [NSMutableArray arrayWithCapacity:channelGroups.count];
        for(NSString *name in channelGroups) {
            if ([name hasSuffix:@"-pnpres"]) [presenceChannelGroups addObject:name];
            else [presenceChannelGroups addObject:[name stringByAppendingString:@"-pnpres"]];
        }
    }
    
    return [[self alloc] initWithChannels:presenceChannels channelGroups:presenceChannelGroups presenceOnly:YES];
}

- (instancetype)initWithChannels:(NSArray<NSString *> *)channels
                   channelGroups:(NSArray<NSString *> *)channelGroups
                    presenceOnly:(BOOL)presenceOnly {
    if ((self = [super init])) {
        _channelGroups = [channelGroups copy];
        _observePresence = presenceOnly;
        _presenceOnly = presenceOnly;
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
        return [self missingParameterError:@"channels" forObjectRequest:@"Subscribe request"];
    }
    
    return nil;
}


#pragma mark - Misc

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{
        @"observePresence": @(self.shouldObservePresence),
        @"channels": self.channels.count ? self.channels : @","
    }];
    
    if (self.arbitraryQueryParameters) dictionary[@"arbitraryQueryParameters"] = self.arbitraryQueryParameters;
    if (self.channelGroups) dictionary[@"channelGroups"] = self.channelGroups;
    if (self.timetoken) dictionary[@"timetoken"] = self.timetoken;
    if (self.region) dictionary[@"region"] = self.region;
    if (self.state) dictionary[@"state"] = self.state;
    
    return dictionary;
}

#pragma mark -


@end
