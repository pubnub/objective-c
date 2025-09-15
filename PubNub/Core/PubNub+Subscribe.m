#import "PubNub+SubscribePrivate.h"
#import "PNBaseOperationData+Private.h"
#import "PNSubscribeRequest+Private.h"
#import "PNOperationResult+Private.h"
#import "PNSubscribeStatus+Private.h"
#import "PNConfiguration+Private.h"
#import "PubNub+CorePrivate.h"
#import "PNStatus+Private.h"
#import "PNSubscribeData.h"
#import "PNSubscriber.h"
#import "PNHelpers.h"


// Deprecated
#import "PNAPICallBuilder+Private.h"


#pragma mark Constants

/// Subscribe REST API path prefix.
///
/// Prefix used for faster request identification (w/o performing search of range with options).
static NSString * const kPNSubscribeAPIPrefix = @"/v2/subscribe/";


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Private interface declaration

/// **PubNub** `Subscribe` APIs private extension.
@interface PubNub (SubscribeProtected)


#pragma mark - Subscription

/// Try subscribe on specified set of channels and/or groups.
///
/// Using subscribe API client is able to subscribe of remote data objects live feed and listen for new events from
/// them.
///
/// - Parameters:
///   - channels:P List of channel names on which client should try to subscribe.
///   - groups: List of channel group names on which client should try to subscribe.
///   - shouldObservePresence: Whether presence observation should be enabled for `channels` and `groups` or not.
///   - timeToken: Time from which client should try to catch up on messages.
///   - state: `NSDictionary` with key-value pairs based on channel group name and value which should be assigned to it.
///   - queryParameters: List arbitrary query parameters which should be sent along with original API call.
- (void)subscribeToChannels:(nullable NSArray<NSString *> *)channels
                     groups:(nullable NSArray<NSString *> *)groups
               withPresence:(BOOL)shouldObservePresence
             usingTimeToken:(nullable NSNumber *)timeToken
                clientState:(nullable NSDictionary<NSString *, id> *)state
            queryParameters:(nullable NSDictionary *)queryParameters;

/// Enable presence observation on specified `channels`.
///
/// Using this API client will be able to observe for presence events which is pushed to remote data objects.
///
/// - Parameters:
///   - channels: List of channel names for which client should try to subscribe on presence observing channels.
///   - queryParameters: List arbitrary query parameters which should be sent along with original API call.
- (void)subscribeToPresenceChannels:(NSArray<NSString *> *)channels
                withQueryParameters:(nullable NSDictionary *)queryParameters;


#pragma mark - Unsubscription

/// Disable presence events observation on specified channels.
///
/// This API allow to stop presence observation on specified set of channels.
///
/// - Parameters:
///   -  channels: List of channel names for which client should try to unsubscribe from presence observing channels.
///   - queryParameters: List arbitrary query parameters which should be sent along with original API call.
- (void)unsubscribeFromPresenceChannels:(NSArray<NSString *> *)channels
                    withQueryParameters:(nullable NSDictionary *)queryParameters;

/// Unsubscribe from all channels and groups on which client has been subscribed so far.
///
/// - Parameters:
///   - queryParameters: List arbitrary query parameters which should be sent along with original API call.
///   - block: Un-subscription completion block.
- (void)unsubscribeFromAllWithQueryParameters:(nullable NSDictionary *)queryParameters
                                   completion:(void(^__nullable)(PNAcknowledgmentStatus *status))block;

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

- (void)addListener:(id <PNEventsListener>)listener {
    [self.listenersManager addListener:listener];
}

- (void)removeListener:(id <PNEventsListener>)listener {
    [self.listenersManager removeListener:listener];
}


#pragma mark - Filtering

- (NSString *)filterExpression {
    return self.configuration.filterExpression;
}

- (void)setFilterExpression:(NSString *)filterExpression {
    self.configuration.filterExpression = filterExpression;

    if ([self.subscriberManager allObjects].count) {
        [self subscribeWithRequest:[PNSubscribeRequest requestWithChannels:@[] channelGroups:@[]]];
    }
}


#pragma mark - API Builder support

- (PNSubscribeAPIBuilder * (^)(void))subscribe {
    [self.logger warnWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
        return [PNStringLogEntry entryWithMessage:@"Builder-based interface deprecated. Please use corresponding "
                "request-based interfaces."];
    }];
    
    PNSubscribeAPIBuilder *builder = nil;
    builder = [PNSubscribeAPIBuilder builderWithExecutionBlock:^(NSArray<NSString *> *flags, NSDictionary *parameters) {
        NSArray *presenceChannels = parameters[NSStringFromSelector(@selector(presenceChannels))];
        NSDictionary *state = parameters[NSStringFromSelector(@selector(state))];
        NSNumber *withPresence = parameters[NSStringFromSelector(@selector(withPresence))];
        NSNumber *timetoken = parameters[NSStringFromSelector(@selector(withTimetoken))];
        NSArray *channels = parameters[NSStringFromSelector(@selector(channels))];
        NSArray *groups = parameters[NSStringFromSelector(@selector(channelGroups))];
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
    [self.logger warnWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
        return [PNStringLogEntry entryWithMessage:@"Builder-based interface deprecated. Please use corresponding "
                "request-based interfaces."];
    }];
    
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
        } else [self unsubscribeFromAllWithQueryParameters:queryParam completion:nil];
    }];
    
    return ^PNUnsubscribeAPICallBuilder * {
        return builder;
    };
}


#pragma mark - Subscription

- (void)subscribeWithRequest:(PNSubscribeRequest *)request {
    [self cancelSubscribeOperations];
    [self.subscriberManager subscribeWithRequest:request];
}

- (void)subscribeWithRequest:(PNSubscribeRequest *)userRequest completion:(PNSubscriberCompletionBlock)handleBlock {
    PNOperationDataParser *responseParser = [self parserWithStatus:[PNSubscribeStatus class]];
    userRequest.presenceHeartbeatValue = self.configuration.presenceHeartbeatValue;
    userRequest.filterExpression = self.filterExpression;

    [userRequest setupWithClientConfiguration:self.configuration];
    PNSubscriberCompletionBlock block = [handleBlock copy];
    PNParsedRequestCompletionBlock handler;

    PNWeakify(self);
    handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, __unused NSURL *location,
                PNOperationDataParseResult<PNSubscribeStatus *, PNSubscribeStatus *> *result) {
        PNStrongify(self);

        result.status.initialSubscription = [userRequest.timetoken isEqualToNumber:@0];

        [self callBlock:block status:YES withResult:nil andStatus:result.status];
    };
    
    [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
        return [PNDictionaryLogEntry entryWithMessage:[userRequest dictionaryRepresentation]
                                              details:@"Subscribe with parameters:"];
    }];

    [self performRequest:userRequest withParser:responseParser completion:handler];
}

- (void)subscribeToChannels:(NSArray<NSString *> *)channels withPresence:(BOOL)shouldObservePresence {
    [self subscribeToChannels:channels withPresence:shouldObservePresence usingTimeToken:nil];
}

- (void)subscribeToChannels:(NSArray<NSString *> *)channels
               withPresence:(BOOL)shouldObservePresence
             usingTimeToken:(NSNumber *)timeToken {
    [self subscribeToChannels:channels withPresence:shouldObservePresence usingTimeToken:timeToken clientState:nil];
}

- (void)subscribeToChannels:(NSArray<NSString *> *)channels
               withPresence:(BOOL)shouldObservePresence
                clientState:(NSDictionary<NSString *, id> *)state {
    [self subscribeToChannels:channels withPresence:shouldObservePresence usingTimeToken:nil clientState:state];
}

- (void)subscribeToChannels:(NSArray<NSString *> *)channels
               withPresence:(BOOL)shouldObservePresence
             usingTimeToken:(NSNumber *)timeToken
                clientState:(NSDictionary<NSString *, id> *)state {
    [self.logger warnWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
        return [PNStringLogEntry entryWithMessage:@"This method deprecated. Please use '-subscribeWithRequest:' method "
                "instead."];
    }];
    
    [self subscribeToChannels:channels
                       groups:nil
                 withPresence:shouldObservePresence
               usingTimeToken:timeToken
                  clientState:state
              queryParameters:nil];
}

- (void)subscribeToChannelGroups:(NSArray<NSString *> *)groups withPresence:(BOOL)shouldObservePresence {
    [self subscribeToChannelGroups:groups withPresence:shouldObservePresence usingTimeToken:nil];
}

- (void)subscribeToChannelGroups:(NSArray<NSString *> *)groups
                    withPresence:(BOOL)shouldObservePresence
                  usingTimeToken:(NSNumber *)timeToken {
    [self subscribeToChannelGroups:groups withPresence:shouldObservePresence usingTimeToken:timeToken clientState:nil];
}

- (void)subscribeToChannelGroups:(NSArray<NSString *> *)groups
                    withPresence:(BOOL)shouldObservePresence
                     clientState:(NSDictionary<NSString *, id> *)state {
    [self subscribeToChannelGroups:groups withPresence:shouldObservePresence usingTimeToken:nil clientState:state];
}

- (void)subscribeToChannelGroups:(NSArray<NSString *> *)groups
                    withPresence:(BOOL)shouldObservePresence
                  usingTimeToken:(NSNumber *)timeToken
                     clientState:(NSDictionary<NSString *, id> *)state {
    [self.logger warnWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
        return [PNStringLogEntry entryWithMessage:@"This method deprecated. Please use '-subscribeWithRequest:' method "
                "instead."];
    }];
    
    [self subscribeToChannels:nil
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
    PNSubscribeRequest *request = [PNSubscribeRequest requestWithChannels:channels ?: @[] channelGroups:groups ?: @[]];
    request.arbitraryQueryParameters = queryParameters;
    request.observePresence = shouldObservePresence;
    request.timetoken = timeToken;
    request.state = state;
               
    [self subscribeWithRequest:request];
}

- (void)subscribeToPresenceChannels:(NSArray<NSString *> *)channels {
    [self.logger warnWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
        return [PNStringLogEntry entryWithMessage:@"This method deprecated. Please use '-subscribeWithRequest:' method "
                "instead."];
    }];
    
    [self subscribeToPresenceChannels:channels withQueryParameters:nil];
}

- (void)subscribeToPresenceChannels:(NSArray<NSString *> *)channels withQueryParameters:(NSDictionary *)query {
    PNSubscribeRequest *request = [PNSubscribeRequest requestWithPresenceChannels:channels channelGroups:nil];
    request.arbitraryQueryParameters = query;

    [self subscribeWithRequest:request];
}


#pragma mark - Unsubscription

- (void)unsubscribeWithRequest:(PNPresenceLeaveRequest *)request {
    if (request.channels.count == 0 && request.channelGroups.count == 0) return;

    [self cancelSubscribeOperations];
    [self.subscriberManager unsubscribeWithRequest:request completion:nil];
}

- (void)unsubscribeWithRequest:(PNPresenceLeaveRequest *)userRequest
                    completion:(PNSubscriberCompletionBlock)handleBlock {
    PNOperationDataParser *responseParser = [self parserWithStatus:[PNAcknowledgmentStatus class]];
    PNSubscriberCompletionBlock block = [handleBlock copy];
    PNParsedRequestCompletionBlock handler;

    PNWeakify(self);
    handler = ^(PNTransportRequest *request, id<PNTransportResponse> response, __unused NSURL *location,
                PNOperationDataParseResult<PNAcknowledgmentStatus *, PNAcknowledgmentStatus *> *result) {
        PNStrongify(self);
        PNSubscribeStatus *subscribeStatus;

        if (!result.status.isError) {
            subscribeStatus = [PNSubscribeStatus objectWithOperation:userRequest.operation
                                                            response:result.status.responseData];
        } else {
            subscribeStatus = [PNSubscribeStatus objectWithOperation:userRequest.operation
                                                            category:result.status.category
                                                            response:result.status.responseData];
        }
        
        [self callBlock:block status:YES withResult:nil andStatus:subscribeStatus];
    };
                        
    [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
        return [PNDictionaryLogEntry entryWithMessage:[userRequest dictionaryRepresentation]
                                                                  details:@"Unsubscribe with parameters:"];
    }];

    [self performRequest:userRequest withParser:responseParser completion:handler];
}

- (void)unsubscribeFromChannels:(NSArray<NSString *> *)channels withPresence:(BOOL)presence {
    [self.logger warnWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
        return [PNStringLogEntry entryWithMessage:@"This method deprecated. Please use '-unsubscribWithRequest:' "
                "method instead."];
    }];
    
    [self unsubscribeFromChannels:channels groups:nil withPresence:presence queryParameters:nil completion:nil];
}

- (void)unsubscribeFromChannelGroups:(NSArray<NSString *> *)groups withPresence:(BOOL)presence {
    [self.logger warnWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
        return [PNStringLogEntry entryWithMessage:@"This method deprecated. Please use '-unsubscribWithRequest:' "
                "method instead."];
    }];
    
    [self unsubscribeFromChannels:nil groups:groups withPresence:presence queryParameters:nil completion:nil];
}

- (void)unsubscribeFromChannels:(NSArray<NSString *> *)channels
                         groups:(NSArray<NSString *> *)groups
                   withPresence:(BOOL)shouldObservePresence
                queryParameters:(NSDictionary *)queryParameters
                     completion:(PNSubscriberCompletionBlock)block {
    PNPresenceLeaveRequest *request = [PNPresenceLeaveRequest requestWithChannels:channels ?: @[]
                                                                    channelGroups:groups ?: @[]];
    request.arbitraryQueryParameters = queryParameters;
    request.observePresence = shouldObservePresence;

    if (request.channels.count || request.channelGroups.count) {
        [self cancelSubscribeOperations];
        [self.subscriberManager unsubscribeWithRequest:request completion:block];
    } else if (block) {
        pn_dispatch_async(self.callbackQueue, ^{
            block(nil);
        });
    }
}

- (void)unsubscribeFromPresenceChannels:(NSArray<NSString *> *)channels {
    [self.logger warnWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
        return [PNStringLogEntry entryWithMessage:@"This method deprecated. Please use '-unsubscribWithRequest:' "
                "method instead."];
    }];
    
    [self unsubscribeFromPresenceChannels:channels withQueryParameters:nil];
}

- (void)unsubscribeFromPresenceChannels:(NSArray<NSString *> *)channels withQueryParameters:(NSDictionary *)query {
    PNPresenceLeaveRequest *request = [PNPresenceLeaveRequest requestWithPresenceChannels:channels channelGroups:nil];
    request.arbitraryQueryParameters = query;

    [self unsubscribeWithRequest:request];
}

- (void)unsubscribeFromAll {
    [self unsubscribeFromAllWithCompletion:nil];
}

- (void)unsubscribeFromAllWithCompletion:(PNStatusBlock)block {
    [self unsubscribeFromAllWithQueryParameters:nil completion:block];
}

- (void)unsubscribeFromAllWithQueryParameters:(NSDictionary *)queryParameters completion:(PNStatusBlock)block {
    [self.logger debugWithLocation:@"PubNub" andMessageFactory:^PNLogEntry * {
        return [PNStringLogEntry entryWithMessage:@"Unsubscribe all channels and groups"];
    }];
    
    [self cancelSubscribeOperations];
    [self.subscriberManager unsubscribeFromAllWithQueryParameters:queryParameters completion:block];
}


#pragma mark - Misc

- (void)cancelSubscribeOperations {
    [self.subscriptionNetwork requestsWithBlock:^(NSArray<PNTransportRequest *> *requests) {
        for(PNTransportRequest *request in requests) {
            dispatch_block_t cancelBlock = request.cancel;
            if ([request.path hasPrefix:kPNSubscribeAPIPrefix] && cancelBlock) cancelBlock();
        }
    }];
}

#pragma mark -


@end
