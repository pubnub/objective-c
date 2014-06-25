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
#import "PubNub+Protected.h"
#import "PNConstants.h"
#import "PNCache.h"


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

// Stores reference on client identifier on the moment of request creation
@property (nonatomic, copy) NSString *clientIdentifier;

/**
 Stores user-provided state which should be appended to the client subscription.
 */
@property (nonatomic, strong) NSDictionary *state;

// Stores whether leave request was sent to subscribe on new channels or as result of user request
@property (nonatomic, assign, getter = isSendingByUserRequest) BOOL sendingByUserRequest;

@property (nonatomic, assign, getter = isPerformingMultipleActions) BOOL performingMultipleActions;


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
        self.clientIdentifier = [PubNub escapedClientIdentifier];
        self.state = (clientState ? clientState : [[PubNub sharedInstance].cache stateForChannels:channels]);
        
        
        // Retrieve largest update time token from set of channels (sorting to make larger token to be at
        // the end of the list
        self.updateTimeToken = [PNChannel largestTimetokenFromChannels:channels];
    }
    
    
    return self;
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
            if (observedChannel && [_channelsForPresenceDisabling containsObject:observedChannel]) {
                
                [channelsForRemoval addObject:channel];
            }
        }
    }];
    
    [channels minusSet:channelsForRemoval];
    
    self.channels = [channels allObjects];
}


- (NSTimeInterval)timeout {
    
    return [PubNub sharedInstance].configuration.subscriptionRequestTimeout;
}

- (NSString *)callbackMethodName {
    
    return PNServiceResponseCallbacks.subscriptionCallback;
}

- (NSString *)resourcePath {
    
    NSString *heartbeatValue = @"";
    if ([PubNub sharedInstance].configuration.presenceHeartbeatTimeout > 0.0f) {
        
        heartbeatValue = [NSString stringWithFormat:@"&heartbeat=%d",
                          (int)[PubNub sharedInstance].configuration.presenceHeartbeatTimeout];
    }
    NSString *state = @"";
    if (self.state) {
        
        state = [NSString stringWithFormat:@"&state=%@",
                 [[PNJSONSerialization stringFromJSONObject:self.state] percentEscapedString]];
    }
    return [NSString stringWithFormat:@"/subscribe/%@/%@/%@_%@/%@?uuid=%@%@%@%@&pnsdk=%@",
            [[PubNub sharedInstance].configuration.subscriptionKey percentEscapedString],
            [[self.channels valueForKey:@"escapedName"] componentsJoinedByString:@","],
            [self callbackMethodName], self.shortIdentifier, self.updateTimeToken,
            self.clientIdentifier, heartbeatValue, state,
            ([self authorizationField] ? [NSString stringWithFormat:@"&%@", [self authorizationField]] : @""),
            [self clientInformationField]];
}

- (NSString *)debugResourcePath {
    
    NSMutableArray *resourcePathComponents = [[[self resourcePath] componentsSeparatedByString:@"/"] mutableCopy];
    [resourcePathComponents replaceObjectAtIndex:2 withObject:PNObfuscateString([[PubNub sharedInstance].configuration.subscriptionKey percentEscapedString])];
    
    return [resourcePathComponents componentsJoinedByString:@"/"];
}

- (NSString *)description {
    
    return [NSString stringWithFormat:@"<%@> %p [PATH: %@]", NSStringFromClass([self class]),
            self, [self debugResourcePath]];
}

#pragma mark -


@end
