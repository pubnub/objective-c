/**
 * @author Serhii Mamontov
 * @since 4.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "PubNub+Subscribe.h"
#import "PNAPICallBuilder+Private.h"
#import "PubNub+CorePrivate.h"
#import "PNSubscriber.h"
#import "PNNetwork.h"
#import "PNHelpers.h"


#pragma mark - Constants

/**
 * @brief Subscribe REST API path prefix.
 *
 * @discussion Prefix used for faster request identification (w/o performing search of range with
 * options).
 *
 * @since 4.6.2
 */
static NSString * const kPNSubscribeAPIPrefix = @"/v2/subscribe/";


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PubNub (SubscribeProtected)


#pragma mark - Subscription

/**
 * @brief Try subscribe on specified set of channels and/or groups.
 *
 * @discussion Using subscribe API client is able to subscribe of remote data objects live feed and
 * listen for new events from them.
 *
 * @param channels List of channel names on which client should try to subscribe.
 * @param groups List of channel group names on which client should try to subscribe.
 * @param shouldObservePresence Whether presence observation should be enabled for \c channels and
 *     \c groups or not.
 * @param timeToken Time from which client should try to catch up on messages.
 * @param state \a NSDictionary with key-value pairs based on channel group name and value which
 *     should be assigned to it.
 * @param queryParameters List arbitrary query parameters which should be sent along with original
 *     API call.
 *
 * @since 4.8.2
 */
- (void)subscribeToChannels:(nullable NSArray<NSString *> *)channels
                     groups:(nullable NSArray<NSString *> *)groups
               withPresence:(BOOL)shouldObservePresence
             usingTimeToken:(nullable NSNumber *)timeToken
                clientState:(nullable NSDictionary<NSString *, id> *)state
            queryParameters:(nullable NSDictionary *)queryParameters;

/**
 * @brief Enable presence observation on specified \c channels.
 *
 * @discussion Using this API client will be able to observe for presence events which is pushed to
 * remote data objects.
 *
 * @param channels List of channel names for which client should try to subscribe on presence
 *     observing channels.
 * @param queryParameters List arbitrary query parameters which should be sent along with original
 *     API call.
 *
 * @since 4.8.2
 */
- (void)subscribeToPresenceChannels:(NSArray<NSString *> *)channels
                withQueryParameters:(nullable NSDictionary *)queryParameters;


#pragma mark - Unsubscription

/**
 * @brief Disable presence events observation on specified channels.
 *
 * @discussion This API allow to stop presence observation on specified set of channels.
 *
 * @param channels List of channel names for which client should try to unsubscribe from presence
 *     observing channels.
 * @param queryParameters List arbitrary query parameters which should be sent along with original
 *     API call.
 *
 * @since 4.8.2
 */
- (void)unsubscribeFromPresenceChannels:(NSArray<NSString *> *)channels
                    withQueryParameters:(nullable NSDictionary *)queryParameters;

/**
 * @brief Unsubscribe from all channels and groups on which client has been subscribed so far.
 *
 * @param queryParameters List arbitrary query parameters which should be sent along with original
 *     API call.
 * @param block Un-subscription completion block.
 *
 * @since 4.8.2
 */
- (void)unsubscribeFromAllWithQueryParameters:(nullable NSDictionary *)queryParameters
                                   completion:(void(^__nullable)(PNStatus *status))block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PubNub (Subscribe)


#pragma mark - Subscription state information

- (NSArray<NSString *> *)channels {
    
    return [self.subscriberManager channels];
}

- (NSArray<NSString *> *)channelGroups {
    
    return [self.subscriberManager channelGroups];
}

- (NSArray<NSString *> *)presenceChannels {
    
    return [self.subscriberManager presenceChannels];
}

- (BOOL)isSubscribedOn:(NSString *)name {
    
    return ([[self channels] containsObject:name] || [[self channelGroups] containsObject:name] ||
            [[self presenceChannels] containsObject:name]);
}


#pragma mark - Listeners

- (void)addListener:(id <PNObjectEventListener>)listener {
    
    // Forwarding calls to listener manager.
    [self.listenersManager addListener:listener];
}

- (void)removeListener:(id <PNObjectEventListener>)listener {
    
    // Forwarding calls to listener manager.
    [self.listenersManager removeListener:listener];
}


#pragma mark - Filtering

- (NSString *)filterExpression {
    
    return self.subscriberManager.filterExpression;
}

- (void)setFilterExpression:(NSString *)filterExpression {
    
    self.subscriberManager.filterExpression = filterExpression;

    if ([self.subscriberManager allObjects].count) {
        [self subscribeToChannels:@[] withPresence:NO];
    }
}


#pragma mark - API Builder support

- (PNSubscribeAPIBuilder * (^)(void))subscribe {
    
    PNSubscribeAPIBuilder *builder = nil;
    builder = [PNSubscribeAPIBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags, 
                                                                 NSDictionary *parameters) {
                            
        NSDictionary *state = parameters[NSStringFromSelector(@selector(state))];
        NSNumber *withPresence = parameters[NSStringFromSelector(@selector(withPresence))];
        NSNumber *timetoken = parameters[NSStringFromSelector(@selector(withTimetoken))];
        NSArray *channels = parameters[NSStringFromSelector(@selector(channels))];
        NSArray *groups = parameters[NSStringFromSelector(@selector(channelGroups))];
        NSArray *presenceChannels = parameters[NSStringFromSelector(@selector(presenceChannels))];
        NSDictionary *queryParam = parameters[@"queryParam"];
        
        if (channels.count || groups.count) {
            [self subscribeToChannels:channels
                               groups:groups
                         withPresence:withPresence.boolValue
                       usingTimeToken:timetoken
                          clientState:state
                      queryParameters:queryParam];
        } else if ((channels = presenceChannels).count) {
            [self subscribeToPresenceChannels:channels withQueryParameters:queryParam];
        }
    }];
    
    return ^PNSubscribeAPIBuilder * {
        return builder;
    };
}

- (PNUnsubscribeAPICallBuilder * (^)(void))unsubscribe {
    
    PNUnsubscribeAPICallBuilder *builder = nil;
    builder = [PNUnsubscribeAPICallBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags, 
                                                                       NSDictionary *parameters) {

        NSNumber *withPresence = parameters[NSStringFromSelector(@selector(withPresence))];
        NSArray *channels = parameters[NSStringFromSelector(@selector(channels))];
        NSArray *groups = parameters[NSStringFromSelector(@selector(channelGroups))];
        NSArray *presenceChannels = parameters[NSStringFromSelector(@selector(presenceChannels))];
        NSDictionary *queryParam = parameters[@"queryParam"];
        
        if (channels.count || groups.count) {
            [self unsubscribeFromChannels:channels
                                   groups:groups
                             withPresence:withPresence.boolValue
                          queryParameters:queryParam
                               completion:nil];
        } else if ((channels = presenceChannels).count) {
            [self unsubscribeFromPresenceChannels:channels withQueryParameters:queryParam];
        } else {
            [self unsubscribeFromAllWithQueryParameters:queryParam completion:nil];
        }
    }];
    
    return ^PNUnsubscribeAPICallBuilder * {
        return builder;
    };
}


#pragma mark - Subscription

- (void)subscribeToChannels:(NSArray<NSString *> *)channels
               withPresence:(BOOL)shouldObservePresence {
    
    [self subscribeToChannels:channels withPresence:shouldObservePresence usingTimeToken:nil];
}

- (void)subscribeToChannels:(NSArray<NSString *> *)channels
               withPresence:(BOOL)shouldObservePresence
             usingTimeToken:(NSNumber *)timeToken {
    
    [self subscribeToChannels:channels
                 withPresence:shouldObservePresence
               usingTimeToken:timeToken
                  clientState:nil];
}

- (void)subscribeToChannels:(NSArray<NSString *> *)channels
               withPresence:(BOOL)shouldObservePresence
                clientState:(NSDictionary<NSString *, id> *)state {
    
    [self subscribeToChannels:channels
                 withPresence:shouldObservePresence
               usingTimeToken:nil
                  clientState:state];
}

- (void)subscribeToChannels:(NSArray<NSString *> *)channels
               withPresence:(BOOL)shouldObservePresence
             usingTimeToken:(NSNumber *)timeToken
                clientState:(NSDictionary<NSString *, id> *)state {
    
    [self subscribeToChannels:channels
                       groups:nil
                 withPresence:shouldObservePresence
               usingTimeToken:timeToken
                  clientState:state];
}

- (void)subscribeToChannelGroups:(NSArray<NSString *> *)groups
                    withPresence:(BOOL)shouldObservePresence {
    
    [self subscribeToChannelGroups:groups
                      withPresence:shouldObservePresence
                    usingTimeToken:nil];
}

- (void)subscribeToChannelGroups:(NSArray<NSString *> *)groups
                    withPresence:(BOOL)shouldObservePresence
                  usingTimeToken:(NSNumber *)timeToken {
    
    [self subscribeToChannelGroups:groups
                      withPresence:shouldObservePresence
                    usingTimeToken:timeToken
                       clientState:nil];
}

- (void)subscribeToChannelGroups:(NSArray<NSString *> *)groups
                    withPresence:(BOOL)shouldObservePresence
                     clientState:(NSDictionary<NSString *, id> *)state {

    [self subscribeToChannelGroups:groups
                      withPresence:shouldObservePresence
                    usingTimeToken:nil
                       clientState:state];
}

- (void)subscribeToChannelGroups:(NSArray<NSString *> *)groups
                    withPresence:(BOOL)shouldObservePresence
                  usingTimeToken:(NSNumber *)timeToken
                     clientState:(NSDictionary<NSString *, id> *)state {
    
    [self subscribeToChannels:nil
                       groups:groups
                 withPresence:shouldObservePresence
               usingTimeToken:timeToken
                  clientState:state];
}

- (void)subscribeToChannels:(NSArray<NSString *> *)channels
                     groups:(NSArray<NSString *> *)groups
               withPresence:(BOOL)shouldObservePresence
             usingTimeToken:(NSNumber *)timeToken
                clientState:(NSDictionary<NSString *, id> *)state {
    
    [self subscribeToChannels:channels
                       groups:groups
                 withPresence:shouldObservePresence
               usingTimeToken:timeToken
                  clientState:state
              queryParameters:nil];
}

- (void)subscribeToChannels:(NSArray<NSString *> *)channels
                     groups:(NSArray<NSString *> *)groups
               withPresence:(BOOL)shouldObservePresence
             usingTimeToken:(NSNumber *)timeToken
                clientState:(NSDictionary<NSString *, id> *)state
            queryParameters:(NSDictionary *)queryParameters {
    
    channels = (channels ?: @[]);
    groups = (groups ?: @[]);
    
    if (channels.count) {
        NSArray *presenceList = nil;
        
        if (shouldObservePresence) {
            presenceList = [PNChannel presenceChannelsFrom:channels];
            
        }

        NSArray *channelsForAddition = [channels arrayByAddingObjectsFromArray:presenceList];
        [self.subscriberManager addChannels:channelsForAddition];
    }
    
    if (groups.count) {
        NSArray *presenceList = nil;
        
        if (shouldObservePresence) {
            presenceList = [PNChannel presenceChannelsFrom:groups];
        }

        NSArray *groupsForAddition = [groups arrayByAddingObjectsFromArray:presenceList];
        [self.subscriberManager addChannelGroups:groupsForAddition];
    }
    
    [self cancelSubscribeOperations];
    [self.subscriberManager subscribeUsingTimeToken:timeToken
                                          withState:state
                                    queryParameters:queryParameters
                                         completion:nil];
}

- (void)subscribeToPresenceChannels:(NSArray<NSString *> *)channels {
    
    [self subscribeToPresenceChannels:channels withQueryParameters:nil];
}

- (void)subscribeToPresenceChannels:(NSArray<NSString *> *)channels
                withQueryParameters:(NSDictionary *)queryParameters {
    
    channels = [PNChannel presenceChannelsFrom:channels];

    [self.subscriberManager addPresenceChannels:channels];
    [self cancelSubscribeOperations];
    [self.subscriberManager subscribeUsingTimeToken:nil
                                          withState:nil
                                    queryParameters:queryParameters
                                         completion:nil];
}


#pragma mark - Unsubscription

- (void)unsubscribeFromChannels:(NSArray<NSString *> *)channels
                   withPresence:(BOOL)shouldObservePresence {
    
    [self unsubscribeFromChannels:channels
                           groups:nil
                     withPresence:shouldObservePresence
                  queryParameters:nil
                       completion:nil];
}

- (void)unsubscribeFromChannelGroups:(NSArray<NSString *> *)groups
                        withPresence:(BOOL)shouldObservePresence {

    [self unsubscribeFromChannels:nil
                           groups:groups
                     withPresence:shouldObservePresence
                  queryParameters:nil
                       completion:nil];
}

- (void)unsubscribeFromChannels:(NSArray<NSString *> *)channels
                         groups:(NSArray<NSString *> *)groups
                   withPresence:(BOOL)shouldObservePresence
                queryParameters:(NSDictionary *)queryParameters
                     completion:(PNSubscriberCompletionBlock)block {
    
    channels = (channels ?: @[]);
    groups = (groups ?: @[]);
    
    if (channels.count) {
        NSArray *presenceList = nil;
        
        if (shouldObservePresence) {
            presenceList = [PNChannel presenceChannelsFrom:channels];
        }

        NSArray *channelsForRemoval = [channels arrayByAddingObjectsFromArray:presenceList];
        [self.subscriberManager removeChannels:channelsForRemoval];
    }
    
    if (groups.count) {
        NSArray *presenceList = nil;
        
        if (shouldObservePresence) {
            presenceList = [PNChannel presenceChannelsFrom:groups];
        }

        NSArray *groupsForRemoval = [groups arrayByAddingObjectsFromArray:presenceList];
        [self.subscriberManager removeChannelGroups:groupsForRemoval];
    }
    
    if (channels.count || groups.count) {
        [self cancelSubscribeOperations];
        [self.subscriberManager unsubscribeFromChannels:channels
                                                 groups:groups
                                    withQueryParameters:queryParameters
                                  listenersNotification:YES
                                             completion:block];
    } else if (block) {
        pn_dispatch_async(self.callbackQueue, ^{
            block(nil);
        });
        
    }
}

- (void)unsubscribeFromPresenceChannels:(NSArray<NSString *> *)channels {
    
    [self unsubscribeFromPresenceChannels:channels withQueryParameters:nil];
}

- (void)unsubscribeFromPresenceChannels:(NSArray<NSString *> *)channels
                    withQueryParameters:(NSDictionary *)queryParameters {
    
    channels = [PNChannel presenceChannelsFrom:channels];
    
    [self.subscriberManager removePresenceChannels:channels];
    [self cancelSubscribeOperations];
    [self.subscriberManager unsubscribeFromChannels:channels
                                             groups:nil
                                withQueryParameters:queryParameters
                              listenersNotification:YES
                                         completion:nil];
}

- (void)unsubscribeFromAll {

    [self unsubscribeFromAllWithCompletion:nil];
}

- (void)unsubscribeFromAllWithCompletion:(void(^)(PNStatus *status))block {
    
    [self unsubscribeFromAllWithQueryParameters:nil completion:block];
}

- (void)unsubscribeFromAllWithQueryParameters:(NSDictionary *)queryParameters
                                   completion:(void(^)(PNStatus *status))block {
    
    [self cancelSubscribeOperations];
    [self.subscriberManager unsubscribeFromAllWithQueryParameters:queryParameters completion:block];
}


#pragma mark - Misc

- (void)cancelSubscribeOperations {
    
    [self.subscriptionNetwork cancelAllOperationsWithURLPrefix:kPNSubscribeAPIPrefix];
}

#pragma mark -


@end
