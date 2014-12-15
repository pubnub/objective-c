//
//  PNSubscribeRequest.m
//  pubnub
//
//  This request object is used to describe
//  channel(s) subscription request which will
//  be scheduled on requests queue and executed
//  as soon as possible.
//
//
//  Created by Sergey Mamontov on 12/12/12.
//
//

#import "PNSubscribeRequest+Protected.h"
#import "PNChannelPresence+Protected.h"
#import "PNServiceResponseCallbacks.h"
#import "PNBaseRequest+Protected.h"
#import "NSString+PNAddition.h"
#import "PNChannel+Protected.h"
#import "PNJSONSerialization.h"
#import "PNConfiguration.h"
#import "PNConstants.h"
#import "PNCache.h"
#import "PNMacro.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub subscribe request must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Private interface methods

@interface PNSubscribeRequest ()


#pragma mark - Properties

// Stores reference on list of channels on which client should subscribe
@property (nonatomic, strong) NSArray *channels;

// Stores reference on list of channels for which presence should be enabled/disabled
@property (nonatomic, strong) NSArray *channelsForPresenceEnabling;
@property (nonatomic, strong) NSArray *channelsForPresenceDisabling;

// Stores recent channels/presence state update time (token)
@property (nonatomic, copy) NSString *updateTimeToken;

/**
 Stores user-provided state which should be appended to the client subscription.
 */
@property (nonatomic, strong) NSDictionary *state;

// Stores whether leave request was sent to subscribe on new channels or as result of user request
@property (nonatomic, assign, getter = isSendingByUserRequest) BOOL sendingByUserRequest;

@property (nonatomic, assign, getter = isPerformingMultipleActions) BOOL performingMultipleActions;

@property (nonatomic, assign) NSInteger presenceHeartbeatTimeout;
@property (nonatomic, copy) NSString *subscriptionKey;


@end


#pragma mark Public interface methods

@implementation PNSubscribeRequest


#pragma mark - Class methods

+ (PNSubscribeRequest *)subscribeRequestForChannel:(PNChannel *)channel byUserRequest:(BOOL)isSubscribingByUserRequest
                                   withClientState:(NSDictionary *)clientState {
    
    return [self subscribeRequestForChannels:@[channel]
                               byUserRequest:isSubscribingByUserRequest
                             withClientState:clientState];
}

+ (PNSubscribeRequest *)subscribeRequestForChannels:(NSArray *)channels byUserRequest:(BOOL)isSubscribingByUserRequest
                                    withClientState:(NSDictionary *)clientState {
    
    return [[[self class] alloc] initForChannels:channels
                                   byUserRequest:isSubscribingByUserRequest
                                 withClientState:clientState];
}

#pragma mark - Instance methods

- (id)initForChannel:(PNChannel *)channel byUserRequest:(BOOL)isSubscribingByUserRequest withClientState:(NSDictionary *)clientState {
    
    return [self initForChannels:@[channel] byUserRequest:isSubscribingByUserRequest withClientState:clientState];
}

- (id)initForChannels:(NSArray *)channels byUserRequest:(BOOL)isSubscribingByUserRequest withClientState:(NSDictionary *)clientState {
    
    // Check whether initialization successful or not
    if((self = [super init])) {
        
        self.sendingByUserRequest = isSubscribingByUserRequest;
        self.channels = [NSArray arrayWithArray:channels];
        self.state = ([clientState count] ? clientState : nil);
        
        
        // Retrieve largest update time token from set of channels (sorting to make larger token to be at
        // the end of the list
        self.updateTimeToken = [PNChannel largestTimetokenFromChannels:channels];
    }
    
    
    return self;
}

- (void)finalizeWithConfiguration:(PNConfiguration *)configuration clientIdentifier:(NSString *)clientIdentifier {
    
    [super finalizeWithConfiguration:configuration clientIdentifier:clientIdentifier];
    
    self.presenceHeartbeatTimeout = configuration.presenceHeartbeatTimeout;
    self.timeout = configuration.subscriptionRequestTimeout;
    self.subscriptionKey = configuration.subscriptionKey;
    self.clientIdentifier = clientIdentifier;
}

- (void)resetSubscriptionTimeToken {
    
    self.updateTimeToken = @"0";
}

- (void)resetTimeToken {
    
    [self resetTimeTokenTo:@"0"];
}

- (void)resetTimeTokenTo:(NSString *)timeToken {
    
    [[self channels] makeObjectsPerformSelector:@selector(setUpdateTimeToken:) withObject:timeToken];
    self.updateTimeToken = timeToken;
}

/**
 * Reloaded to return full list of channels for which client is subscribing
 */
- (NSArray *)channels {
    
    NSArray *channels = _channels;
    
    // Check whether presence enabling / disabling channels specified or not
    if ([self.channelsForPresenceEnabling count] > 0 || [self.channelsForPresenceDisabling count] > 0) {
        
        NSMutableSet *updatedSet = [NSMutableSet setWithArray:channels];
        
        // In case if user specified set of channels for which presence is enabled, add them to the channels list
        if ([self.channelsForPresenceEnabling count] > 0) {
            
            [updatedSet addObjectsFromArray:self.channelsForPresenceEnabling];
        }
        NSArray *presenceEnabledChannels = [PNChannelPresence presenceChannelsFromArray:_channels];
        [self.channelsForPresenceDisabling enumerateObjectsUsingBlock:^(PNChannel *channel, NSUInteger channelIdx, BOOL *channelEnumeratorStop) {
            
            [presenceEnabledChannels enumerateObjectsUsingBlock:^(PNChannelPresence *presenceChannel, NSUInteger presenceChannelIdx,
                                                                  BOOL *presenceChannelEnumeratorStop) {
                
                if ([[presenceChannel observedChannel] isEqual:[channel valueForKey:@"observedChannel"]]) {
                    
                    [updatedSet removeObject:presenceChannel];
                    *presenceChannelEnumeratorStop = YES;
                }
            }];
        }];
        
        channels = [updatedSet allObjects];
    }
    
    
    return channels;
}

- (NSArray *)channelsForSubscription {
    
    return _channels;
}

- (BOOL)isInitialSubscription {
    
    return [self.updateTimeToken isEqualToString:@"0"];
}

- (void)prepareToSend {

    NSMutableSet *channels = [NSMutableSet setWithArray:_channels];
    NSSet *forPresenceDisabling = [NSSet setWithArray:self.channelsForPresenceDisabling];
    if ([channels intersectsSet:forPresenceDisabling]) {

        [forPresenceDisabling enumerateObjectsUsingBlock:^(PNChannel *channel, BOOL *channelEnumeratorStop) {

            if ([channel isPresenceObserver]) {

                [channels removeObject:channel];
            }
        }];
    }
}
- (void)setChannelsForPresenceDisabling:(NSArray *)channelsForPresenceDisabling {
    
    _channelsForPresenceDisabling = channelsForPresenceDisabling;
    
    NSMutableSet *channels = [NSMutableSet setWithArray:_channels];
    NSMutableSet *channelsForRemoval = [NSMutableSet set];
    
    [_channelsForPresenceDisabling enumerateObjectsUsingBlock:^(PNChannel *channel, NSUInteger channelIdx,
                                                                BOOL *channelEnumeratorStop) {
        
        if ([channel isPresenceObserver]) {
            
            [channelsForRemoval addObject:channel];
        }
        else {
            
            PNChannelPresence *observer = [channel presenceObserver];
            if (observer) {
                
                [channelsForRemoval addObject:[channel presenceObserver]];
            }
        }
    }];
    [_channels enumerateObjectsUsingBlock:^(PNChannel *channel, NSUInteger channelIdx,
                                            BOOL *channelEnumeratorStop) {
        
        if ([channel isPresenceObserver]) {
            
            PNChannel *observedChannel = [(PNChannelPresence *)channel observedChannel];
            if (observedChannel && [self->_channelsForPresenceDisabling containsObject:observedChannel]) {
                
                [channelsForRemoval addObject:channel];
            }
        }
    }];
    
    [channels minusSet:channelsForRemoval];
    
    self.channels = [channels allObjects];
}

- (NSString *)callbackMethodName {
    
    return PNServiceResponseCallbacks.subscriptionCallback;
}

- (NSString *)resourcePath {
    
    NSString *heartbeatValue = @"";
    if (self.presenceHeartbeatTimeout > 0.0f) {
        
        heartbeatValue = [NSString stringWithFormat:@"&heartbeat=%d", (int)self.presenceHeartbeatTimeout];
    }
    NSString *state = @"";
    if (self.state) {
        
        state = [NSString stringWithFormat:@"&state=%@",
                                           [[PNJSONSerialization stringFromJSONObject:self.state] pn_percentEscapedString]];
    }
    
    NSArray *channelsList = [self channels];
    NSString *channelsListParameter = nil;
    NSString *groupsListParameter = nil;
    if ([channelsList count]) {
        
        NSArray *channels = [channelsList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.isChannelGroup = NO"]];
        NSArray *groups = [channelsList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.isChannelGroup = YES"]];
        if ([channels count]) {
            
            channelsListParameter = [[channels valueForKey:@"escapedName"] componentsJoinedByString:@","];
        }
        if ([groups count]) {
            
            groupsListParameter = [[groups valueForKey:@"escapedName"] componentsJoinedByString:@","];
        }
    }
    
    return [NSString stringWithFormat:@"/subscribe/%@/%@/%@_%@/%@?uuid=%@%@%@%@%@&pnsdk=%@",
            [self.subscriptionKey pn_percentEscapedString], (channelsListParameter ? channelsListParameter : @","),
            [self callbackMethodName], self.shortIdentifier, self.updateTimeToken,
            [self.clientIdentifier stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], heartbeatValue,
            state, (groupsListParameter ? [NSString stringWithFormat:@"&channel-group=%@", groupsListParameter] : @""),
            ([self authorizationField] ? [NSString stringWithFormat:@"&%@", [self authorizationField]] : @""),
            [self clientInformationField]];
}

- (NSString *)debugResourcePath {
    
    NSString *subscriptionKey = [self.subscriptionKey pn_percentEscapedString];
    return [[self resourcePath] stringByReplacingOccurrencesOfString:subscriptionKey withString:PNObfuscateString(subscriptionKey)];
}

- (NSString *)description {
    
    return [NSString stringWithFormat:@"<%@|%@>", NSStringFromClass([self class]), [self debugResourcePath]];
}

#pragma mark -


@end
