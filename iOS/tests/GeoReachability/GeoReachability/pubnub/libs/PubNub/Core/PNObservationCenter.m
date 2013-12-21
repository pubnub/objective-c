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
#import "PNMessagesHistory+Protected.h"
#import "PNHereNow+Protected.h"
#import "PNError+Protected.h"
#import "PubNub+Protected.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub observation center must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Static

// Stores reference on shared observation center instance
static PNObservationCenter *_sharedInstance = nil;
static dispatch_once_t onceToken;


struct PNObservationEventsStruct {

    __unsafe_unretained NSString *clientConnectionStateChange;
    __unsafe_unretained NSString *clientSubscriptionOnChannels;
    __unsafe_unretained NSString *clientUnsubscribeFromChannels;
    __unsafe_unretained NSString *clientPresenceEnableOnChannels;
    __unsafe_unretained NSString *clientPresenceDisableOnChannels;
    __unsafe_unretained NSString *clientPushNotificationEnabling;
    __unsafe_unretained NSString *clientPushNotificationDisabling;
    __unsafe_unretained NSString *clientPushNotificationEnabledChannelsRetrieval;
    __unsafe_unretained NSString *clientPushNotificationRemovalForAllChannels;
    __unsafe_unretained NSString *clientTimeTokenReceivingComplete;
    __unsafe_unretained NSString *clientMessageSendCompletion;
    __unsafe_unretained NSString *clientReceivedMessage;
    __unsafe_unretained NSString *clientReceivedPresenceEvent;
    __unsafe_unretained NSString *clientReceivedHistory;
    __unsafe_unretained NSString *clientReceivedParticipantsList;
};

struct PNObservationObserverDataStruct {

    __unsafe_unretained NSString *observer;
    __unsafe_unretained NSString *observerCallbackBlock;
};

static struct PNObservationEventsStruct PNObservationEvents = {
    .clientConnectionStateChange = @"clientConnectionStateChangeEvent",
    .clientTimeTokenReceivingComplete = @"clientReceivingTimeTokenEvent",
    .clientSubscriptionOnChannels = @"clientSubscribtionOnChannelsEvent",
    .clientUnsubscribeFromChannels = @"clientUnsubscribeFromChannelsEvent",
    .clientPresenceEnableOnChannels = @"clientPresenceEnableOnChannels",
    .clientPresenceDisableOnChannels = @"clientPresenceDisableOnChannels",
    .clientPushNotificationEnabling = @"clientPushNotificationEnabling",
    .clientPushNotificationDisabling = @"clientPushNotificationDisabling",
    .clientPushNotificationEnabledChannelsRetrieval = @"clientPushNotificationEnabledChannelsRetrieval",
    .clientPushNotificationRemovalForAllChannels = @"clientPushNotificationRemovalForAllChannels",
    .clientMessageSendCompletion = @"clientMessageSendCompletionEvent",
    .clientReceivedMessage = @"clientReceivedMessageEvent",
    .clientReceivedPresenceEvent = @"clientReceivedPresenceEvent",
    .clientReceivedHistory = @"clientReceivedHistoryEvent",
    .clientReceivedParticipantsList = @"clientReceivedParticipantsListEvent"
};

static struct PNObservationObserverDataStruct PNObservationObserverData = {

    .observer = @"observer",
    .observerCallbackBlock = @"observerCallbackBlock"
};


#pragma mark - Private interface methods

@interface PNObservationCenter ()


#pragma mark - Properties

// Stores mapped observers to events wich they want to track
// and execution block provided by subscriber
@property (nonatomic, strong) NSMutableDictionary *observers;

// Stores mapped observers to events wich they want to track
// and execution block provided by subscriber
// This is FIFO observer type which means that as soon as event
// will occur observer will be removed from list
@property (nonatomic, strong) NSMutableDictionary *oneTimeObservers;


#pragma mark - Instance methods

/**
 * Helper methods which will create collection for specified
 * event name if it doesn't exist or return existing.
 */
- (NSMutableArray *)persistentObserversForEvent:(NSString *)eventName;
- (NSMutableArray *)oneTimeObserversForEvent:(NSString *)eventName;

- (void)removeOneTimeObserversForEvent:(NSString *)eventName;

/**
 * Managing observation list
 */
- (void)addObserver:(id)observer forEvent:(NSString *)eventName oneTimeEvent:(BOOL)isOneTimeEvent withBlock:(id)block;
- (void)removeObserver:(id)observer forEvent:(NSString *)eventName oneTimeEvent:(BOOL)isOneTimeEvent;


#pragma mark - Handler methods

- (void)handleClientConnectionStateChange:(NSNotification *)notification;
- (void)handleClientSubscriptionProcess:(NSNotification *)notification;
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
- (void)handleClientHereNowProcess:(NSNotification *)notification;
- (void)handleClientCompletedTimeTokenProcessing:(NSNotification *)notification;


#pragma mark - Misc methods

/**
 * Retrieve full list of observers for specified event name
 */
- (NSMutableArray *)observersForEvent:(NSString *)eventName;


@end


#pragma mark - Public interface methods

@implementation PNObservationCenter


#pragma mark Class methods

+ (PNObservationCenter *)defaultCenter {

    dispatch_once(&onceToken, ^{
        
        _sharedInstance = [[[self class] alloc] init];
    });
    
    
    return _sharedInstance;
}

+ (void)resetCenter {

    // Resetting one time observers (they bound to PubNub client instance)
    [[self defaultCenter].oneTimeObservers removeAllObjects];
}


#pragma mark - Instance methods

- (id)init {
    
    // Check whether initialization was successful or not
    if((self = [super init])) {
        
        self.observers = [NSMutableDictionary dictionary];
        self.oneTimeObservers = [NSMutableDictionary dictionary];
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

        [notificationCenter addObserver:self
                               selector:@selector(handleClientConnectionStateChange:)
                                   name:kPNClientDidConnectToOriginNotification
                                 object:nil];
        [notificationCenter addObserver:self
                               selector:@selector(handleClientConnectionStateChange:)
                                   name:kPNClientDidDisconnectFromOriginNotification
                                 object:nil];
        [notificationCenter addObserver:self
                               selector:@selector(handleClientConnectionStateChange:)
                                   name:kPNClientConnectionDidFailWithErrorNotification
                                 object:nil];


        // Handle subscription events
        [notificationCenter addObserver:self
                               selector:@selector(handleClientSubscriptionProcess:)
                                   name:kPNClientSubscriptionDidCompleteNotification
                                 object:nil];
        [notificationCenter addObserver:self
                               selector:@selector(handleClientSubscriptionProcess:)
                                   name:kPNClientSubscriptionWillRestoreNotification
                                 object:nil];
        [notificationCenter addObserver:self
                               selector:@selector(handleClientSubscriptionProcess:)
                                   name:kPNClientSubscriptionDidRestoreNotification
                                 object:nil];
        [notificationCenter addObserver:self
                               selector:@selector(handleClientSubscriptionProcess:)
                                   name:kPNClientSubscriptionDidFailNotification
                                 object:nil];
        [notificationCenter addObserver:self
                               selector:@selector(handleClientUnsubscriptionProcess:)
                                   name:kPNClientUnsubscriptionDidCompleteNotification
                                 object:nil];
        [notificationCenter addObserver:self
                               selector:@selector(handleClientUnsubscriptionProcess:)
                                   name:kPNClientUnsubscriptionDidFailNotification
                                 object:nil];

        // Handle presence events
        [notificationCenter addObserver:self
                               selector:@selector(handleClientPresenceObservationEnablingProcess:)
                                   name:kPNClientPresenceEnablingDidCompleteNotification
                                 object:nil];
        [notificationCenter addObserver:self
                               selector:@selector(handleClientPresenceObservationEnablingProcess:)
                                   name:kPNClientPresenceEnablingDidFailNotification
                                 object:nil];
        [notificationCenter addObserver:self
                               selector:@selector(handleClientPresenceObservationDisablingProcess:)
                                   name:kPNClientPresenceDisablingDidCompleteNotification
                                 object:nil];
        [notificationCenter addObserver:self
                               selector:@selector(handleClientPresenceObservationDisablingProcess:)
                                   name:kPNClientPresenceDisablingDidFailNotification
                                 object:nil];


        // Handle push notification state changing events
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleClientPushNotificationStateChange:)
                                                     name:kPNClientPushNotificationEnableDidCompleteNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleClientPushNotificationStateChange:)
                                                     name:kPNClientPushNotificationEnableDidFailNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleClientPushNotificationStateChange:)
                                                     name:kPNClientPushNotificationDisableDidCompleteNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleClientPushNotificationStateChange:)
                                                     name:kPNClientPushNotificationDisableDidFailNotification
                                                   object:nil];


        // Handle push notification remove events
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleClientPushNotificationRemoveProcess:)
                                                     name:kPNClientPushNotificationRemoveDidCompleteNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleClientPushNotificationRemoveProcess:)
                                                     name:kPNClientPushNotificationRemoveDidFailNotification
                                                   object:nil];


        // Handle push notification enabled channels retrieve events
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleClientPushNotificationEnabledChannels:)
                                                     name:kPNClientPushNotificationChannelsRetrieveDidCompleteNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleClientPushNotificationEnabledChannels:)
                                                     name:kPNClientPushNotificationChannelsRetrieveDidFailNotification
                                                   object:nil];


        // Handle time token events
        [notificationCenter addObserver:self
                               selector:@selector(handleClientCompletedTimeTokenProcessing:)
                                   name:kPNClientDidReceiveTimeTokenNotification
                                 object:nil];
        [notificationCenter addObserver:self
                               selector:@selector(handleClientCompletedTimeTokenProcessing:)
                                   name:kPNClientDidFailTimeTokenReceiveNotification
                                 object:nil];


        // Handle message processing events
        [notificationCenter addObserver:self
                               selector:@selector(handleClientMessageProcessingStateChange:)
                                   name:kPNClientWillSendMessageNotification
                                 object:nil];
        [notificationCenter addObserver:self
                               selector:@selector(handleClientMessageProcessingStateChange:)
                                   name:kPNClientDidSendMessageNotification
                                 object:nil];
        [notificationCenter addObserver:self
                               selector:@selector(handleClientMessageProcessingStateChange:)
                                   name:kPNClientMessageSendingDidFailNotification
                                 object:nil];

        // Handle messages/presence event arrival
        [notificationCenter addObserver:self
                               selector:@selector(handleClientDidReceiveMessage:)
                                   name:kPNClientDidReceiveMessageNotification
                                 object:nil];
        [notificationCenter addObserver:self
                               selector:@selector(handleClientDidReceivePresenceEvent:)
                                   name:kPNClientDidReceivePresenceEventNotification
                                 object:nil];

        // Handle message history events arrival
        [notificationCenter addObserver:self
                               selector:@selector(handleClientMessageHistoryProcess:)
                                   name:kPNClientDidReceiveMessagesHistoryNotification
                                 object:nil];
        [notificationCenter addObserver:self
                               selector:@selector(handleClientMessageHistoryProcess:)
                                   name:kPNClientHistoryDownloadFailedWithErrorNotification
                                 object:nil];

        // Handle participants list arrival
        [notificationCenter addObserver:self
                               selector:@selector(handleClientHereNowProcess:)
                                   name:kPNClientDidReceiveParticipantsListNotification
                                 object:nil];
        [notificationCenter addObserver:self
                               selector:@selector(handleClientHereNowProcess:)
                                   name:kPNClientParticipantsListDownloadFailedWithErrorNotification
                                 object:nil];
        
        
    }
    
    
    return self;
}

- (BOOL)isSubscribedOnClientStateChange:(id)observer {

    NSMutableArray *observersData = [self oneTimeObserversForEvent:PNObservationEvents.clientConnectionStateChange];
    NSArray *observers = [observersData valueForKey:PNObservationObserverData.observer];


    return [observers containsObject:observer];
}

- (void)removeOneTimeObserversForEvent:(NSString *)eventName {

    [self.oneTimeObservers removeObjectForKey:eventName];
}

- (void)addObserver:(id)observer forEvent:(NSString *)eventName oneTimeEvent:(BOOL)isOneTimeEvent withBlock:(id)block {

    NSMutableDictionary *observerData = [@{PNObservationObserverData.observer:observer,
                              PNObservationObserverData.observerCallbackBlock:block} mutableCopy];

    // Retrieve reference on list of observers for specific event
    SEL observersSelector = isOneTimeEvent?@selector(oneTimeObserversForEvent:): @selector(persistentObserversForEvent:);

    // Turn off error warning on performSelector, because ARC
    // can't understand what is goingon there
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSMutableArray *observers = [self performSelector:observersSelector withObject:eventName];
    #pragma clang diagnostic pop

    [observers addObject:observerData];
}

- (void)removeObserver:(id)observer forEvent:(NSString *)eventName oneTimeEvent:(BOOL)isOneTimeEvent {

    // Retrieve reference on list of observers for specific event
    SEL observersSelector = isOneTimeEvent?@selector(oneTimeObserversForEvent:): @selector(persistentObserversForEvent:);

    // Turn off error warning on performSelector, because ARC
    // can't understand what is goingon there
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSMutableArray *observers = [self performSelector:observersSelector withObject:eventName];
    #pragma clang diagnostic pop

    // Retrieve list of observing requests with specified observer
    NSString *filterFormat = [NSString stringWithFormat:@"%@ = %%@", PNObservationObserverData.observer];
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:filterFormat, observer];

    NSArray *filteredObservers = [observers filteredArrayUsingPredicate:filterPredicate];

    
    if ([filteredObservers count] > 0) {

        // Removing first occurrence of observer request in list
        [observers removeObject:[filteredObservers objectAtIndex:0]];
    }
}


#pragma mark - Client connection state observation

- (void)addClientConnectionStateObserver:(id)observer
                       withCallbackBlock:(PNClientConnectionStateChangeBlock)callbackBlock {

    [self addClientConnectionStateObserver:observer oneTimeEvent:NO withCallbackBlock:callbackBlock];
}

- (void)removeClientConnectionStateObserver:(id)observer {

    [self removeClientConnectionStateObserver:observer oneTimeEvent:NO];
}

- (void)addClientConnectionStateObserver:(id)observer
                            oneTimeEvent:(BOOL)isOneTimeEventObserver
                       withCallbackBlock:(PNClientConnectionStateChangeBlock)callbackBlock {

    [self addObserver:observer
             forEvent:PNObservationEvents.clientConnectionStateChange
         oneTimeEvent:isOneTimeEventObserver
            withBlock:callbackBlock];

}

- (void)removeClientConnectionStateObserver:(id)observer oneTimeEvent:(BOOL)isOneTimeEventObserver {

    [self removeObserver:observer
                forEvent:PNObservationEvents.clientConnectionStateChange
            oneTimeEvent:isOneTimeEventObserver];
}


#pragma mark - Client channels action/event observation

- (void)addClientChannelSubscriptionStateObserver:(id)observer

                           withCallbackBlock:(PNClientChannelSubscriptionHandlerBlock)callbackBlock {

    [self addObserver:observer
             forEvent:PNObservationEvents.clientSubscriptionOnChannels
         oneTimeEvent:NO
            withBlock:callbackBlock];
}

- (void)removeClientChannelSubscriptionStateObserver:(id)observer {

    [self removeObserver:observer forEvent:PNObservationEvents.clientSubscriptionOnChannels oneTimeEvent:NO];
}

- (void)addClientChannelUnsubscriptionObserver:(id)observer
                             withCallbackBlock:(PNClientChannelUnsubscriptionHandlerBlock)callbackBlock {

    [self addObserver:observer
             forEvent:PNObservationEvents.clientUnsubscribeFromChannels
         oneTimeEvent:NO
            withBlock:callbackBlock];
}

- (void)removeClientChannelUnsubscriptionObserver:(id)observer {

    [self removeObserver:observer forEvent:PNObservationEvents.clientUnsubscribeFromChannels oneTimeEvent:NO];
}


#pragma mark - Subscription observation

- (void)addClientAsSubscriptionObserverWithBlock:(PNClientChannelSubscriptionHandlerBlock)handleBlock {

    [self addObserver:[PubNub sharedInstance]
             forEvent:PNObservationEvents.clientSubscriptionOnChannels
         oneTimeEvent:YES
            withBlock:handleBlock];
}

- (void)removeClientAsSubscriptionObserver {

    [self removeObserver:[PubNub sharedInstance]
                forEvent:PNObservationEvents.clientSubscriptionOnChannels
            oneTimeEvent:YES];
}

- (void)addClientAsUnsubscribeObserverWithBlock:(PNClientChannelUnsubscriptionHandlerBlock)handleBlock {

    [self addObserver:[PubNub sharedInstance]
             forEvent:PNObservationEvents.clientUnsubscribeFromChannels
         oneTimeEvent:YES
            withBlock:handleBlock];
}

- (void)removeClientAsUnsubscribeObserver {

    [self removeObserver:[PubNub sharedInstance]
                forEvent:PNObservationEvents.clientUnsubscribeFromChannels
            oneTimeEvent:YES];
}


#pragma mark - Channels presence enable/disable observers

- (void)addClientAsPresenceEnablingObserverWithBlock:(PNClientPresenceEnableHandlingBlock)handlerBlock {

    [self addObserver:[PubNub sharedInstance]
             forEvent:PNObservationEvents.clientPresenceEnableOnChannels
         oneTimeEvent:YES
            withBlock:handlerBlock];
}

- (void)removeClientAsPresenceEnabling {

    [self removeObserver:[PubNub sharedInstance]
                forEvent:PNObservationEvents.clientPresenceEnableOnChannels
            oneTimeEvent:YES];
}

- (void)addClientAsPresenceDisablingObserverWithBlock:(PNClientPresenceDisableHandlingBlock)handlerBlock {

    [self addObserver:[PubNub sharedInstance]
             forEvent:PNObservationEvents.clientPresenceDisableOnChannels
         oneTimeEvent:YES
            withBlock:handlerBlock];
}

- (void)removeClientAsPresenceDisabling {

    [self removeObserver:[PubNub sharedInstance]
                forEvent:PNObservationEvents.clientPresenceDisableOnChannels
            oneTimeEvent:YES];
}

- (void)addClientPresenceEnablingObserver:(id)observer withCallbackBlock:(PNClientPresenceEnableHandlingBlock)handlerBlock {

    [self addObserver:observer
             forEvent:PNObservationEvents.clientPresenceEnableOnChannels
         oneTimeEvent:NO
            withBlock:handlerBlock];
}

- (void)removeClientPresenceEnablingObserver:(id)observer {

    [self removeObserver:observer
                forEvent:PNObservationEvents.clientPresenceEnableOnChannels
            oneTimeEvent:NO];
}

- (void)addClientAsPresenceDisablingObserver:(id)observer withCallbackBlock:(PNClientPresenceDisableHandlingBlock)handlerBlock {

    [self addObserver:observer
             forEvent:PNObservationEvents.clientPresenceDisableOnChannels
         oneTimeEvent:NO
            withBlock:handlerBlock];
}

- (void)removeClientAsPresenceDisablingObserver:(id)observer {

    [self removeObserver:observer
                forEvent:PNObservationEvents.clientPresenceDisableOnChannels
            oneTimeEvent:NO];
}


#pragma mark - APNS interaction observation

- (void)addClientAsPushNotificationsEnableObserverWithBlock:(PNClientPushNotificationsEnableHandlingBlock)handlerBlock {

    [self addObserver:[PubNub sharedInstance]
             forEvent:PNObservationEvents.clientPushNotificationEnabling
         oneTimeEvent:YES
            withBlock:handlerBlock];
}

- (void)removeClientAsPushNotificationsEnableObserver {

    [self removeObserver:[PubNub sharedInstance]
                forEvent:PNObservationEvents.clientPushNotificationEnabling
            oneTimeEvent:YES];
}

- (void)addClientPushNotificationsEnableObserver:(id)observer
                               withCallbackBlock:(PNClientPushNotificationsEnableHandlingBlock)handlerBlock {

    [self addObserver:observer
             forEvent:PNObservationEvents.clientPushNotificationEnabling
         oneTimeEvent:NO
            withBlock:handlerBlock];
}

- (void)removeClientPushNotificationsEnableObserver:(id)observer {

    [self removeObserver:observer
                forEvent:PNObservationEvents.clientPushNotificationEnabling
            oneTimeEvent:NO];
}

- (void)addClientAsPushNotificationsDisableObserverWithBlock:(PNClientPushNotificationsDisableHandlingBlock)handlerBlock {

    [self addObserver:[PubNub sharedInstance]
             forEvent:PNObservationEvents.clientPushNotificationDisabling
         oneTimeEvent:YES
            withBlock:handlerBlock];
}

- (void)removeClientAsPushNotificationsDisableObserver {

    [self removeObserver:[PubNub sharedInstance]
                forEvent:PNObservationEvents.clientPushNotificationDisabling
            oneTimeEvent:YES];
}

- (void)addClientPushNotificationsDisableObserver:(id)observer
                                withCallbackBlock:(PNClientPushNotificationsDisableHandlingBlock)handlerBlock {

    [self addObserver:observer
             forEvent:PNObservationEvents.clientPushNotificationDisabling
         oneTimeEvent:NO
            withBlock:handlerBlock];
}

- (void)removeClientPushNotificationsDisableObserver:(id)observer {

    [self removeObserver:observer
                forEvent:PNObservationEvents.clientPushNotificationDisabling
            oneTimeEvent:NO];
}

- (void)addClientAsPushNotificationsEnabledChannelsObserverWithBlock:(PNClientPushNotificationsEnabledChannelsHandlingBlock)handlerBlock {

    [self addObserver:[PubNub sharedInstance]
             forEvent:PNObservationEvents.clientPushNotificationEnabledChannelsRetrieval
         oneTimeEvent:YES
            withBlock:handlerBlock];
}

- (void)removeClientAsPushNotificationsEnabledChannelsObserver {

    [self removeObserver:[PubNub sharedInstance]
                forEvent:PNObservationEvents.clientPushNotificationEnabledChannelsRetrieval
            oneTimeEvent:YES];
}

- (void)addClientPushNotificationsEnabledChannelsObserver:(id)observer
                                        withCallbackBlock:(PNClientPushNotificationsEnabledChannelsHandlingBlock)handlerBlock {

    [self addObserver:observer
             forEvent:PNObservationEvents.clientPushNotificationEnabledChannelsRetrieval
         oneTimeEvent:NO
            withBlock:handlerBlock];
}

- (void)removeClientPushNotificationsEnabledChannelsObserver:(id)observer {

    [self removeObserver:observer
                forEvent:PNObservationEvents.clientPushNotificationEnabledChannelsRetrieval
            oneTimeEvent:NO];
}

- (void)addClientAsPushNotificationsRemoveObserverWithBlock:(PNClientPushNotificationsRemoveHandlingBlock)handlerBlock {

    [self addObserver:[PubNub sharedInstance]
             forEvent:PNObservationEvents.clientPushNotificationRemovalForAllChannels
         oneTimeEvent:YES
            withBlock:handlerBlock];
}

- (void)removeClientAsPushNotificationsRemoveObserver {

    [self removeObserver:[PubNub sharedInstance]
                forEvent:PNObservationEvents.clientPushNotificationRemovalForAllChannels
            oneTimeEvent:YES];
}

- (void)addClientPushNotificationsRemoveObserver:(id)observer
                               withCallbackBlock:(PNClientPushNotificationsRemoveHandlingBlock)handlerBlock {

    [self addObserver:observer
             forEvent:PNObservationEvents.clientPushNotificationRemovalForAllChannels
         oneTimeEvent:NO
            withBlock:handlerBlock];
}

- (void)removeClientPushNotificationsRemoveObserver:(id)observer {

    [self removeObserver:observer
                forEvent:PNObservationEvents.clientPushNotificationRemovalForAllChannels
            oneTimeEvent:NO];
}


#pragma mark - Time token observation

- (void)addClientAsTimeTokenReceivingObserverWithCallbackBlock:(PNClientTimeTokenReceivingCompleteBlock)callbackBlock {

    [self addObserver:[PubNub sharedInstance]
             forEvent:PNObservationEvents.clientTimeTokenReceivingComplete
         oneTimeEvent:YES
            withBlock:callbackBlock];
}

- (void)removeClientAsTimeTokenReceivingObserver {

    [self removeObserver:[PubNub sharedInstance]
                forEvent:PNObservationEvents.clientTimeTokenReceivingComplete
            oneTimeEvent:YES];
}

- (void)addTimeTokenReceivingObserver:(id)observer
                    withCallbackBlock:(PNClientTimeTokenReceivingCompleteBlock)callbackBlock {

    [self addObserver:observer
             forEvent:PNObservationEvents.clientTimeTokenReceivingComplete
         oneTimeEvent:NO
            withBlock:callbackBlock];
}

- (void)removeTimeTokenReceivingObserver:(id)observer {

    [self removeObserver:observer forEvent:PNObservationEvents.clientTimeTokenReceivingComplete oneTimeEvent:NO];
}


#pragma mark - Message sending observers

- (void)addClientAsMessageProcessingObserverWithBlock:(PNClientMessageProcessingBlock)handleBlock {

    [self addMessageProcessingObserver:[PubNub sharedInstance] withBlock:handleBlock oneTimeEvent:YES];

}
- (void)removeClientAsMessageProcessingObserver {

    [self removeMessageProcessingObserver:[PubNub sharedInstance] oneTimeEvent:YES];
}

- (void)addMessageProcessingObserver:(id)observer withBlock:(PNClientMessageProcessingBlock)handleBlock {

    [self addMessageProcessingObserver:observer withBlock:handleBlock oneTimeEvent:NO];
}

- (void)removeMessageProcessingObserver:(id)observer {

    [self removeMessageProcessingObserver:observer oneTimeEvent:NO];
}

- (void)addMessageProcessingObserver:(id)observer
                           withBlock:(PNClientMessageProcessingBlock)handleBlock
                        oneTimeEvent:(BOOL)isOneTimeEventObserver {

    [self addObserver:observer
             forEvent:PNObservationEvents.clientMessageSendCompletion
         oneTimeEvent:isOneTimeEventObserver
            withBlock:handleBlock];
}

- (void)removeMessageProcessingObserver:(id)observer oneTimeEvent:(BOOL)isOneTimeEventObserver {

    [self removeObserver:observer
                forEvent:PNObservationEvents.clientMessageSendCompletion
            oneTimeEvent:isOneTimeEventObserver];
}

- (void)addMessageReceiveObserver:(id)observer withBlock:(PNClientMessageHandlingBlock)handleBlock {

    [self addObserver:observer
             forEvent:PNObservationEvents.clientReceivedMessage
         oneTimeEvent:NO
            withBlock:handleBlock];
}

- (void)removeMessageReceiveObserver:(id)observer {

    [self removeObserver:observer
                forEvent:PNObservationEvents.clientReceivedMessage
            oneTimeEvent:NO];
}


#pragma mark - Presence observing

- (void)addPresenceEventObserver:(id)observer withBlock:(PNClientPresenceEventHandlingBlock)handleBlock {

    [self addObserver:observer
             forEvent:PNObservationEvents.clientReceivedPresenceEvent
         oneTimeEvent:NO
            withBlock:handleBlock];
}

- (void)removePresenceEventObserver:(id)observer {

    [self removeObserver:observer
                forEvent:PNObservationEvents.clientReceivedPresenceEvent
            oneTimeEvent:NO];
}


#pragma mark - History observers

- (void)addClientAsHistoryDownloadObserverWithBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {

    [self addObserver:[PubNub sharedInstance]
             forEvent:PNObservationEvents.clientReceivedHistory
         oneTimeEvent:YES
            withBlock:handleBlock];
}

- (void)removeClientAsHistoryDownloadObserver {

    [self removeObserver:[PubNub sharedInstance]
                forEvent:PNObservationEvents.clientReceivedHistory
            oneTimeEvent:YES];
}

- (void)addMessageHistoryProcessingObserver:(id)observer withBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {

    [self addObserver:observer
             forEvent:PNObservationEvents.clientReceivedHistory
         oneTimeEvent:NO
            withBlock:handleBlock];
}

- (void)removeMessageHistoryProcessingObserver:(id)observer {

    [self removeObserver:observer
                forEvent:PNObservationEvents.clientReceivedHistory
            oneTimeEvent:NO];
}


#pragma mark - Participants observer

- (void)addClientAsParticipantsListDownloadObserverWithBlock:(PNClientParticipantsHandlingBlock)handleBlock {

    [self addObserver:[PubNub sharedInstance]
             forEvent:PNObservationEvents.clientReceivedParticipantsList
         oneTimeEvent:YES
            withBlock:handleBlock];

}

- (void)removeClientAsParticipantsListDownloadObserver {

    [self removeObserver:[PubNub sharedInstance]
                forEvent:PNObservationEvents.clientReceivedParticipantsList
            oneTimeEvent:NO];
}


#pragma mark - Participants observing

- (void)addChannelParticipantsListProcessingObserver:(id)observer
                                           withBlock:(PNClientParticipantsHandlingBlock)handleBlock {

    [self addObserver:observer
             forEvent:PNObservationEvents.clientReceivedParticipantsList
         oneTimeEvent:NO
            withBlock:handleBlock];
}

- (void)removeChannelParticipantsListProcessingObserver:(id)observer {

    [self removeObserver:observer
                forEvent:PNObservationEvents.clientReceivedParticipantsList
            oneTimeEvent:NO];
}


#pragma mark - Handler methods

- (void)handleClientConnectionStateChange:(NSNotification *)notification {
    
    // Default field values
    BOOL connected = YES;
    PNError *connectionError = nil;
    NSString *origin = [PubNub sharedInstance].configuration.origin;
    
    if([notification.name isEqualToString:kPNClientDidConnectToOriginNotification] ||
       [notification.name isEqualToString:kPNClientDidDisconnectFromOriginNotification]) {
        
        origin = (NSString *)notification.userInfo;
        connected = [notification.name isEqualToString:kPNClientDidConnectToOriginNotification];
    }
    else if([notification.name isEqualToString:kPNClientConnectionDidFailWithErrorNotification]) {
        
        connected = NO;
        connectionError = (PNError *)notification.userInfo;
    }

    // Retrieving list of observers (including one time and persistent observers)
    NSArray *observers = [self observersForEvent:PNObservationEvents.clientConnectionStateChange];

    // Clean one time observers for specific event
    [self removeOneTimeObserversForEvent:PNObservationEvents.clientConnectionStateChange];
    [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                            NSUInteger observerDataIdx,
                                            BOOL *observerDataEnumeratorStop) {

        // Call handling blocks
        PNClientConnectionStateChangeBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
        if (block) {

            block(origin, connected, connectionError);
        }
    }];
}

- (void)handleClientSubscriptionProcess:(NSNotification *)notification {

    NSArray *channels = nil;
    PNError *error = nil;
    PNSubscriptionProcessState state = PNSubscriptionProcessNotSubscribedState;

    // Check whether arrived notification that subscription failed or not
    if ([notification.name isEqualToString:kPNClientSubscriptionDidFailNotification]) {

        error = (PNError *)notification.userInfo;
        channels = error.associatedObject;
    }
    else {

        // Retrieve list of channels on which event is occurred
        channels = (NSArray *)notification.userInfo;
        state = PNSubscriptionProcessSubscribedState;

        // Check whether arrived notification that subscription will be restored
        if ([notification.name isEqualToString:kPNClientSubscriptionWillRestoreNotification]) {

            state = PNSubscriptionProcessWillRestoreState;
        }
        // Check whether arrived notification that subscription restored
        else if ([notification.name isEqualToString:kPNClientSubscriptionDidRestoreNotification]) {

            state = PNSubscriptionProcessRestoredState;
        }
    }


    // Retrieving list of observers (including one time and persistent observers)
    NSArray *observers = [self observersForEvent:PNObservationEvents.clientSubscriptionOnChannels];

    // Clean one time observers for specific event
    [self removeOneTimeObserversForEvent:PNObservationEvents.clientSubscriptionOnChannels];

    [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                            NSUInteger observerDataIdx,
                                            BOOL *observerDataEnumeratorStop) {

        // Call handling blocks
        PNClientChannelSubscriptionHandlerBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
        if (block) {

            block(state, channels, error);
        }
    }];
}

- (void)handleClientUnsubscriptionProcess:(NSNotification *)notification {

    NSArray *channels = nil;
    PNError *error = nil;
    if ([notification.name isEqualToString:kPNClientUnsubscriptionDidCompleteNotification]) {

        channels = (NSArray *)notification.userInfo;
    }
    else {

        error = (PNError *)notification.userInfo;
        channels = (NSArray *)error.associatedObject;
    }

    // Retrieving list of observers (including one time and persistent observers)
    NSArray *observers = [self observersForEvent:PNObservationEvents.clientUnsubscribeFromChannels];

    // Clean one time observers for specific event
    [self removeOneTimeObserversForEvent:PNObservationEvents.clientUnsubscribeFromChannels];

    [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                            NSUInteger observerDataIdx,
                                            BOOL *observerDataEnumeratorStop) {

        // Call handling blocks
        PNClientChannelUnsubscriptionHandlerBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
        if (block) {

            block(channels, error);
        }
    }];
}

- (void)handleClientPresenceObservationEnablingProcess:(NSNotification *)notification {

    NSArray *channels = nil;
    PNError *error = nil;
    if ([notification.name isEqualToString:kPNClientPresenceEnablingDidCompleteNotification]) {

        channels = (NSArray *)notification.userInfo;
    }
    else {

        error = (PNError *)notification.userInfo;
        channels = (NSArray *)error.associatedObject;
    }

    // Retrieving list of observers (including one time and persistent observers)
    NSArray *observers = [self observersForEvent:PNObservationEvents.clientPresenceEnableOnChannels];

    // Clean one time observers for specific event
    [self removeOneTimeObserversForEvent:PNObservationEvents.clientPresenceEnableOnChannels];

    [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                            NSUInteger observerDataIdx,
                                            BOOL *observerDataEnumeratorStop) {

        // Call handling blocks
        PNClientPresenceEnableHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
        if (block) {

            block(channels, error);
        }
    }];
}

- (void)handleClientPresenceObservationDisablingProcess:(NSNotification *)notification {

    NSArray *channels = nil;
    PNError *error = nil;
    if ([notification.name isEqualToString:kPNClientPresenceDisablingDidCompleteNotification]) {

        channels = (NSArray *)notification.userInfo;
    }
    else {

        error = (PNError *)notification.userInfo;
        channels = (NSArray *)error.associatedObject;
    }

    // Retrieving list of observers (including one time and persistent observers)
    NSArray *observers = [self observersForEvent:PNObservationEvents.clientPresenceDisableOnChannels];

    // Clean one time observers for specific event
    [self removeOneTimeObserversForEvent:PNObservationEvents.clientPresenceDisableOnChannels];

    [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                            NSUInteger observerDataIdx,
                                            BOOL *observerDataEnumeratorStop) {

        // Call handling blocks
        PNClientPresenceDisableHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
        if (block) {

            block(channels, error);
        }
    }];
}

- (void)handleClientPushNotificationStateChange:(NSNotification *)notification {

    BOOL isEnablingPushNotifications = YES;
    NSString *eventName = PNObservationEvents.clientPushNotificationEnabling;
    if ([notification.name isEqualToString:kPNClientPushNotificationDisableDidCompleteNotification]) {

        isEnablingPushNotifications = NO;
        eventName = PNObservationEvents.clientPushNotificationDisabling;
    }
    NSArray *channels = nil;
    PNError *error = nil;
    if ([notification.name isEqualToString:kPNClientPushNotificationEnableDidCompleteNotification] ||
        [notification.name isEqualToString:kPNClientPushNotificationDisableDidCompleteNotification]) {

        channels = (NSArray *)notification.userInfo;
    }
    else {

        error = (PNError *)notification.userInfo;
        channels = error.associatedObject;
    }


    // Retrieving list of observers (including one time and persistent observers)
    NSArray *observers = [self observersForEvent:eventName];

    // Clean one time observers for specific event
    [self removeOneTimeObserversForEvent:eventName];

    [observers enumerateObjectsUsingBlock:^(NSDictionary *observerData,
                                                NSUInteger observerDataIdx,
                                                BOOL *observerDataEnumeratorStop) {

        // Receive reference on handling block
        id block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
        if (block) {

            if (isEnablingPushNotifications) {

                ((PNClientPushNotificationsEnableHandlingBlock)block)(channels, error);
            }
            else {

                ((PNClientPushNotificationsDisableHandlingBlock)block)(channels, error);
            }
        }
    }];
}

- (void)handleClientPushNotificationRemoveProcess:(NSNotification *)notification {

    PNError *error = nil;
    if (![notification.name isEqualToString:kPNClientPushNotificationRemoveDidCompleteNotification]) {

        error = (PNError *)notification.userInfo;
    }


    // Retrieving list of observers (including one time and persistent observers)
    NSArray *observers = [self observersForEvent:PNObservationEvents.clientPushNotificationRemovalForAllChannels];

    // Clean one time observers for specific event
    [self removeOneTimeObserversForEvent:PNObservationEvents.clientPushNotificationRemovalForAllChannels];

    [observers enumerateObjectsUsingBlock:^(NSDictionary *observerData,
                                                NSUInteger observerDataIdx,
                                                BOOL *observerDataEnumeratorStop) {

        // Receive reference on handling block
        PNClientPushNotificationsRemoveHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
        if (block) {

            block(error);
        }
    }];
}

- (void)handleClientPushNotificationEnabledChannels:(NSNotification *)notification {

    NSArray *channels = nil;
    PNError *error = nil;
    if ([notification.name isEqualToString:kPNClientPushNotificationChannelsRetrieveDidCompleteNotification]) {

        channels = (NSArray *)notification.userInfo;
    }
    else {

        error = (PNError *)notification.userInfo;
    }


    // Retrieving list of observers (including one time and persistent observers)
    NSArray *observers = [self observersForEvent:PNObservationEvents.clientPushNotificationEnabledChannelsRetrieval];

    // Clean one time observers for specific event
    [self removeOneTimeObserversForEvent:PNObservationEvents.clientPushNotificationEnabledChannelsRetrieval];

    [observers enumerateObjectsUsingBlock:^(NSDictionary *observerData,
                                                NSUInteger observerDataIdx,
                                                BOOL *observerDataEnumeratorStop) {

        // Receive reference on handling block
        PNClientPushNotificationsEnabledChannelsHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
        if (block) {

            block(channels, error);
        }
    }];
}

- (void)handleClientMessageProcessingStateChange:(NSNotification *)notification {

    PNMessageState state = PNMessageSending;
    id processingData = nil;
    BOOL shouldUnsubscribe = NO;
    if ([notification.name isEqualToString:kPNClientMessageSendingDidFailNotification]) {

        state = PNMessageSendingError;
        shouldUnsubscribe = YES;
        processingData = (PNError *)notification.userInfo;
    }
    else {

        shouldUnsubscribe = [notification.name isEqualToString:kPNClientDidSendMessageNotification];
        if (shouldUnsubscribe) {

            state = PNMessageSent;
        }
        processingData = (PNMessage *)notification.userInfo;
    }

    // Retrieving list of observers (including one time and persistent observers)
    NSArray *observers = [self observersForEvent:PNObservationEvents.clientMessageSendCompletion];

    if (shouldUnsubscribe) {

        // Clean one time observers for specific event
        [self removeOneTimeObserversForEvent:PNObservationEvents.clientMessageSendCompletion];
    }

    [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                            NSUInteger observerDataIdx,
                                            BOOL *observerDataEnumeratorStop) {

        // Call handling blocks
        PNClientMessageProcessingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
        if (block) {

            block(state, processingData);
        }
    }];
}

- (void)handleClientDidReceiveMessage:(NSNotification *)notification {

    // Retrieve reference on message which was received
    PNMessage *message = (PNMessage *)notification.userInfo;


    // Retrieving list of observers
    NSArray *observers = [self observersForEvent:PNObservationEvents.clientReceivedMessage];

    [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                            NSUInteger observerDataIdx,
                                            BOOL *observerDataEnumeratorStop) {

        // Call handling blocks
        PNClientMessageHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
        if (block) {

            block(message);
        }
    }];
}

- (void)handleClientDidReceivePresenceEvent:(NSNotification *)notification {

    // Retrieve reference on presence event which was received
    PNPresenceEvent *presenceEvent = (PNPresenceEvent *)notification.userInfo;


    // Retrieving list of observers
    NSArray *observers = [self observersForEvent:PNObservationEvents.clientReceivedPresenceEvent];

    [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                            NSUInteger observerDataIdx,
                                            BOOL *observerDataEnumeratorStop) {

        // Call handling blocks
        PNClientPresenceEventHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
        if (block) {

            block(presenceEvent);
        }
    }];
}

- (void)handleClientMessageHistoryProcess:(NSNotification *)notification {

    // Retrieve reference on history object
    PNMessagesHistory *history = nil;
    PNChannel *channel = nil;
    PNError *error = nil;
    if ([notification.name isEqualToString:kPNClientDidReceiveMessagesHistoryNotification]) {

        history = (PNMessagesHistory *)notification.userInfo;
        channel = history.channel;
    }
    else {

        error = (PNError *)notification.userInfo;
        channel = error.associatedObject;
    }

    // Retrieving list of observers (including one time and persistent observers)
    NSArray *observers = [self observersForEvent:PNObservationEvents.clientReceivedHistory];

    // Clean one time observers for specific event
    [self removeOneTimeObserversForEvent:PNObservationEvents.clientReceivedHistory];

    [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                            NSUInteger observerDataIdx,
                                            BOOL *observerDataEnumeratorStop) {

        // Call handling blocks
        PNClientHistoryLoadHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
        if (block) {

            block(history.messages, channel, history.startDate, history.endDate, error);
        }
    }];
}

- (void)handleClientHereNowProcess:(NSNotification *)notification {

    // Retrieve reference on participants object
    PNHereNow *participants = nil;
    PNChannel *channel = nil;
    PNError *error = nil;
    if ([notification.name isEqualToString:kPNClientDidReceiveParticipantsListNotification]) {

        participants = (PNHereNow *)notification.userInfo;
        channel = participants.channel;
    }
    else {

        error = (PNError *)notification.userInfo;
        channel = error.associatedObject;
    }

    // Retrieving list of observers (including one time and persistent observers)
    NSArray *observers = [self observersForEvent:PNObservationEvents.clientReceivedParticipantsList];

    // Clean one time observers for specific event
    [self removeOneTimeObserversForEvent:PNObservationEvents.clientReceivedParticipantsList];

    [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                            NSUInteger observerDataIdx,
                                            BOOL *observerDataEnumeratorStop) {

        // Call handling blocks
        PNClientParticipantsHandlingBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
        if (block) {

            block(participants.participants, channel, error);
        }
    }];
}

- (void)handleClientCompletedTimeTokenProcessing:(NSNotification *)notification {

    PNError *error = nil;
    NSNumber *timeToken = nil;
    if ([[notification name] isEqualToString:kPNClientDidReceiveTimeTokenNotification]) {

        timeToken = (NSNumber *)notification.userInfo;
    }
    else {

        error = (PNError *)notification.userInfo;
    }

    // Retrieving list of observers (including one time and persistent observers)
    NSArray *observers = [self observersForEvent:PNObservationEvents.clientTimeTokenReceivingComplete];

    // Clean one time observers for specific event
    [self removeOneTimeObserversForEvent:PNObservationEvents.clientTimeTokenReceivingComplete];

    [observers enumerateObjectsUsingBlock:^(NSMutableDictionary *observerData,
                                            NSUInteger observerDataIdx,
                                            BOOL *observerDataEnumeratorStop) {

        // Call handling blocks
        PNClientTimeTokenReceivingCompleteBlock block = [observerData valueForKey:PNObservationObserverData.observerCallbackBlock];
        if (block) {

            block(timeToken, error);
        }
    }];
}


#pragma mark - Misc methods

- (NSMutableArray *)persistentObserversForEvent:(NSString *)eventName {

    if ([self.observers valueForKey:eventName] == nil) {
        
        [self.observers setValue:[NSMutableArray array] forKey:eventName];
    }
    
    
    return [self.observers valueForKey:eventName];
}

- (NSMutableArray *)oneTimeObserversForEvent:(NSString *)eventName {
    
    if ([self.oneTimeObservers valueForKey:eventName] == nil) {
        
        [self.oneTimeObservers setValue:[NSMutableArray array] forKey:eventName];
    }
    
    
    return [self.oneTimeObservers valueForKey:eventName];
}

- (NSMutableArray *)observersForEvent:(NSString *)eventName {

    NSMutableArray *persistentObservers = [self persistentObserversForEvent:eventName];
    NSMutableArray *oneTimeEventObservers = [self oneTimeObserversForEvent:eventName];


    // Composing full observers list depending on whether at least
    // one object exist in retrieved arrays
    NSMutableArray *allObservers = [NSMutableArray array];
    if ([persistentObservers count] > 0) {

        [allObservers addObjectsFromArray:persistentObservers];
    }

    if ([oneTimeEventObservers count] > 0) {

        [allObservers addObjectsFromArray:oneTimeEventObservers];
    }


    return allObservers;
}


#pragma mark - Memory management

- (void)dealloc {

    // Unsubscribe from all notifications
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:kPNClientDidConnectToOriginNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientDidDisconnectFromOriginNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientConnectionDidFailWithErrorNotification object:nil];

    [notificationCenter removeObserver:self name:kPNClientSubscriptionDidCompleteNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientSubscriptionWillRestoreNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientSubscriptionDidRestoreNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientSubscriptionDidFailNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientUnsubscriptionDidCompleteNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientUnsubscriptionDidFailNotification object:nil];

    [notificationCenter removeObserver:self name:kPNClientPresenceEnablingDidCompleteNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientPresenceEnablingDidFailNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientPresenceDisablingDidCompleteNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientPresenceDisablingDidFailNotification object:nil];

    [notificationCenter removeObserver:self name:kPNClientDidReceiveTimeTokenNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientDidFailTimeTokenReceiveNotification object:nil];

    [notificationCenter removeObserver:self name:kPNClientWillSendMessageNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientDidSendMessageNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientMessageSendingDidFailNotification object:nil];

    [notificationCenter removeObserver:self name:kPNClientDidReceiveMessageNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientDidReceivePresenceEventNotification object:nil];

    [notificationCenter removeObserver:self name:kPNClientDidReceiveMessagesHistoryNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientHistoryDownloadFailedWithErrorNotification object:nil];

    [notificationCenter removeObserver:self name:kPNClientDidReceiveParticipantsListNotification object:nil];
    [notificationCenter removeObserver:self name:kPNClientParticipantsListDownloadFailedWithErrorNotification object:nil];

    PNLog(PNLogGeneralLevel, self, @"Destroyed");
}

#pragma mark -


@end
