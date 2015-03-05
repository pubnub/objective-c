//
//  PNObservationCenter.h
//  pubnub
//
//  Observation center will allow to subscribe
//  for particular events with handle block
//  (block will be provided by subscriber)
//
//
//  Created by Sergey Mamontov.
//
//

#import "PNObservationCenter+Protected.h"
#import "NSNotification+PNPrivateAdditions.h"
#import "PNMessagesHistory+Protected.h"
#import "PNChannelGroupChange.h"
#import "NSObject+PNAdditions.h"
#import "PNHereNow+Protected.h"
#import "PNLogger+Protected.h"
#import "PNError+Protected.h"
#import "PNNotifications.h"
#import "PNLoggerSymbols.h"
#import "PNChannelGroup.h"
#import "PNWhereNow.h"
#import "PNChannel.h"
#import "PNClient.h"
#import "PNHelper.h"
#import "PNMacro.h"
#import "PubNub.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub observation center must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Static

/**
 @brief Key under which stored all general callbacks w/o particular callback token.

 @since 3.7.9
 */
static NSString * const kPNObserverGeneralCallbacks = @"general";

// Stores reference on shared observation center instance
static PNObservationCenter *_sharedInstance = nil;
static dispatch_once_t onceToken;


struct PNObservationEventsStruct {

    __unsafe_unretained NSString *clientConnectionStateChange;
    __unsafe_unretained NSString *clientStateRetrieval;
    __unsafe_unretained NSString *clientStateUpdate;
    __unsafe_unretained NSString *clientChannelGroupsRequest;
    __unsafe_unretained NSString *clientChannelGroupNamespacesRequest;
    __unsafe_unretained NSString *clientChannelGroupNamespaceRemoval;
    __unsafe_unretained NSString *clientChannelGroupRemoval;
    __unsafe_unretained NSString *clientChannelsForGroupRequest;
    __unsafe_unretained NSString *clientChannelsAdditionToGroup;
    __unsafe_unretained NSString *clientChannelsRemovalFromGroup;
    __unsafe_unretained NSString *clientSubscriptionOnChannels;
    __unsafe_unretained NSString *clientUnsubscribeFromChannels;
    __unsafe_unretained NSString *clientPresenceEnableOnChannels;
    __unsafe_unretained NSString *clientPresenceDisableOnChannels;
    __unsafe_unretained NSString *clientPushNotificationEnabling;
    __unsafe_unretained NSString *clientPushNotificationDisabling;
    __unsafe_unretained NSString *clientPushNotificationEnabledChannelsRetrieval;
    __unsafe_unretained NSString *clientPushNotificationRemovalForAllChannels;
    __unsafe_unretained NSString *clientTimeTokenReceivingComplete;
    __unsafe_unretained NSString *clientAccessRightsChange;
    __unsafe_unretained NSString *clientAccessRightsAudit;
    __unsafe_unretained NSString *clientMessageSendCompletion;
    __unsafe_unretained NSString *clientReceivedMessage;
    __unsafe_unretained NSString *clientReceivedPresenceEvent;
    __unsafe_unretained NSString *clientReceivedHistory;
    __unsafe_unretained NSString *clientReceivedParticipantsList;
    __unsafe_unretained NSString *clientParticipantChannelsList;
};

struct PNObservationObserverDataStruct {

    __unsafe_unretained NSString *observer;
    __unsafe_unretained NSString *observerCallbackBlock;
};

static struct PNObservationEventsStruct PNObservationEvents = {

    .clientConnectionStateChange = @"clientConnectionStateChangeEvent",
    .clientStateRetrieval = @"clientStateRetrieveEvent",
    .clientStateUpdate = @"clientStateUpdateEvent",
    .clientChannelGroupsRequest = @"clientChannelGroupsRequest",
    .clientChannelGroupNamespacesRequest = @"clientChannelGroupNamespacesRequest",
    .clientChannelGroupNamespaceRemoval = @"clientChannelGroupNamespaceRemoval",
    .clientChannelGroupRemoval = @"clientChannelGroupRemoval",
    .clientChannelsForGroupRequest = @"clientChannelsForGroupRequest",
    .clientChannelsAdditionToGroup = @"clientChannelsAdditionToGroup",
    .clientChannelsRemovalFromGroup = @"clientChannelsRemovalFromGroup",
    .clientTimeTokenReceivingComplete = @"clientReceivingTimeTokenEvent",
    .clientSubscriptionOnChannels = @"clientSubscribtionOnChannelsEvent",
    .clientUnsubscribeFromChannels = @"clientUnsubscribeFromChannelsEvent",
    .clientPresenceEnableOnChannels = @"clientPresenceEnableOnChannels",
    .clientPresenceDisableOnChannels = @"clientPresenceDisableOnChannels",
    .clientPushNotificationEnabling = @"clientPushNotificationEnabling",
    .clientPushNotificationDisabling = @"clientPushNotificationDisabling",
    .clientPushNotificationEnabledChannelsRetrieval = @"clientPushNotificationEnabledChannelsRetrieval",
    .clientPushNotificationRemovalForAllChannels = @"clientPushNotificationRemovalForAllChannels",
    .clientAccessRightsChange = @"clientAccessRightsChange",
    .clientAccessRightsAudit = @"clientAccessRightsAudit",
    .clientMessageSendCompletion = @"clientMessageSendCompletionEvent",
    .clientReceivedMessage = @"clientReceivedMessageEvent",
    .clientReceivedPresenceEvent = @"clientReceivedPresenceEvent",
    .clientReceivedHistory = @"clientReceivedHistoryEvent",
    .clientReceivedParticipantsList = @"clientReceivedParticipantsListEvent",
    .clientParticipantChannelsList = @"clientParticipantChannelsProcessingEvent"
};

static struct PNObservationObserverDataStruct PNObservationObserverData = {

    .observer = @"observer",
    .observerCallbackBlock = @"observerCallbackBlock"
};


#pragma mark - Private interface methods

@interface PNObservationCenter ()


#pragma mark - Properties

/**
 Stores mapped observers to events wich they want to track and execution block provided by subscriber.
 */
@property (nonatomic, strong) NSMutableDictionary *observers;

/**
 Stores mapped observers to events wich they want to track and execution block provided by subscriber.
 This is FIFO observer type which means that as soon as event will occur observer will be removed from list.
 */
@property (nonatomic, strong) NSMutableDictionary *oneTimeObservers;

/**
 Stores reference on default observer which should be used by simplified observation methods.
 */
@property (nonatomic, pn_desired_weak) id defaultObserver;

/**
 @brief      Stores reference on list of object returned by NSNotificationCenter during subscription
             on notifications.
 @discussion Will be used to unsubscribe from notifications at the end of \b PNObservationCenter
             life-cycle.

 @since 3.7.9
 */
@property (nonatomic, strong) NSMutableArray *notifications;


#pragma mark - Instance methods

/**
 * Helper methods which will create collection for specified
 * event name if it doesn't exist or return existing.
 */
- (NSMutableArray *)persistentObserversForEvent:(NSString *)eventName;

- (id)oneTimeObserversForEvent:(NSString *)eventName withCallbackToken:(NSString *)callbackToken;

- (void)removeOneTimeObserversForEvent:(NSString *)eventName
                      andCallbackToken:(NSString *)callbackToken;

/**
 * Managing observation list
 */
- (void)addObserver:(id)observer forEvent:(NSString *)eventName oneTimeEvent:(BOOL)isOneTimeEvent
          withBlock:(id)block andToken:(NSString *)callbackToken;

- (void)removeObserver:(id)observer forEvent:(NSString *)eventName oneTimeEvent:(BOOL)isOneTimeEvent withCallbackToken:(NSString *)callbackToken;


#pragma mark - Handler methods

- (void)handleClientConnectionStateChange:(NSNotification *)notification;
- (void)handleClientStateRetrieveProcess:(NSNotification *)notification;
- (void)handleClientStateUpdateProcess:(NSNotification *)notification;
- (void)handleClientSubscriptionProcess:(NSNotification *)notification;
- (void)handleClientChannelGroupsRequestProcess:(NSNotification *)notification;
- (void)handleClientChannelGroupNamespacesRequestProcess:(NSNotification *)notification;
- (void)handleClientChannelGroupNamespacesRemovalProcess:(NSNotification *)notification;
- (void)handleClientChannelGroupRemovalProcess:(NSNotification *)notification;
- (void)handleClientChannelsForGroupRequestProcess:(NSNotification *)notification;
- (void)handleClientGroupChannelsListModificationProcess:(NSNotification *)notification;
- (void)handleClientUnsubscriptionProcess:(NSNotification *)notification;
- (void)handleClientPresenceObservationEnablingProcess:(NSNotification *)notification;
- (void)handleClientPresenceObservationDisablingProcess:(NSNotification *)notification;
- (void)handleClientPushNotificationStateChange:(NSNotification *)notification;
- (void)handleClientPushNotificationRemoveProcess:(NSNotification *)notification;
- (void)handleClientPushNotificationEnabledChannels:(NSNotification *)notification;
- (void)handleClientMessageProcessingStateChange:(NSNotification *)notification;
- (void)handleClientDidReceiveMessage:(NSNotification *)notification;
- (void)handleClientDidReceivePresenceEvent:(NSNotification *)notification;
- (void)handleClientMessageHistoryProcess:(NSNotification *)notification;
- (void)handleClientChannelAccessRightsChange:(NSNotification *)notification;
- (void)handleClientChannelAccessRightsRequest:(NSNotification *)notification;
- (void)handleClientHereNowProcess:(NSNotification *)notification;
- (void)handleClientWhereNowProcess:(NSNotification *)notification;
- (void)handleClientCompletedTimeTokenProcessing:(NSNotification *)notification;


#pragma mark - Misc methods

/**
 * Retrieve full list of observers for specified event name
 */
- (void)observersForEvent:(NSString *)eventName withCallbackToken:(NSString *)callbackToken andBlock:(void (^)(NSMutableArray *observers))fetchCompletionBlock;


@end


#pragma mark - Public interface methods

@implementation PNObservationCenter


#pragma mark Class methods

+ (PNObservationCenter *)defaultCenter {

    dispatch_once(&onceToken, ^{
        
        _sharedInstance = [self new];
    });
    
    
    return _sharedInstance;
}

+ (PNObservationCenter *)observationCenterWithDefaultObserver:(id)defaultObserver; {
    
    return [[self alloc] initWithDefaultObserver:defaultObserver];
}

+ (void)resetCenter {
    
    [[self defaultCenter] pn_dispatchBlock:^{
        
        // Resetting one time observers (they bound to PubNub client instance)
        [[self defaultCenter].oneTimeObservers removeAllObjects];
    }];
}

#pragma mark - Instance methods

- (id)init {
    
    return [self initWithDefaultObserver:nil];
}

- (id)initWithDefaultObserver:(id)defaultObserver {
    
    // Check whether initialization was successful or not
    if((self = [super init])) {
        
        self.observers = [NSMutableDictionary dictionary];
        self.oneTimeObservers = [NSMutableDictionary dictionary];
        self.notifications = [NSMutableArray array];
        self.defaultObserver = (defaultObserver ? defaultObserver : [PubNub sharedInstance]);
        [self pn_setupPrivateSerialQueueWithIdentifier:@"observer" andPriority:DISPATCH_QUEUE_PRIORITY_DEFAULT];

        __block __pn_desired_weak __typeof__(self) weakSelf = self;
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        void(^handleBlock)(SEL, NSNotification *) = ^(SEL handlerSelector,
                                                      NSNotification *notification){

            __strong __typeof__(self) strongSelf = weakSelf;
            [strongSelf pn_dispatchBlock:^{
                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [strongSelf performSelector:handlerSelector withObject:notification];
                #pragma clang diagnostic pop
            }];
        };
        void(^addObserver)(SEL, NSString *) = ^(SEL handlerSelector, NSString *notificationName) {

            NSString *privateNotification = [NSNotification pn_privateNotificationNameFrom:notificationName];
            id observer = [notificationCenter addObserverForName:privateNotification
                                                          object:self.defaultObserver queue:nil
                                                      usingBlock:^(NSNotification *notification) {

                handleBlock(handlerSelector, (NSNotification *)notification);
            }];

            [self.notifications addObject:observer];
        };

        addObserver(@selector(handleClientConnectionStateChange:), kPNClientDidConnectToOriginNotification);
        addObserver(@selector(handleClientConnectionStateChange:), kPNClientDidDisconnectFromOriginNotification);
        addObserver(@selector(handleClientConnectionStateChange:), kPNClientConnectionDidFailWithErrorNotification);

        addObserver(@selector(handleClientStateRetrieveProcess:), kPNClientDidReceiveClientStateNotification);
        addObserver(@selector(handleClientStateRetrieveProcess:), kPNClientStateRetrieveDidFailWithErrorNotification);
        addObserver(@selector(handleClientStateUpdateProcess:), kPNClientDidUpdateClientStateNotification);
        addObserver(@selector(handleClientStateUpdateProcess:), kPNClientStateUpdateDidFailWithErrorNotification);

        // Handle channel registry events
        addObserver(@selector(handleClientChannelGroupsRequestProcess:), kPNClientChannelGroupsRequestCompleteNotification);
        addObserver(@selector(handleClientChannelGroupsRequestProcess:), kPNClientChannelGroupsRequestDidFailWithErrorNotification);
        addObserver(@selector(handleClientChannelGroupNamespacesRequestProcess:), kPNClientChannelGroupNamespacesRequestCompleteNotification);
        addObserver(@selector(handleClientChannelGroupNamespacesRequestProcess:), kPNClientChannelGroupNamespacesRequestDidFailWithErrorNotification);
        addObserver(@selector(handleClientChannelGroupNamespacesRemovalProcess:), kPNClientChannelGroupNamespaceRemovalCompleteNotification);
        addObserver(@selector(handleClientChannelGroupNamespacesRemovalProcess:), kPNClientChannelGroupNamespaceRemovalDidFailWithErrorNotification);
        addObserver(@selector(handleClientChannelGroupRemovalProcess:), kPNClientChannelGroupRemovalCompleteNotification);
        addObserver(@selector(handleClientChannelGroupRemovalProcess:), kPNClientChannelGroupRemovalDidFailWithErrorNotification);
        addObserver(@selector(handleClientChannelsForGroupRequestProcess:), kPNClientChannelsForGroupRequestCompleteNotification);
        addObserver(@selector(handleClientChannelsForGroupRequestProcess:), kPNClientChannelsForGroupRequestDidFailWithErrorNotification);
        addObserver(@selector(handleClientGroupChannelsListModificationProcess:), kPNClientGroupChannelsAdditionCompleteNotification);
        addObserver(@selector(handleClientGroupChannelsListModificationProcess:), kPNClientGroupChannelsAdditionDidFailWithErrorNotification);
        addObserver(@selector(handleClientGroupChannelsListModificationProcess:), kPNClientGroupChannelsRemovalCompleteNotification);
        addObserver(@selector(handleClientGroupChannelsListModificationProcess:), kPNClientGroupChannelsRemovalDidFailWithErrorNotification);
        
        // Handle subscription events
        addObserver(@selector(handleClientSubscriptionProcess:), kPNClientSubscriptionDidCompleteNotification);
        addObserver(@selector(handleClientSubscriptionProcess:), kPNClientSubscriptionDidCompleteOnClientIdentifierUpdateNotification);
        addObserver(@selector(handleClientSubscriptionProcess:), kPNClientSubscriptionWillRestoreNotification);
        addObserver(@selector(handleClientSubscriptionProcess:), kPNClientSubscriptionDidRestoreNotification);
        addObserver(@selector(handleClientSubscriptionProcess:), kPNClientSubscriptionDidFailNotification);
        addObserver(@selector(handleClientSubscriptionProcess:), kPNClientSubscriptionDidFailOnClientIdentifierUpdateNotification);
        addObserver(@selector(handleClientUnsubscriptionProcess:), kPNClientUnsubscriptionDidCompleteNotification);
        addObserver(@selector(handleClientUnsubscriptionProcess:), kPNClientUnsubscriptionDidCompleteOnClientIdentifierUpdateNotification);
        addObserver(@selector(handleClientUnsubscriptionProcess:), kPNClientUnsubscriptionDidFailNotification);
        addObserver(@selector(handleClientUnsubscriptionProcess:), kPNClientUnsubscriptionDidFailOnClientIdentifierUpdateNotification);

        // Handle presence events
        addObserver(@selector(handleClientPresenceObservationEnablingProcess:), kPNClientPresenceEnablingDidCompleteNotification);
        addObserver(@selector(handleClientPresenceObservationEnablingProcess:), kPNClientPresenceEnablingDidFailNotification);
        addObserver(@selector(handleClientPresenceObservationDisablingProcess:), kPNClientPresenceDisablingDidCompleteNotification);
        addObserver(@selector(handleClientPresenceObservationDisablingProcess:), kPNClientPresenceDisablingDidFailNotification);

        // Handle push notification state changing events
        addObserver(@selector(handleClientPushNotificationStateChange:), kPNClientPushNotificationEnableDidCompleteNotification);
        addObserver(@selector(handleClientPushNotificationStateChange:), kPNClientPushNotificationEnableDidFailNotification);
        addObserver(@selector(handleClientPushNotificationStateChange:), kPNClientPushNotificationDisableDidCompleteNotification);
        addObserver(@selector(handleClientPushNotificationStateChange:), kPNClientPushNotificationDisableDidFailNotification);

        // Handle push notification remove events
        addObserver(@selector(handleClientPushNotificationRemoveProcess:), kPNClientPushNotificationRemoveDidCompleteNotification);
        addObserver(@selector(handleClientPushNotificationRemoveProcess:), kPNClientPushNotificationRemoveDidFailNotification);

        // Handle push notification enabled channels retrieve events
        addObserver(@selector(handleClientPushNotificationEnabledChannels:), kPNClientPushNotificationChannelsRetrieveDidCompleteNotification);
        addObserver(@selector(handleClientPushNotificationEnabledChannels:), kPNClientPushNotificationChannelsRetrieveDidFailNotification);

        // Handle access rights change events
        addObserver(@selector(handleClientChannelAccessRightsChange:), kPNClientAccessRightsChangeDidCompleteNotification);
        addObserver(@selector(handleClientChannelAccessRightsChange:), kPNClientAccessRightsChangeDidFailNotification);
        
        // Handle access rights audit events
        addObserver(@selector(handleClientChannelAccessRightsRequest:), kPNClientAccessRightsAuditDidCompleteNotification);
        addObserver(@selector(handleClientChannelAccessRightsRequest:), kPNClientAccessRightsAuditDidFailNotification);

        // Handle time token events
        addObserver(@selector(handleClientCompletedTimeTokenProcessing:), kPNClientDidReceiveTimeTokenNotification);
        addObserver(@selector(handleClientCompletedTimeTokenProcessing:), kPNClientDidFailTimeTokenReceiveNotification);

        // Handle message processing events
        addObserver(@selector(handleClientMessageProcessingStateChange:), kPNClientWillSendMessageNotification);
        addObserver(@selector(handleClientMessageProcessingStateChange:), kPNClientDidSendMessageNotification);
        addObserver(@selector(handleClientMessageProcessingStateChange:), kPNClientMessageSendingDidFailNotification);
        
        // Handle messages/presence event arrival
        addObserver(@selector(handleClientDidReceiveMessage:), kPNClientDidReceiveMessageNotification);
        addObserver(@selector(handleClientDidReceivePresenceEvent:), kPNClientDidReceivePresenceEventNotification);
        
        // Handle message history events arrival
        addObserver(@selector(handleClientMessageHistoryProcess:), kPNClientDidReceiveMessagesHistoryNotification);
        addObserver(@selector(handleClientMessageHistoryProcess:), kPNClientHistoryDownloadFailedWithErrorNotification);
        
        // Handle participants list arrival
        addObserver(@selector(handleClientHereNowProcess:), kPNClientDidReceiveParticipantsListNotification);
        addObserver(@selector(handleClientHereNowProcess:), kPNClientParticipantsListDownloadFailedWithErrorNotification);
        addObserver(@selector(handleClientWhereNowProcess:), kPNClientDidReceiveParticipantChannelsListNotification);
        addObserver(@selector(handleClientWhereNowProcess:), kPNClientParticipantChannelsListDownloadFailedWithErrorNotification);
    }
    
    
    return self;
}

- (void)checkSubscribedOnClientStateChange:(id)observer
                                 withBlock:(void (^)(BOOL observing))checkCompletionBlock {

    [self pn_dispatchBlock:^{

        id observersData = [self oneTimeObserversForEvent:PNObservationEvents.clientConnectionStateChange
                                        withCallbackToken:nil];
        BOOL isSubscribed = NO;
        id  eventObserver = [observersData valueForKey:PNObservationObserverData.observer];
        if (observer) {

            if ([observersData isKindOfClass:[NSDictionary class]]) {

                isSubscribed = [eventObserver isEqualToString:observer];
            }
            else {

                isSubscribed = [(NSArray *)eventObserver containsObject:observer];
            }
        }

        if (checkCompletionBlock) {

            checkCompletionBlock(isSubscribed);
        }
    }];
}

- (void)changeClientCallbackToken:(NSString *)oldCallbackToken to:(NSString *)callbackToken {

    [self pn_dispatchBlock:^{

        NSArray *allEvents = [self.oneTimeObservers allValues];
        [allEvents enumerateObjectsUsingBlock:^(NSMutableDictionary *eventSubscribers,
                                                NSUInteger eventSubscribersIdx,
                                                BOOL *eventSubscribersEnumeratorStop) {

            if ([eventSubscribers objectForKey:oldCallbackToken]) {

                id callback = [eventSubscribers objectForKey:oldCallbackToken];
                [eventSubscribers removeObjectForKey:oldCallbackToken];
                [eventSubscribers setValue:callback forKey:callbackToken];
                *eventSubscribersEnumeratorStop = YES;
            }
        }];
    }];
}

- (void)removeClientAsObserver {

    [self pn_dispatchBlock:^{

        [self.oneTimeObservers removeAllObjects];
    }];
}

- (void)removeOneTimeObserversForEvent:(NSString *)eventName
                      andCallbackToken:(NSString *)callbackToken {
    
    [self pn_dispatchBlock:^{
        
        if (!callbackToken) {
            
            [[[self.oneTimeObservers valueForKey:eventName] valueForKey:kPNObserverGeneralCallbacks] removeAllObjects];
        }
        else {
            
            [[self.oneTimeObservers valueForKey:eventName] removeObjectForKey:callbackToken];
        }
    }];
}

- (void)addObserver:(id)observer forEvent:(NSString *)eventName oneTimeEvent:(BOOL)isOneTimeEvent
          withBlock:(id)block andToken:(NSString *)callbackToken {

    [self pn_dispatchBlock:^{

        id blockCopy = [block copy];
        NSMutableDictionary *observerData = [@{PNObservationObserverData.observer : observer,
                                               PNObservationObserverData.observerCallbackBlock : blockCopy} mutableCopy];

        if (isOneTimeEvent && callbackToken) {

            [self oneTimeObserversForEvent:eventName withCallbackToken:callbackToken];

            NSMutableDictionary *eventObservers = [self.oneTimeObservers valueForKey:eventName];
            [eventObservers setValue:observerData forKey:callbackToken];
        }
        else {

            NSMutableArray *observers = nil;
            if (isOneTimeEvent) {

                observers = [self oneTimeObserversForEvent:eventName withCallbackToken:nil];
            }
            else {

                observers = [self persistentObserversForEvent:eventName];
            }

            [observers addObject:observerData];
        }
    }];
}

- (void)removeObserver:(id)observer forEvent:(NSString *)eventName oneTimeEvent:(BOOL)isOneTimeEvent
     withCallbackToken:(NSString *)callbackToken {

    [self pn_dispatchBlock:^{

        if (isOneTimeEvent && callbackToken) {

            [[self.oneTimeObservers valueForKey:eventName] removeObjectForKey:callbackToken];
        }
        else {

            // Retrieve list of observing requests with specified observer
            NSString *filterFormat = [NSString stringWithFormat:@"%@ = %%@", PNObservationObserverData.observer];
            NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:filterFormat, observer];

            NSMutableArray *observers = nil;
            if (isOneTimeEvent) {

                observers = [self oneTimeObserversForEvent:eventName withCallbackToken:nil];
            }
            else {

                observers = [self persistentObserversForEvent:eventName];
            }
            NSArray *filteredObservers = [observers filteredArrayUsingPredicate:filterPredicate];
            if ([filteredObservers count] > 0) {

                // Removing first occurrence of observer request in list
                [observers removeObject:[filteredObservers objectAtIndex:0]];
            }
        }


    }];
}


#pragma mark - Client connection state observation

- (void)addClientConnectionStateObserver:(id)observer
                       withCallbackBlock:(PNClientConnectionStateChangeBlock)callbackBlock {

    [self addClientConnectionStateObserver:observer oneTimeEvent:NO withCallbackBlock:callbackBlock];
}

- (void)removeClientConnectionStateObserver:(id)observer {

    [self removeClientConnectionStateObserver:observer oneTimeEvent:NO];
}

- (void)addClientConnectionStateObserver:(id)observer oneTimeEvent:(BOOL)isOneTimeEventObserver
                       withCallbackBlock:(PNClientConnectionStateChangeBlock)callbackBlock {

    [self addObserver:observer forEvent:PNObservationEvents.clientConnectionStateChange
         oneTimeEvent:isOneTimeEventObserver withBlock:callbackBlock andToken:nil];
}

- (void)removeClientConnectionStateObserver:(id)observer oneTimeEvent:(BOOL)isOneTimeEventObserver {

    [self removeObserver:observer forEvent:PNObservationEvents.clientConnectionStateChange oneTimeEvent:isOneTimeEventObserver withCallbackToken:nil];
}


#pragma mark - Client state retrieval / update observation

- (void)addClientStateRequestObserver:(id)observer
                            withBlock:(PNClientStateRetrieveHandlingBlock)handleBlock {

    [self addObserver:observer forEvent:PNObservationEvents.clientStateRetrieval
         oneTimeEvent:NO withBlock:handleBlock andToken:nil];
}

- (void)removeClientStateRequestObserver:(id)observer {

    [self removeObserver:observer forEvent:PNObservationEvents.clientStateRetrieval oneTimeEvent:NO withCallbackToken:nil];
}

- (void)addClientStateUpdateObserver:(id)observer
                           withBlock:(PNClientStateUpdateHandlingBlock)handleBlock {

    [self addObserver:observer forEvent:PNObservationEvents.clientStateUpdate
         oneTimeEvent:NO withBlock:handleBlock andToken:nil];
}

- (void)removeClientStateUpdateObserver:(id)observer {

    [self removeObserver:observer forEvent:PNObservationEvents.clientStateUpdate oneTimeEvent:NO withCallbackToken:nil];
}

- (void)addClientAsStateRequestObserverWithToken:(NSString *)callbackToken
                                        andBlock:(PNClientStateRetrieveHandlingBlock)handlerBlock {

    [self addObserver:self.defaultObserver forEvent:PNObservationEvents.clientStateRetrieval
         oneTimeEvent:YES withBlock:handlerBlock andToken:callbackToken];
}

- (void)addClientAsStateUpdateObserverWithToken:(NSString *)callbackToken
                                       andBlock:(PNClientStateUpdateHandlingBlock)handlerBlock {

    [self addObserver:self.defaultObserver forEvent:PNObservationEvents.clientStateUpdate
         oneTimeEvent:YES withBlock:handlerBlock andToken:callbackToken];
}


#pragma mark - Client channel groups observation

- (void)addClientAsChannelGroupsRequestObserverWithToken:(NSString *)callbackToken
                                                andBlock:(PNClientChannelGroupsRequestHandlingBlock)callbackBlock {

    [self addObserver:self.defaultObserver forEvent:PNObservationEvents.clientChannelGroupsRequest
         oneTimeEvent:YES withBlock:callbackBlock andToken:callbackToken];
}

- (void)addChannelGroupsRequestObserver:(id)observer
                      withCallbackBlock:(PNClientChannelGroupsRequestHandlingBlock)callbackBlock {
    
    [self addObserver:observer forEvent:PNObservationEvents.clientChannelGroupsRequest
         oneTimeEvent:NO withBlock:callbackBlock andToken:nil];
}

- (void)removeChannelGroupsRequestObserver:(id)observer {
    
    [self removeObserver:observer forEvent:PNObservationEvents.clientChannelGroupsRequest
            oneTimeEvent:NO withCallbackToken:nil];
}

- (void)addClientAsChannelGroupNamespacesRequestObserverWithToken:(NSString *)callbackToken
                                                         andBlock:(PNClientChannelGroupNamespacesRequestHandlingBlock)callbackBlock {

    [self addObserver:self.defaultObserver
             forEvent:PNObservationEvents.clientChannelGroupNamespacesRequest oneTimeEvent:YES
            withBlock:callbackBlock andToken:callbackToken];
}

- (void)addChannelGroupNamespacesRequestObserver:(id)observer
                               withCallbackBlock:(PNClientChannelGroupNamespacesRequestHandlingBlock)callbackBlock {
    
    [self addObserver:observer forEvent:PNObservationEvents.clientChannelGroupNamespacesRequest
         oneTimeEvent:NO withBlock:callbackBlock andToken:nil];
}

- (void)removeChannelGroupNamespacesRequestObserver:(id)observer {
    
    [self removeObserver:observer forEvent:PNObservationEvents.clientChannelGroupNamespacesRequest
            oneTimeEvent:NO withCallbackToken:nil];
}

- (void)addClientAsChannelGroupNamespaceRemovalObserverWithToken:(NSString *)callbackToken
                                                        andBlock:(PNClientChannelGroupNamespaceRemoveHandlingBlock)callbackBlock {

    [self addObserver:self.defaultObserver
             forEvent:PNObservationEvents.clientChannelGroupNamespaceRemoval oneTimeEvent:YES
            withBlock:callbackBlock andToken:callbackToken];
}

- (void)addChannelGroupNamespaceRemovalObserver:(id)observer
                              withCallbackBlock:(PNClientChannelGroupNamespaceRemoveHandlingBlock)callbackBlock {
    
    [self addObserver:observer forEvent:PNObservationEvents.clientChannelGroupNamespaceRemoval
         oneTimeEvent:NO withBlock:callbackBlock andToken:nil];
}

- (void)removeChannelGroupNamespaceRemovalObserver:(id)observer {
    
    [self removeObserver:observer forEvent:PNObservationEvents.clientChannelGroupNamespaceRemoval
            oneTimeEvent:NO withCallbackToken:nil];
}

- (void)addClientAsChannelGroupRemovalObserverWithToken:(NSString *)callbackToken
                                               andBlock:(PNClientChannelGroupRemoveHandlingBlock)callbackBlock {

    [self addObserver:self.defaultObserver forEvent:PNObservationEvents.clientChannelGroupRemoval
         oneTimeEvent:YES withBlock:callbackBlock andToken:callbackToken];
}

- (void)addChannelGroupRemovalObserver:(id)observer
                     withCallbackBlock:(PNClientChannelGroupRemoveHandlingBlock)callbackBlock {
    
    [self addObserver:observer forEvent:PNObservationEvents.clientChannelGroupRemoval
         oneTimeEvent:NO withBlock:callbackBlock andToken:nil];
}

- (void)removeChannelGroupRemovalObserver:(id)observer {
    
    [self removeObserver:observer forEvent:PNObservationEvents.clientChannelGroupRemoval
            oneTimeEvent:NO withCallbackToken:nil];
}

- (void)addClientAsChannelsForGroupRequestObserverWithToken:(NSString *)callbackToken
                                                   andBlock:(PNClientChannelsForGroupRequestHandlingBlock)callbackBlock {

    [self addObserver:self.defaultObserver
             forEvent:PNObservationEvents.clientChannelsForGroupRequest oneTimeEvent:YES
            withBlock:callbackBlock andToken:callbackToken];
}

- (void)addChannelsForGroupRequestObserver:(id)observer
                         withCallbackBlock:(PNClientChannelsForGroupRequestHandlingBlock)callbackBlock {
    
    [self addObserver:observer forEvent:PNObservationEvents.clientChannelsForGroupRequest
         oneTimeEvent:NO withBlock:callbackBlock andToken:nil];
}

- (void)removeChannelsForGroupRequestObserver:(id)observer {
    
    [self removeObserver:observer forEvent:PNObservationEvents.clientChannelsForGroupRequest
            oneTimeEvent:NO withCallbackToken:nil];
}

- (void)addClientAsChannelsAdditionToGroupObserverWithToken:(NSString *)callbackToken
                                                   andBlock:(PNClientChannelsAdditionToGroupHandlingBlock)callbackBlock {

    [self addObserver:self.defaultObserver
             forEvent:PNObservationEvents.clientChannelsAdditionToGroup oneTimeEvent:YES
            withBlock:callbackBlock andToken:callbackToken];
}

- (void)addChannelsAdditionToGroupObserver:(id)observer
                         withCallbackBlock:(PNClientChannelsAdditionToGroupHandlingBlock)callbackBlock {
    
    [self addObserver:observer forEvent:PNObservationEvents.clientChannelsAdditionToGroup
         oneTimeEvent:NO withBlock:callbackBlock andToken:nil];
}

- (void)removeChannelsAdditionToGroupObserver:(id)observer {
    
    [self removeObserver:observer forEvent:PNObservationEvents.clientChannelsAdditionToGroup
            oneTimeEvent:NO withCallbackToken:nil];
}

- (void)addClientAsChannelsRemovalFromGroupObserverWithToken:(NSString *)callbackToken
                                                    andBlock:(PNClientChannelsRemovalFromGroupHandlingBlock)callbackBlock {

    [self addObserver:self.defaultObserver
             forEvent:PNObservationEvents.clientChannelsRemovalFromGroup oneTimeEvent:YES
            withBlock:callbackBlock andToken:callbackToken];
}

- (void)addChannelsRemovalFromGroupObserver:(id)observer
                          withCallbackBlock:(PNClientChannelsRemovalFromGroupHandlingBlock)callbackBlock {
    
    [self addObserver:observer forEvent:PNObservationEvents.clientChannelsRemovalFromGroup
         oneTimeEvent:NO withBlock:callbackBlock andToken:nil];
}

- (void)removeChannelsRemovalFromGroupObserver:(id)observer {
    
    [self removeObserver:observer forEvent:PNObservationEvents.clientChannelsRemovalFromGroup
            oneTimeEvent:NO withCallbackToken:nil];
}


#pragma mark - Client channels action/event observation

- (void)addClientAsSubscriptionObserverWithBlock:(PNClientChannelSubscriptionHandlerBlock)handleBlock {

    [self addObserver:self.defaultObserver forEvent:PNObservationEvents.clientSubscriptionOnChannels
         oneTimeEvent:YES withBlock:handleBlock andToken:nil];
}

- (void)addClientChannelSubscriptionStateObserver:(id)observer
                                withCallbackBlock:(PNClientChannelSubscriptionHandlerBlock)callbackBlock {

    [self addObserver:observer forEvent:PNObservationEvents.clientSubscriptionOnChannels
         oneTimeEvent:NO withBlock:callbackBlock andToken:nil];
}

- (void)removeClientAsSubscriptionObserver {

    [self removeObserver:self.defaultObserver
                forEvent:PNObservationEvents.clientSubscriptionOnChannels oneTimeEvent:YES
       withCallbackToken:nil];
}

- (void)removeClientChannelSubscriptionStateObserver:(id)observer {

    [self removeObserver:observer forEvent:PNObservationEvents.clientSubscriptionOnChannels
            oneTimeEvent:NO withCallbackToken:nil];
}

- (void)addClientAsUnsubscribeObserverWithBlock:(PNClientChannelUnsubscriptionHandlerBlock)handleBlock {

    [self addObserver:self.defaultObserver
             forEvent:PNObservationEvents.clientUnsubscribeFromChannels oneTimeEvent:YES
            withBlock:handleBlock andToken:nil];
}

- (void)addClientChannelUnsubscriptionObserver:(id)observer
                             withCallbackBlock:(PNClientChannelUnsubscriptionHandlerBlock)callbackBlock {

    [self addObserver:observer forEvent:PNObservationEvents.clientUnsubscribeFromChannels
         oneTimeEvent:NO withBlock:callbackBlock andToken:nil];
}

- (void)removeClientAsUnsubscribeObserver {

    [self removeObserver:self.defaultObserver
                forEvent:PNObservationEvents.clientUnsubscribeFromChannels oneTimeEvent:YES
       withCallbackToken:nil];
}

- (void)removeClientChannelUnsubscriptionObserver:(id)observer {

    [self removeObserver:observer forEvent:PNObservationEvents.clientUnsubscribeFromChannels
            oneTimeEvent:NO withCallbackToken:nil];
}


#pragma mark - Channels presence enable/disable observers

- (void)addClientAsPresenceEnablingObserverWithBlock:(PNClientPresenceEnableHandlingBlock)handlerBlock {

    [self addObserver:self.defaultObserver
             forEvent:PNObservationEvents.clientPresenceEnableOnChannels oneTimeEvent:YES
            withBlock:handlerBlock andToken:nil];
}

- (void)addClientPresenceEnablingObserver:(id)observer
                        withCallbackBlock:(PNClientPresenceEnableHandlingBlock)handlerBlock {

    [self addObserver:observer forEvent:PNObservationEvents.clientPresenceEnableOnChannels
         oneTimeEvent:NO withBlock:handlerBlock andToken:nil];
}

- (void)removeClientAsPresenceEnabling {

    [self removeObserver:self.defaultObserver
                forEvent:PNObservationEvents.clientPresenceEnableOnChannels oneTimeEvent:YES
       withCallbackToken:nil];
}

- (void)removeClientPresenceEnablingObserver:(id)observer {

    [self removeObserver:observer forEvent:PNObservationEvents.clientPresenceEnableOnChannels
            oneTimeEvent:NO withCallbackToken:nil];
}

- (void)addClientAsPresenceDisablingObserverWithBlock:(PNClientPresenceDisableHandlingBlock)handlerBlock {

    [self addObserver:self.defaultObserver
             forEvent:PNObservationEvents.clientPresenceDisableOnChannels oneTimeEvent:YES
            withBlock:handlerBlock andToken:nil];
}

- (void)addClientPresenceDisablingObserver:(id)observer
                         withCallbackBlock:(PNClientPresenceDisableHandlingBlock)handlerBlock {

    [self addObserver:observer forEvent:PNObservationEvents.clientPresenceDisableOnChannels
         oneTimeEvent:NO withBlock:handlerBlock andToken:nil];
}

- (void)removeClientAsPresenceDisabling {

    [self removeObserver:self.defaultObserver
                forEvent:PNObservationEvents.clientPresenceDisableOnChannels oneTimeEvent:YES
       withCallbackToken:nil];
}

- (void)removeClientPresenceDisablingObserver:(id)observer {

    [self removeObserver:observer forEvent:PNObservationEvents.clientPresenceDisableOnChannels
            oneTimeEvent:NO withCallbackToken:nil];
}


#pragma mark - APNS interaction observation

- (void)addClientAsPushNotificationsEnableObserverWithToken:(NSString *)callbackToken
                                                   andBlock:(PNClientPushNotificationsEnableHandlingBlock)handlerBlock {

    [self addObserver:self.defaultObserver
             forEvent:PNObservationEvents.clientPushNotificationEnabling oneTimeEvent:YES
            withBlock:handlerBlock andToken:callbackToken];
}

- (void)addClientPushNotificationsEnableObserver:(id)observer
                               withCallbackBlock:(PNClientPushNotificationsEnableHandlingBlock)handlerBlock {

    [self addObserver:observer forEvent:PNObservationEvents.clientPushNotificationEnabling
         oneTimeEvent:NO withBlock:handlerBlock andToken:nil];
}

- (void)removeClientPushNotificationsEnableObserver:(id)observer {

    [self removeObserver:observer forEvent:PNObservationEvents.clientPushNotificationEnabling
            oneTimeEvent:NO withCallbackToken:nil];
}

- (void)addClientAsPushNotificationsDisableObserverWithToken:(NSString *)callbackToken
                                                    andBlock:(PNClientPushNotificationsDisableHandlingBlock)handlerBlock {

    [self addObserver:self.defaultObserver
             forEvent:PNObservationEvents.clientPushNotificationDisabling oneTimeEvent:YES
            withBlock:handlerBlock andToken:callbackToken];
}

- (void)addClientPushNotificationsDisableObserver:(id)observer
                                withCallbackBlock:(PNClientPushNotificationsDisableHandlingBlock)handlerBlock {

    [self addObserver:observer forEvent:PNObservationEvents.clientPushNotificationDisabling
         oneTimeEvent:NO withBlock:handlerBlock andToken:nil];
}

- (void)removeClientPushNotificationsDisableObserver:(id)observer {

    [self removeObserver:observer forEvent:PNObservationEvents.clientPushNotificationDisabling
            oneTimeEvent:NO withCallbackToken:nil];
}

- (void)addClientAsPushNotificationsEnabledChannelsObserverWithToken:(NSString *)callbackToken
                                                            andBlock:(PNClientPushNotificationsEnabledChannelsHandlingBlock)handlerBlock {

    [self addObserver:self.defaultObserver
             forEvent:PNObservationEvents.clientPushNotificationEnabledChannelsRetrieval
         oneTimeEvent:YES withBlock:handlerBlock andToken:callbackToken];
}

- (void)addClientPushNotificationsEnabledChannelsObserver:(id)observer
                                        withCallbackBlock:(PNClientPushNotificationsEnabledChannelsHandlingBlock)handlerBlock {

    [self addObserver:observer
             forEvent:PNObservationEvents.clientPushNotificationEnabledChannelsRetrieval
         oneTimeEvent:NO withBlock:handlerBlock andToken:nil];
}

- (void)removeClientPushNotificationsEnabledChannelsObserver:(id)observer {

    [self removeObserver:observer
                forEvent:PNObservationEvents.clientPushNotificationEnabledChannelsRetrieval
            oneTimeEvent:NO withCallbackToken:nil];
}

- (void)addClientAsPushNotificationsRemoveObserverWithToken:(NSString *)callbackToken
                                                   andBlock:(PNClientPushNotificationsRemoveHandlingBlock)handlerBlock {

    [self addObserver:self.defaultObserver
             forEvent:PNObservationEvents.clientPushNotificationRemovalForAllChannels
         oneTimeEvent:YES withBlock:handlerBlock andToken:callbackToken];
}

- (void)addClientPushNotificationsRemoveObserver:(id)observer
                               withCallbackBlock:(PNClientPushNotificationsRemoveHandlingBlock)handlerBlock {

    [self addObserver:observer
             forEvent:PNObservationEvents.clientPushNotificationRemovalForAllChannels
         oneTimeEvent:NO withBlock:handlerBlock andToken:nil];
}

- (void)removeClientPushNotificationsRemoveObserver:(id)observer {

    [self removeObserver:observer
                forEvent:PNObservationEvents.clientPushNotificationRemovalForAllChannels
            oneTimeEvent:NO withCallbackToken:nil];
}


#pragma mark - Time token observation

- (void)addClientAsTimeTokenReceivingObserverWithToken:(NSString *)callbackToken
                                              andBlock:(PNClientTimeTokenReceivingCompleteBlock)callbackBlock {

    [self addObserver:self.defaultObserver
             forEvent:PNObservationEvents.clientTimeTokenReceivingComplete oneTimeEvent:YES
            withBlock:callbackBlock andToken:callbackToken];
}

- (void)addTimeTokenReceivingObserver:(id)observer
                    withCallbackBlock:(PNClientTimeTokenReceivingCompleteBlock)callbackBlock {

    [self addObserver:observer forEvent:PNObservationEvents.clientTimeTokenReceivingComplete
         oneTimeEvent:NO withBlock:callbackBlock andToken:nil];
}

- (void)removeTimeTokenReceivingObserver:(id)observer {

    [self removeObserver:observer forEvent:PNObservationEvents.clientTimeTokenReceivingComplete
            oneTimeEvent:NO withCallbackToken:nil];
}


#pragma mark - Message sending observers

- (void)addClientAsMessageProcessingObserverWithToken:(NSString *)callbackToken
                                             andBlock:(PNClientMessageProcessingBlock)handleBlock {

    [self addObserver:self.defaultObserver forEvent:PNObservationEvents.clientMessageSendCompletion
         oneTimeEvent:YES withBlock:handleBlock andToken:callbackToken];
}

- (void)addMessageProcessingObserver:(id)observer
                           withBlock:(PNClientMessageProcessingBlock)handleBlock {

    [self addObserver:observer forEvent:PNObservationEvents.clientMessageSendCompletion
         oneTimeEvent:NO withBlock:handleBlock andToken:nil];
}

- (void)removeMessageProcessingObserver:(id)observer {

    [self removeObserver:observer forEvent:PNObservationEvents.clientMessageSendCompletion
            oneTimeEvent:NO withCallbackToken:nil];
}

- (void)addMessageReceiveObserver:(id)observer withBlock:(PNClientMessageHandlingBlock)handleBlock {

    [self addObserver:observer forEvent:PNObservationEvents.clientReceivedMessage
         oneTimeEvent:NO withBlock:handleBlock andToken:nil];
}

- (void)removeMessageReceiveObserver:(id)observer {

    [self removeObserver:observer forEvent:PNObservationEvents.clientReceivedMessage
            oneTimeEvent:NO withCallbackToken:nil];
}


#pragma mark - Presence observing

- (void)addPresenceEventObserver:(id)observer
                       withBlock:(PNClientPresenceEventHandlingBlock)handleBlock {

    [self addObserver:observer forEvent:PNObservationEvents.clientReceivedPresenceEvent
         oneTimeEvent:NO withBlock:handleBlock andToken:nil];
}

- (void)removePresenceEventObserver:(id)observer {

    [self removeObserver:observer forEvent:PNObservationEvents.clientReceivedPresenceEvent
            oneTimeEvent:NO withCallbackToken:nil];
}


#pragma mark - History observers

- (void)addClientAsHistoryDownloadObserverWithToken:(NSString *)callbackToken
                                           andBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {

    [self addObserver:self.defaultObserver forEvent:PNObservationEvents.clientReceivedHistory
         oneTimeEvent:YES withBlock:handleBlock andToken:callbackToken];
}

- (void)addMessageHistoryProcessingObserver:(id)observer
                                  withBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {

    [self addObserver:observer forEvent:PNObservationEvents.clientReceivedHistory
         oneTimeEvent:NO withBlock:handleBlock andToken:nil];
}

- (void)removeMessageHistoryProcessingObserver:(id)observer {

    [self removeObserver:observer forEvent:PNObservationEvents.clientReceivedHistory
            oneTimeEvent:NO withCallbackToken:nil];
}


#pragma mark - PAM observer

- (void)addClientAsAccessRightsChangeObserverWithToken:(NSString *)callbackToken
                                              andBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {

    [self addObserver:self.defaultObserver forEvent:PNObservationEvents.clientAccessRightsChange
         oneTimeEvent:YES withBlock:handlerBlock andToken:callbackToken];
}

- (void)addAccessRightsChangeObserver:(id)observer
                            withBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock {
    
    [self addObserver:observer forEvent:PNObservationEvents.clientAccessRightsChange
         oneTimeEvent:NO withBlock:handlerBlock andToken:nil];
}

- (void)removeAccessRightsObserver:(id)observer {
    
    [self removeObserver:observer forEvent:PNObservationEvents.clientAccessRightsChange
            oneTimeEvent:NO withCallbackToken:nil];
}

- (void)addClientAsAccessRightsAuditObserverWithToken:(NSString *)callbackToken
                                             andBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock {

    [self addObserver:self.defaultObserver forEvent:PNObservationEvents.clientAccessRightsAudit
         oneTimeEvent:YES withBlock:handlerBlock andToken:callbackToken];
    
}

- (void)addAccessRightsAuditObserver:(id)observer
                           withBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock {
    
    [self addObserver:observer forEvent:PNObservationEvents.clientAccessRightsAudit oneTimeEvent:NO
            withBlock:handlerBlock andToken:nil];
}

- (void)removeAccessRightsAuditObserver:(id)observer {
    
    [self removeObserver:observer forEvent:PNObservationEvents.clientAccessRightsAudit
            oneTimeEvent:NO withCallbackToken:nil];
}


#pragma mark - Participants observer

- (void)addClientAsParticipantsListDownloadObserverWithToken:(NSString *)callbackToken
                                                    andBlock:(PNClientParticipantsHandlingBlock)handleBlock {

    [self addObserver:self.defaultObserver
             forEvent:PNObservationEvents.clientReceivedParticipantsList oneTimeEvent:YES
            withBlock:handleBlock andToken:callbackToken];

}

- (void)addChannelParticipantsListProcessingObserver:(id)observer
                                           withBlock:(PNClientParticipantsHandlingBlock)handleBlock {

    [self addObserver:observer forEvent:PNObservationEvents.clientReceivedParticipantsList
         oneTimeEvent:NO withBlock:handleBlock andToken:nil];
}

- (void)removeChannelParticipantsListProcessingObserver:(id)observer {

    [self removeObserver:observer forEvent:PNObservationEvents.clientReceivedParticipantsList
            oneTimeEvent:NO withCallbackToken:nil];
}

- (void)addClientAsParticipantChannelsListDownloadObserverWithToken:(NSString *)callbackToken
                                                           andBlock:(PNClientParticipantChannelsHandlingBlock)handleBlock {

    [self addObserver:self.defaultObserver
             forEvent:PNObservationEvents.clientParticipantChannelsList oneTimeEvent:YES
            withBlock:handleBlock andToken:callbackToken];
}

- (void)addClientParticipantChannelsListDownloadObserver:(id)observer
                                               withBlock:(PNClientParticipantChannelsHandlingBlock)handleBlock {

    [self addObserver:observer forEvent:PNObservationEvents.clientParticipantChannelsList
         oneTimeEvent:NO withBlock:handleBlock andToken:nil];
}

- (void)removeClientParticipantChannelsListDownloadObserver:(id)observer {

    [self removeObserver:observer forEvent:PNObservationEvents.clientParticipantChannelsList
            oneTimeEvent:NO withCallbackToken:nil];
}


#pragma mark - Handler methods

- (void)handleClientConnectionStateChange:(NSNotification *)notification {
    
    // Default field values
    BOOL connected = YES;
    PNError *connectionError = nil;
    NSString *origin = nil;

    // Retrieve reference on original notification name.
    NSString *notificationName = [notification pn_notificationName];
    
    if([notificationName isEqualToString:kPNClientDidConnectToOriginNotification] ||
       [notificationName isEqualToString:kPNClientDidDisconnectFromOriginNotification]) {
        
        origin = (NSString *)[notification pn_data];
        connected = [notificationName isEqualToString:kPNClientDidConnectToOriginNotification];
    }
    else if([notificationName isEqualToString:kPNClientConnectionDidFailWithErrorNotification]) {
        
        connected = NO;
        connectionError = (PNError *)[notification pn_data];
        origin = (NSString *)connectionError.associatedObject;
    }

    // Retrieving list of observers (including one time and persistent observers)
    [self observersForEvent:PNObservationEvents.clientConnectionStateChange
          withCallbackToken:[notification pn_callbackToken]
                   andBlock:^(NSMutableArray *observers) {

        // Clean one time observers for specific event
        [self removeOneTimeObserversForEvent:PNObservationEvents.clientConnectionStateChange
                            andCallbackToken:[notification pn_callbackToken]];
        dispatch_async(dispatch_get_main_queue(), ^{

            [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                                    NSUInteger observerDataIdx,
                                                    BOOL *observerDataEnumeratorStop) {

                // Call handling blocks
                PNClientConnectionStateChangeBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
                if (block) {

                    block(origin, connected, connectionError);
                }
            }];
        });
    }];
}

- (void)handleClientStateRetrieveProcess:(NSNotification *)notification {

    PNError *error = nil;
    PNClient *client = nil;

    // Retrieve reference on original notification name.
    NSString *notificationName = [notification pn_notificationName];

    if ([notificationName isEqualToString:kPNClientDidReceiveClientStateNotification]) {

        client = (PNClient *)[notification pn_data];
    }
    else {

        error = (PNError *)[notification pn_data];
        client = (PNClient *)error.associatedObject;
    }

    // Retrieving list of observers (including one time and persistent observers)
    [self observersForEvent:PNObservationEvents.clientStateRetrieval
          withCallbackToken:[notification pn_callbackToken]
                   andBlock:^(NSMutableArray *observers) {

        // Clean one time observers for specific event
        [self removeOneTimeObserversForEvent:PNObservationEvents.clientStateRetrieval
                            andCallbackToken:[notification pn_callbackToken]];
        dispatch_async(dispatch_get_main_queue(), ^{

            [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                                    NSUInteger observerDataIdx,
                                                    BOOL *observerDataEnumeratorStop) {

                // Call handling blocks
                PNClientStateRetrieveHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
                if (block) {

                    block(client, error);
                }
            }];
        });
    }];
}

- (void)handleClientStateUpdateProcess:(NSNotification *)notification {

    PNError *error = nil;
    PNClient *client = nil;

    // Retrieve reference on original notification name.
    NSString *notificationName = [notification pn_notificationName];

    if ([notificationName isEqualToString:kPNClientDidUpdateClientStateNotification]) {

        client = (PNClient *)[notification pn_data];
    }
    else {

        error = (PNError *)[notification pn_data];
        client = (PNClient *)error.associatedObject;
    }

    // Retrieving list of observers (including one time and persistent observers)
    [self observersForEvent:PNObservationEvents.clientStateUpdate
          withCallbackToken:[notification pn_callbackToken]
                   andBlock:^(NSMutableArray *observers) {

        // Clean one time observers for specific event
        [self removeOneTimeObserversForEvent:PNObservationEvents.clientStateUpdate
                            andCallbackToken:[notification pn_callbackToken]];
        dispatch_async(dispatch_get_main_queue(), ^{

            [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                                    NSUInteger observerDataIdx,
                                                    BOOL *observerDataEnumeratorStop) {

                // Call handling blocks
                PNClientStateUpdateHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
                if (block) {

                    block(client, error);
                }
            }];
        });
    }];
}

- (void)handleClientChannelGroupsRequestProcess:(NSNotification *)notification {
    
    NSArray *groups = nil;
    NSString *namespaceName = nil;
    PNError *error = nil;

    // Retrieve reference on original notification name.
    NSString *notificationName = [notification pn_notificationName];
    
    // Check whether arrived notification that channel groups retrieved or not
    if ([notificationName isEqualToString:kPNClientChannelGroupsRequestCompleteNotification]) {
        
        if ([[notification pn_data] isKindOfClass:[NSDictionary class]]) {
            
            namespaceName = [[[notification pn_data] allKeys] lastObject];
            if (namespaceName) {
                
                groups = [[notification pn_data] valueForKey:namespaceName];
            }
        }
        else {
            
            groups = (NSArray *)[notification pn_data];
        }
    }
    else {
        
        error = (PNError *)[notification pn_data];
        namespaceName = error.associatedObject;
    }
    
    // Retrieving list of observers (including one time and persistent observers)
    [self observersForEvent:PNObservationEvents.clientChannelGroupsRequest
          withCallbackToken:[notification pn_callbackToken]
                   andBlock:^(NSMutableArray *observers) {

        // Clean one time observers for specific event
        [self removeOneTimeObserversForEvent:PNObservationEvents.clientChannelGroupsRequest
                            andCallbackToken:[notification pn_callbackToken]];
        dispatch_async(dispatch_get_main_queue(), ^{

            [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                                    NSUInteger observerDataIdx,
                                                    BOOL *observerDataEnumeratorStop) {

                // Call handling blocks
                PNClientChannelGroupsRequestHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
                if (block) {

                    block(namespaceName, groups, error);
                }
            }];
        });
    }];
}

- (void)handleClientChannelGroupNamespacesRequestProcess:(NSNotification *)notification {
    
    NSArray *namespaces = nil;
    PNError *error = nil;

    // Retrieve reference on original notification name.
    NSString *notificationName = [notification pn_notificationName];
    
    // Check whether arrived notification that channel group namespaces retrieved or not
    if ([notificationName isEqualToString:kPNClientChannelGroupNamespacesRequestCompleteNotification]) {
        
        namespaces = (NSArray *)[notification pn_data];
    }
    else {
        
        error = (PNError *)[notification pn_data];
    }
    
    // Retrieving list of observers (including one time and persistent observers)
    [self observersForEvent:PNObservationEvents.clientChannelGroupNamespacesRequest
          withCallbackToken:[notification pn_callbackToken]
                   andBlock:^(NSMutableArray *observers) {

        // Clean one time observers for specific event
        [self removeOneTimeObserversForEvent:PNObservationEvents.clientChannelGroupNamespacesRequest
                            andCallbackToken:[notification pn_callbackToken]];
        dispatch_async(dispatch_get_main_queue(), ^{

            [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                                    NSUInteger observerDataIdx,
                                                    BOOL *observerDataEnumeratorStop) {

                // Call handling blocks
                PNClientChannelGroupNamespacesRequestHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
                if (block) {

                    block(namespaces, error);
                }
            }];
        });
    }];
}

- (void)handleClientChannelGroupNamespacesRemovalProcess:(NSNotification *)notification {
    
    id namespace = nil;
    PNError *error = nil;

    // Retrieve reference on original notification name.
    NSString *notificationName = [notification pn_notificationName];
    
    // Check whether arrived notification that channel group namespace removed or not
    if ([notificationName isEqualToString:kPNClientChannelGroupNamespaceRemovalCompleteNotification]) {
        
        namespace = (NSString *)[notification pn_data];
    }
    else {
        
        error = (PNError *)[notification pn_data];
        namespace = error.associatedObject;
        if ([namespace isKindOfClass:[NSArray class]]) {
            
            namespace = [(NSArray *)namespace lastObject];
        }
    }
    
    // Retrieving list of observers (including one time and persistent observers)
    [self observersForEvent:PNObservationEvents.clientChannelGroupNamespaceRemoval
          withCallbackToken:[notification pn_callbackToken]
                   andBlock:^(NSMutableArray *observers) {

        // Clean one time observers for specific event
        [self removeOneTimeObserversForEvent:PNObservationEvents.clientChannelGroupNamespaceRemoval
                            andCallbackToken:[notification pn_callbackToken]];
        dispatch_async(dispatch_get_main_queue(), ^{

            [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                                    NSUInteger observerDataIdx,
                                                    BOOL *observerDataEnumeratorStop) {

                // Call handling blocks
                PNClientChannelGroupNamespaceRemoveHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
                if (block) {

                    block(namespace, error);
                }
            }];
        });
    }];
}

- (void)handleClientChannelGroupRemovalProcess:(NSNotification *)notification {
    
    id group = nil;
    PNError *error = nil;

    // Retrieve reference on original notification name.
    NSString *notificationName = [notification pn_notificationName];
    
    // Check whether arrived notification that channel group removed or not
    if ([notificationName isEqualToString:kPNClientChannelGroupRemovalCompleteNotification]) {
        
        group = (PNChannelGroup *)[notification pn_data];
    }
    else {
        
        error = (PNError *)[notification pn_data];
        group = error.associatedObject;
        if ([group isKindOfClass:[NSArray class]]) {
            
            group = [(NSArray *)group lastObject];
        }
    }
    
    // Retrieving list of observers (including one time and persistent observers)
    [self observersForEvent:PNObservationEvents.clientChannelGroupRemoval
          withCallbackToken:[notification pn_callbackToken]
                   andBlock:^(NSMutableArray *observers) {

        // Clean one time observers for specific event
        [self removeOneTimeObserversForEvent:PNObservationEvents.clientChannelGroupRemoval
                            andCallbackToken:[notification pn_callbackToken]];
        dispatch_async(dispatch_get_main_queue(), ^{

            [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                                    NSUInteger observerDataIdx,
                                                    BOOL *observerDataEnumeratorStop) {

                // Call handling blocks
                PNClientChannelGroupRemoveHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
                if (block) {

                    block(group, error);
                }
            }];
        });
    }];
}

- (void)handleClientChannelsForGroupRequestProcess:(NSNotification *)notification {
    
    PNChannelGroup *group = nil;
    PNError *error = nil;

    // Retrieve reference on original notification name.
    NSString *notificationName = [notification pn_notificationName];
    
    // Check whether arrived notification that channels list for group retrieved or not
    if ([notificationName isEqualToString:kPNClientChannelsForGroupRequestCompleteNotification]) {
        
        group = (PNChannelGroup *)[notification pn_data];
    }
    else {
        
        error = (PNError *)[notification pn_data];
        group = (PNChannelGroup *)error.associatedObject;
        if ([error.associatedObject isKindOfClass:[NSArray class]]) {
            
            group = [(NSArray *)error.associatedObject lastObject];
        }
    }
    
    // Retrieving list of observers (including one time and persistent observers)
    [self observersForEvent:PNObservationEvents.clientChannelsForGroupRequest
          withCallbackToken:[notification pn_callbackToken]
                   andBlock:^(NSMutableArray *observers) {

        // Clean one time observers for specific event
        [self removeOneTimeObserversForEvent:PNObservationEvents.clientChannelsForGroupRequest
                            andCallbackToken:[notification pn_callbackToken]];
        dispatch_async(dispatch_get_main_queue(), ^{

            [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                                    NSUInteger observerDataIdx,
                                                    BOOL *observerDataEnumeratorStop) {

                // Call handling blocks
                PNClientChannelsForGroupRequestHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
                if (block) {

                    block(group, error);
                }
            }];
        });
    }];
}

- (void)handleClientGroupChannelsListModificationProcess:(NSNotification *)notification {
    
    PNChannelGroupChange *change = nil;
    BOOL addingChannels = YES;
    PNError *error = nil;

    // Retrieve reference on original notification name.
    NSString *notificationName = [notification pn_notificationName];
    
    NSString *eventName = PNObservationEvents.clientChannelsAdditionToGroup;
    if ([notificationName isEqualToString:kPNClientGroupChannelsRemovalCompleteNotification] ||
        [notificationName isEqualToString:kPNClientGroupChannelsRemovalDidFailWithErrorNotification]) {
        
        addingChannels = NO;
        eventName = PNObservationEvents.clientChannelsRemovalFromGroup;
    }
    if ([notificationName isEqualToString:kPNClientGroupChannelsAdditionCompleteNotification] ||
        [notificationName isEqualToString:kPNClientGroupChannelsRemovalCompleteNotification]) {
        
        change = (PNChannelGroupChange *)[notification pn_data];
    }
    else {
        
        error = (PNError *)[notification pn_data];
        change = error.associatedObject;
    }
    
    
    // Retrieving list of observers (including one time and persistent observers)
    [self observersForEvent:eventName withCallbackToken:[notification pn_callbackToken]
                   andBlock:^(NSMutableArray *observers) {

        // Clean one time observers for specific event
        [self removeOneTimeObserversForEvent:eventName
                            andCallbackToken:[notification pn_callbackToken]];
        dispatch_async(dispatch_get_main_queue(), ^{

            [observers enumerateObjectsUsingBlock:^(NSDictionary *observerData,
                                                    NSUInteger observerDataIdx,
                                                    BOOL *observerDataEnumeratorStop) {

                // Receive reference on handling block
                id block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
                if (block) {

                    if (addingChannels) {

                        ((PNClientChannelsAdditionToGroupHandlingBlock) block)(change.group, change.channels, error);
                    }
                    else {

                        ((PNClientChannelsRemovalFromGroupHandlingBlock) block)(change.group, change.channels, error);
                    }
                }
            }];
        });
    }];
}

- (void)handleClientSubscriptionProcess:(NSNotification *)notification {

    NSArray *channels = nil;
    PNError *error = nil;
    PNSubscriptionProcessState state = PNSubscriptionProcessNotSubscribedState;

    // Retrieve reference on original notification name.
    NSString *notificationName = [notification pn_notificationName];

    // Check whether arrived notification that subscription failed or not
    if ([notificationName isEqualToString:kPNClientSubscriptionDidFailNotification] ||
        [notificationName isEqualToString:kPNClientSubscriptionDidFailOnClientIdentifierUpdateNotification]) {

        error = (PNError *)[notification pn_data];
        channels = error.associatedObject;
    }
    else {

        // Retrieve list of channels on which event is occurred
        channels = (NSArray *)[notification pn_data];
        state = PNSubscriptionProcessSubscribedState;

        // Check whether arrived notification that subscription will be restored
        if ([notificationName isEqualToString:kPNClientSubscriptionWillRestoreNotification]) {

            state = PNSubscriptionProcessWillRestoreState;
        }
        // Check whether arrived notification that subscription restored
        else if ([notificationName isEqualToString:kPNClientSubscriptionDidRestoreNotification]) {

            state = PNSubscriptionProcessRestoredState;
        }
    }


    // Retrieving list of observers (including one time and persistent observers)
    [self observersForEvent:PNObservationEvents.clientSubscriptionOnChannels
          withCallbackToken:[notification pn_callbackToken]
                   andBlock:^(NSMutableArray *allObservers) {

        NSMutableArray *observers = [NSMutableArray arrayWithArray:allObservers];
        if ([notificationName isEqualToString:kPNClientSubscriptionDidCompleteOnClientIdentifierUpdateNotification] ||
            [notificationName isEqualToString:kPNClientSubscriptionDidFailOnClientIdentifierUpdateNotification]) {

            id oneTimeEventObservers = [self oneTimeObserversForEvent:PNObservationEvents.clientSubscriptionOnChannels
                                                    withCallbackToken:[notification pn_callbackToken]];

            BOOL(^oneTimeProcessingBlock)(NSMutableDictionary *) = ^BOOL(NSMutableDictionary *observerData){

                BOOL foundObject = NO;
                if ([[observerData valueForKey:PNObservationObserverData.observer] isEqual:self.defaultObserver]) {

                    [observers removeAllObjects];
                    [observers addObject:observerData];
                    [self removeObserver:[observerData valueForKey:PNObservationObserverData.observer]
                                forEvent:PNObservationEvents.clientSubscriptionOnChannels
                            oneTimeEvent:YES withCallbackToken:[notification pn_callbackToken]];
                    foundObject = YES;
                }

                return foundObject;
            };

            if ([oneTimeEventObservers isKindOfClass:[NSMutableDictionary class]]) {

                oneTimeProcessingBlock(oneTimeEventObservers);
            }
            else if ([(NSMutableArray *)oneTimeEventObservers count]) {

                [(NSMutableArray *)oneTimeEventObservers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                                                                      NSUInteger observerDataIdx,
                                                                                      BOOL *observerDataEnumeratorStop) {

                    *observerDataEnumeratorStop = oneTimeProcessingBlock(observerData);
                }];
            }
        }
        else {

            // Clean one time observers for specific event
            [self removeOneTimeObserversForEvent:PNObservationEvents.clientSubscriptionOnChannels
                                andCallbackToken:[notification pn_callbackToken]];
        }

        dispatch_async(dispatch_get_main_queue(), ^{

            [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                                    NSUInteger observerDataIdx,
                                                    BOOL *observerDataEnumeratorStop) {

                // Call handling blocks
                PNClientChannelSubscriptionHandlerBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
                if (block) {

                    block(state, channels, error);
                }
            }];
        });
    }];
}

- (void)handleClientUnsubscriptionProcess:(NSNotification *)notification {

    NSArray *channels = nil;
    PNError *error = nil;

    // Retrieve reference on original notification name.
    NSString *notificationName = [notification pn_notificationName];

    if ([notificationName isEqualToString:kPNClientUnsubscriptionDidCompleteNotification] ||
        [notificationName isEqualToString:kPNClientUnsubscriptionDidCompleteOnClientIdentifierUpdateNotification]) {

        channels = (NSArray *)[notification pn_data];
    }
    else {

        error = (PNError *)[notification pn_data];
        channels = (NSArray *)error.associatedObject;
    }

    // Retrieving list of observers (including one time and persistent observers)
    [self observersForEvent:PNObservationEvents.clientUnsubscribeFromChannels
          withCallbackToken:[notification pn_callbackToken]
                   andBlock:^(NSMutableArray *allObservers) {

        NSMutableArray *observers = [NSMutableArray arrayWithArray:allObservers];
        if ([notificationName isEqualToString:kPNClientUnsubscriptionDidCompleteOnClientIdentifierUpdateNotification] ||
            [notificationName isEqualToString:kPNClientUnsubscriptionDidFailOnClientIdentifierUpdateNotification]) {

            id oneTimeEventObservers = [self oneTimeObserversForEvent:PNObservationEvents.clientUnsubscribeFromChannels
                                                    withCallbackToken:[notification pn_callbackToken]];

            BOOL(^oneTimeProcessingBlock)(NSMutableDictionary *) = ^BOOL(NSMutableDictionary *observerData){

                BOOL foundObject = NO;
                if ([[observerData valueForKey:PNObservationObserverData.observer] isEqual:self.defaultObserver]) {

                    [observers removeAllObjects];
                    [observers addObject:observerData];
                    [self removeObserver:[observerData valueForKey:PNObservationObserverData.observer]
                                forEvent:PNObservationEvents.clientUnsubscribeFromChannels
                            oneTimeEvent:YES withCallbackToken:[notification pn_callbackToken]];
                    foundObject = YES;
                }

                return foundObject;
            };

            if ([oneTimeEventObservers isKindOfClass:[NSMutableDictionary class]]) {

                oneTimeProcessingBlock(oneTimeEventObservers);
            }
            else if ([(NSMutableArray *)oneTimeEventObservers count]) {

                [(NSMutableArray *)oneTimeEventObservers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                                                                      NSUInteger observerDataIdx,
                                                                                      BOOL *observerDataEnumeratorStop) {

                    *observerDataEnumeratorStop = oneTimeProcessingBlock(observerData);
                }];
            }
        }
        else {

            // Clean one time observers for specific event
            [self removeOneTimeObserversForEvent:PNObservationEvents.clientUnsubscribeFromChannels
                                andCallbackToken:[notification pn_callbackToken]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{

            [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                                    NSUInteger observerDataIdx,
                                                    BOOL *observerDataEnumeratorStop) {

                // Call handling blocks
                PNClientChannelUnsubscriptionHandlerBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
                if (block) {

                    block(channels, error);
                }
            }];
        });
    }];
}

- (void)handleClientPresenceObservationEnablingProcess:(NSNotification *)notification {

    NSArray *channels = nil;
    PNError *error = nil;

    // Retrieve reference on original notification name.
    NSString *notificationName = [notification pn_notificationName];

    if ([notificationName isEqualToString:kPNClientPresenceEnablingDidCompleteNotification]) {

        channels = (NSArray *)[notification pn_data];
    }
    else {

        error = (PNError *)[notification pn_data];
        channels = (NSArray *)error.associatedObject;
    }

    // Retrieving list of observers (including one time and persistent observers)
    [self observersForEvent:PNObservationEvents.clientPresenceEnableOnChannels
          withCallbackToken:[notification pn_callbackToken]
                   andBlock:^(NSMutableArray *observers) {

        // Clean one time observers for specific event
        [self removeOneTimeObserversForEvent:PNObservationEvents.clientPresenceEnableOnChannels
                            andCallbackToken:[notification pn_callbackToken]];
        dispatch_async(dispatch_get_main_queue(), ^{

            [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                                    NSUInteger observerDataIdx,
                                                    BOOL *observerDataEnumeratorStop) {

                // Call handling blocks
                PNClientPresenceEnableHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
                if (block) {

                    block(channels, error);
                }
            }];
        });
    }];
}

- (void)handleClientPresenceObservationDisablingProcess:(NSNotification *)notification {

    NSArray *channels = nil;
    PNError *error = nil;

    // Retrieve reference on original notification name.
    NSString *notificationName = [notification pn_notificationName];

    if ([notificationName isEqualToString:kPNClientPresenceDisablingDidCompleteNotification]) {

        channels = (NSArray *)[notification pn_data];
    }
    else {

        error = (PNError *)[notification pn_data];
        channels = (NSArray *)error.associatedObject;
    }

    // Retrieving list of observers (including one time and persistent observers)
    [self observersForEvent:PNObservationEvents.clientPresenceDisableOnChannels
          withCallbackToken:[notification pn_callbackToken]
                   andBlock:^(NSMutableArray *observers) {

        // Clean one time observers for specific event
        [self removeOneTimeObserversForEvent:PNObservationEvents.clientPresenceDisableOnChannels
                            andCallbackToken:[notification pn_callbackToken]];
        dispatch_async(dispatch_get_main_queue(), ^{

            [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                                    NSUInteger observerDataIdx,
                                                    BOOL *observerDataEnumeratorStop) {

                // Call handling blocks
                PNClientPresenceDisableHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
                if (block) {

                    block(channels, error);
                }
            }];
        });
    }];
}

- (void)handleClientPushNotificationStateChange:(NSNotification *)notification {

    BOOL isEnablingPushNotifications = YES;
    NSString *eventName = PNObservationEvents.clientPushNotificationEnabling;

    // Retrieve reference on original notification name.
    NSString *notificationName = [notification pn_notificationName];

    if ([notificationName isEqualToString:kPNClientPushNotificationDisableDidCompleteNotification] ||
        [notificationName isEqualToString:kPNClientPushNotificationDisableDidFailNotification]) {

        isEnablingPushNotifications = NO;
        eventName = PNObservationEvents.clientPushNotificationDisabling;
    }
    NSArray *channels = nil;
    PNError *error = nil;
    if ([notificationName isEqualToString:kPNClientPushNotificationEnableDidCompleteNotification] ||
        [notificationName isEqualToString:kPNClientPushNotificationDisableDidCompleteNotification]) {

        channels = (NSArray *)[notification pn_data];
    }
    else {

        error = (PNError *)[notification pn_data];
        channels = error.associatedObject;
    }


    // Retrieving list of observers (including one time and persistent observers)
    [self observersForEvent:eventName withCallbackToken:[notification pn_callbackToken]
                   andBlock:^(NSMutableArray *observers) {

        // Clean one time observers for specific event
        [self removeOneTimeObserversForEvent:eventName
                            andCallbackToken:[notification pn_callbackToken]];
        dispatch_async(dispatch_get_main_queue(), ^{

            [observers enumerateObjectsUsingBlock:^(NSDictionary *observerData,
                                                    NSUInteger observerDataIdx,
                                                    BOOL *observerDataEnumeratorStop) {

                // Receive reference on handling block
                id block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
                if (block) {

                    if (isEnablingPushNotifications) {

                        ((PNClientPushNotificationsEnableHandlingBlock) block)(channels, error);
                    }
                    else {

                        ((PNClientPushNotificationsDisableHandlingBlock) block)(channels, error);
                    }
                }
            }];
        });
    }];
}

- (void)handleClientPushNotificationRemoveProcess:(NSNotification *)notification {

    PNError *error = nil;

    // Retrieve reference on original notification name.
    NSString *notificationName = [notification pn_notificationName];

    if (![notificationName isEqualToString:kPNClientPushNotificationRemoveDidCompleteNotification]) {

        error = (PNError *)[notification pn_data];
    }

    // Retrieving list of observers (including one time and persistent observers)
    [self observersForEvent:PNObservationEvents.clientPushNotificationRemovalForAllChannels
          withCallbackToken:[notification pn_callbackToken]
                   andBlock:^(NSMutableArray *observers) {

        // Clean one time observers for specific event
        [self removeOneTimeObserversForEvent:PNObservationEvents.clientPushNotificationRemovalForAllChannels
                            andCallbackToken:[notification pn_callbackToken]];
        dispatch_async(dispatch_get_main_queue(), ^{

            [observers enumerateObjectsUsingBlock:^(NSDictionary *observerData,
                                                    NSUInteger observerDataIdx,
                                                    BOOL *observerDataEnumeratorStop) {

                // Receive reference on handling block
                PNClientPushNotificationsRemoveHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
                if (block) {

                    block(error);
                }
            }];
        });
    }];
}

- (void)handleClientPushNotificationEnabledChannels:(NSNotification *)notification {

    NSArray *channels = nil;
    PNError *error = nil;

    // Retrieve reference on original notification name.
    NSString *notificationName = [notification pn_notificationName];

    if ([notificationName isEqualToString:kPNClientPushNotificationChannelsRetrieveDidCompleteNotification]) {

        channels = (NSArray *)[notification pn_data];
    }
    else {

        error = (PNError *)[notification pn_data];
    }


    // Retrieving list of observers (including one time and persistent observers)
    [self observersForEvent:PNObservationEvents.clientPushNotificationEnabledChannelsRetrieval
          withCallbackToken:[notification pn_callbackToken]
                   andBlock:^(NSMutableArray *observers) {

        // Clean one time observers for specific event
        [self removeOneTimeObserversForEvent:PNObservationEvents.clientPushNotificationEnabledChannelsRetrieval
                            andCallbackToken:[notification pn_callbackToken]];
        dispatch_async(dispatch_get_main_queue(), ^{

            [observers enumerateObjectsUsingBlock:^(NSDictionary *observerData,
                                                    NSUInteger observerDataIdx,
                                                    BOOL *observerDataEnumeratorStop) {

                // Receive reference on handling block
                PNClientPushNotificationsEnabledChannelsHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
                if (block) {

                    block(channels, error);
                }
            }];
        });
    }];
}

- (void)handleClientMessageProcessingStateChange:(NSNotification *)notification {

    PNMessageState state = PNMessageSending;
    id processingData = nil;
    BOOL shouldUnsubscribe = NO;

    // Retrieve reference on original notification name.
    NSString *notificationName = [notification pn_notificationName];

    if ([notificationName isEqualToString:kPNClientMessageSendingDidFailNotification]) {

        state = PNMessageSendingError;
        shouldUnsubscribe = YES;
        processingData = (PNError *)[notification pn_data];
    }
    else {

        shouldUnsubscribe = [notificationName isEqualToString:kPNClientDidSendMessageNotification];
        if (shouldUnsubscribe) {

            state = PNMessageSent;
        }
        processingData = (PNMessage *)[notification pn_data];
    }

    // Retrieving list of observers (including one time and persistent observers)
    [self observersForEvent:PNObservationEvents.clientMessageSendCompletion
          withCallbackToken:[notification pn_callbackToken]
                   andBlock:^(NSMutableArray *observers) {

        if (shouldUnsubscribe) {

            // Clean one time observers for specific event
            [self removeOneTimeObserversForEvent:PNObservationEvents.clientMessageSendCompletion
                                andCallbackToken:[notification pn_callbackToken]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{

            [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                                    NSUInteger observerDataIdx,
                                                    BOOL *observerDataEnumeratorStop) {

                // Call handling blocks
                PNClientMessageProcessingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
                if (block) {

                    block(state, processingData);
                }
            }];
        });
    }];
}

- (void)handleClientDidReceiveMessage:(NSNotification *)notification {

    // Retrieve reference on message which was received
    PNMessage *message = (PNMessage *)[notification pn_data];

    // Retrieving list of observers
    [self observersForEvent:PNObservationEvents.clientReceivedMessage
          withCallbackToken:[notification pn_callbackToken]
                   andBlock:^(NSMutableArray *observers) {

        dispatch_async(dispatch_get_main_queue(), ^{

            [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                                    NSUInteger observerDataIdx,
                                                    BOOL *observerDataEnumeratorStop) {

                // Call handling blocks
                PNClientMessageHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
                if (block) {

                    block(message);
                }
            }];
        });
    }];
}

- (void)handleClientDidReceivePresenceEvent:(NSNotification *)notification {

    // Retrieve reference on presence event which was received
    PNPresenceEvent *presenceEvent = (PNPresenceEvent *)[notification pn_data];

    // Retrieving list of observers
    [self observersForEvent:PNObservationEvents.clientReceivedPresenceEvent
          withCallbackToken:[notification pn_callbackToken]
                   andBlock:^(NSMutableArray *observers) {

        dispatch_async(dispatch_get_main_queue(), ^{

            [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                                    NSUInteger observerDataIdx,
                                                    BOOL *observerDataEnumeratorStop) {

                // Call handling blocks
                PNClientPresenceEventHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
                if (block) {

                    block(presenceEvent);
                }
            }];
        });
    }];
}

- (void)handleClientMessageHistoryProcess:(NSNotification *)notification {

    // Retrieve reference on history object
    PNMessagesHistory *history = nil;
    PNChannel *channel = nil;
    PNError *error = nil;

    // Retrieve reference on original notification name.
    NSString *notificationName = [notification pn_notificationName];

    if ([notificationName isEqualToString:kPNClientDidReceiveMessagesHistoryNotification]) {

        history = (PNMessagesHistory *)[notification pn_data];
        channel = ([history.channel isKindOfClass:[NSArray class]] ?
                    [(NSArray *)history.channel lastObject] :
                    history.channel);
    }
    else {

        error = (PNError *)[notification pn_data];
        channel = ([error.associatedObject isKindOfClass:[NSArray class]] ?
                    [(NSArray *)error.associatedObject lastObject] :
                    error.associatedObject);
    }

    // Retrieving list of observers (including one time and persistent observers)
    [self observersForEvent:PNObservationEvents.clientReceivedHistory
          withCallbackToken:[notification pn_callbackToken]
                   andBlock:^(NSMutableArray *observers) {

        // Clean one time observers for specific event
        [self removeOneTimeObserversForEvent:PNObservationEvents.clientReceivedHistory
                            andCallbackToken:[notification pn_callbackToken]];
        dispatch_async(dispatch_get_main_queue(), ^{

            [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                                    NSUInteger observerDataIdx,
                                                    BOOL *observerDataEnumeratorStop) {

                // Call handling blocks
                PNClientHistoryLoadHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
                if (block) {

                    block(history.messages, channel, history.startDate, history.endDate, error);
                }
            }];
        });
    }];
}

- (void)handleClientChannelAccessRightsChange:(NSNotification *)notification {

    PNAccessRightsCollection *collection = nil;
    PNError *error = nil;

    // Retrieve reference on original notification name.
    NSString *notificationName = [notification pn_notificationName];

    if ([notificationName isEqualToString:kPNClientAccessRightsChangeDidCompleteNotification]) {

        collection = (PNAccessRightsCollection *)[notification pn_data];
    }
    else {

        error = (PNError *)[notification pn_data];
    }

    // Retrieving list of observers (including one time and persistent observers)
    [self observersForEvent:PNObservationEvents.clientAccessRightsChange
          withCallbackToken:[notification pn_callbackToken]
                   andBlock:^(NSMutableArray *observers) {

        // Clean one time observers for specific event
        [self removeOneTimeObserversForEvent:PNObservationEvents.clientAccessRightsChange
                            andCallbackToken:[notification pn_callbackToken]];
        dispatch_async(dispatch_get_main_queue(), ^{

            [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                                    NSUInteger observerDataIdx,
                                                    BOOL *observerDataEnumeratorStop) {

                // Call handling blocks
                PNClientChannelAccessRightsChangeBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
                if (block) {

                    block(collection, error);
                }
            }];
        });
    }];
}

- (void)handleClientChannelAccessRightsRequest:(NSNotification *)notification {

    PNAccessRightsCollection *collection = nil;
    PNError *error = nil;

    // Retrieve reference on original notification name.
    NSString *notificationName = [notification pn_notificationName];

    if ([notificationName isEqualToString:kPNClientAccessRightsAuditDidCompleteNotification]) {

        collection = (PNAccessRightsCollection *)[notification pn_data];
    }
    else {

        error = (PNError *)[notification pn_data];
    }

    // Retrieving list of observers (including one time and persistent observers)
    [self observersForEvent:PNObservationEvents.clientAccessRightsAudit
          withCallbackToken:[notification pn_callbackToken]
                   andBlock:^(NSMutableArray *observers) {

        // Clean one time observers for specific event
        [self removeOneTimeObserversForEvent:PNObservationEvents.clientAccessRightsAudit
                            andCallbackToken:[notification pn_callbackToken]];
        dispatch_async(dispatch_get_main_queue(), ^{

            [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                                    NSUInteger observerDataIdx,
                                                    BOOL *observerDataEnumeratorStop) {

                // Call handling blocks
                PNClientChannelAccessRightsAuditBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
                if (block) {

                    block(collection, error);
                }
            }];
        });
    }];
}

- (void)handleClientHereNowProcess:(NSNotification *)notification {

    // Retrieve reference on participants object
    PNHereNow *participants = nil;
    NSArray *channels = nil;
    PNError *error = nil;

    // Retrieve reference on original notification name.
    NSString *notificationName = [notification pn_notificationName];

    if ([notificationName isEqualToString:kPNClientDidReceiveParticipantsListNotification]) {

        participants = (PNHereNow *)[notification pn_data];
        channels = [participants channels];
    }
    else {

        error = (PNError *)[notification pn_data];
        channels = error.associatedObject;
    }

    // Retrieving list of observers (including one time and persistent observers)
    [self observersForEvent:PNObservationEvents.clientReceivedParticipantsList
          withCallbackToken:[notification pn_callbackToken]
                   andBlock:^(NSMutableArray *observers) {

        // Clean one time observers for specific event
        [self removeOneTimeObserversForEvent:PNObservationEvents.clientReceivedParticipantsList
                            andCallbackToken:[notification pn_callbackToken]];
        dispatch_async(dispatch_get_main_queue(), ^{

            [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                                    NSUInteger observerDataIdx,
                                                    BOOL *observerDataEnumeratorStop) {

                // Call handling blocks
                PNClientParticipantsHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
                if (block) {

                    block(participants, channels, error);
                }
            }];
        });
    }];
}

- (void)handleClientWhereNowProcess:(NSNotification *)notification {

    // Retrieve reference on participants object
    PNWhereNow *channelsList = nil;
    NSString *identifier = nil;
    PNError *error = nil;

    // Retrieve reference on original notification name.
    NSString *notificationName = [notification pn_notificationName];

    if ([notificationName isEqualToString:kPNClientDidReceiveParticipantChannelsListNotification]) {

        channelsList = (PNWhereNow *)[notification pn_data];
        identifier = channelsList.identifier;
    }
    else {

        error = (PNError *)[notification pn_data];
        identifier = error.associatedObject;
    }

    // Retrieving list of observers (including one time and persistent observers)
    [self observersForEvent:PNObservationEvents.clientParticipantChannelsList
          withCallbackToken:[notification pn_callbackToken]
                   andBlock:^(NSMutableArray *observers) {

        // Clean one time observers for specific event
        [self removeOneTimeObserversForEvent:PNObservationEvents.clientParticipantChannelsList
                            andCallbackToken:[notification pn_callbackToken]];
        dispatch_async(dispatch_get_main_queue(), ^{

            [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                                    NSUInteger observerDataIdx,
                                                    BOOL *observerDataEnumeratorStop) {

                // Call handling blocks
                PNClientParticipantChannelsHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
                if (block) {

                    block(identifier, channelsList.channels, error);
                }
            }];
        });
    }];
}

- (void)handleClientCompletedTimeTokenProcessing:(NSNotification *)notification {

    PNError *error = nil;
    NSNumber *timeToken = nil;

    // Retrieve reference on original notification name.
    NSString *notificationName = [notification pn_notificationName];

    if ([notificationName isEqualToString:kPNClientDidReceiveTimeTokenNotification]) {

        timeToken = (NSNumber *)[notification pn_data];
    }
    else {

        error = (PNError *)[notification pn_data];
    }

    // Retrieving list of observers (including one time and persistent observers)
    [self observersForEvent:PNObservationEvents.clientTimeTokenReceivingComplete
          withCallbackToken:[notification pn_callbackToken]
                   andBlock:^(NSMutableArray *observers) {

        // Clean one time observers for specific event
        [self removeOneTimeObserversForEvent:PNObservationEvents.clientTimeTokenReceivingComplete
                            andCallbackToken:[notification pn_callbackToken]];
        dispatch_async(dispatch_get_main_queue(), ^{

            [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                                    NSUInteger observerDataIdx,
                                                    BOOL *observerDataEnumeratorStop) {

                // Call handling blocks
                PNClientTimeTokenReceivingCompleteBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
                if (block) {

                    block(timeToken, error);
                }
            }];
        });
    }];
}


#pragma mark - Misc methods

- (NSMutableArray *)persistentObserversForEvent:(NSString *)eventName {

    // This method should be launched only from within it's private queue
    [self pn_scheduleOnPrivateQueueAssert];

    if ([self.observers valueForKey:eventName] == nil) {

        [self.observers setValue:[NSMutableArray array] forKey:eventName];
    }
    
    
    return [self.observers valueForKey:eventName];
}

- (id)oneTimeObserversForEvent:(NSString *)eventName withCallbackToken:(NSString *)callbackToken {
    
    if ([self.oneTimeObservers valueForKey:eventName] == nil) {

        NSMutableDictionary *observersForEvent = [NSMutableDictionary dictionary];
        [observersForEvent setValue:[NSMutableArray array] forKey:kPNObserverGeneralCallbacks];
        [self.oneTimeObservers setValue:observersForEvent forKey:eventName];
    }

    NSString *targetKey = (callbackToken ? callbackToken : kPNObserverGeneralCallbacks);
    

    return [[self.oneTimeObservers valueForKey:eventName] valueForKey:targetKey];
}

- (void)observersForEvent:(NSString *)eventName withCallbackToken:(NSString *)callbackToken
                 andBlock:(void (^)(NSMutableArray *observers))fetchCompletionBlock {
    
    [self pn_dispatchBlock:^{

        id oneTimeEventObservers = [self oneTimeObserversForEvent:eventName
                                                withCallbackToken:callbackToken];
        NSMutableArray *persistentObservers = [self persistentObserversForEvent:eventName];


        // Composing full observers list depending on whether at least
        // one object exist in retrieved arrays
        NSMutableArray *allObservers = [NSMutableArray array];
        if ([oneTimeEventObservers isKindOfClass:[NSMutableDictionary class]]) {

            [allObservers addObject:oneTimeEventObservers];
        }
        else if ([oneTimeEventObservers count]) {

            [allObservers addObjectsFromArray:oneTimeEventObservers];
        }

        if ([persistentObservers count]) {

            [allObservers addObjectsFromArray:persistentObservers];
        }


        fetchCompletionBlock(allObservers);
    }];
}


#pragma mark - Memory management

- (void)dealloc {
    
    [self pn_destroyPrivateDispatchQueue];

    // Unsubscribe from all notifications
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [_notifications enumerateObjectsUsingBlock:^(id notification, NSUInteger notificationIdx,
                                                 BOOL *notificationsEnumeratorStop) {

        [notificationCenter removeObserver:notification];
    }];
    _notifications = nil;
    
    _defaultObserver = nil;

    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
        
        return @[PNLoggerSymbols.observationCenter.destroyed];
    }];
}

#pragma mark -


@end
