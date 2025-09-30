/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.0.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNStateListener.h"
#import "PNSubscribeEventData+Private.h"
#import "PNDictionaryLogEntry+Private.h"
#import "PubNub+CorePrivate.h"
#import "PNSubscribeStatus.h"
#import "PNEventsListener.h"
#import "PNFunctions.h"
#import "PNHelpers.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNStateListener ()


#pragma mark - Information 

/**
 * @brief Weak reference on client for which state listeners manager created.
 */
@property (nonatomic, weak) PubNub *client;

/**
 * @brief List of listeners which would like to be notified when new message arrive from remote data
 * feed objects on which client subscribed at this moment.
 *
 * @return Hash table with list of new message listeners.
 */
@property (nonatomic, strong) NSHashTable<id <PNEventsListener>> *messageListeners;

/**
 * @brief List of listeners which would like to be notified when new signal arrive from remote data
 * feed objects on which client subscribed at this moment.
 *
 * @return Hash table with list of new \c signal listeners.
 *
 * @since 4.9.0
 */
@property (nonatomic, strong) NSHashTable<id <PNEventsListener>> *signalListeners;

/**
 * @brief List of listeners which would like to be notified when new \c message \c actions
 * arrive from remote data feed objects on which client subscribed at this moment.
 *
 * @return Hash table with list of new \c action listeners.
 *
 * @since 4.11.0
 */
@property (nonatomic, strong) NSHashTable<id <PNEventsListener>> *messageActionListeners;

/**
 * @brief List of listeners which would like to be notified when new presence event arrive from
 * remote data feed objects on which client subscribed at this moment.
 *
 * @return Hash table with list of presence event listeners.
 */
@property (nonatomic, strong) NSHashTable<id <PNEventsListener>> *presenceEventListeners;

/**
 * @brief List of listeners which would like to be notified when new \c object event arrive from
 * remote data feed objects on which client subscribed at this moment.
 *
 * @return Hash table with list of \c object event listeners.
 *
 * @since 4.14.0
 */
@property (nonatomic, strong) NSHashTable<id <PNEventsListener>> *objectEventListeners;

/**
 * @brief List of listeners which would like to be notified when new \c file event arrive from
 * remote data feed objects on which client subscribed at this moment.
 *
 * @return Hash table with list of \c file event listeners.
 *
 * @since 4.15.0
 */
@property (nonatomic, strong) NSHashTable<id <PNEventsListener>> *fileEventListeners;

/**
 * @brief List of listeners which would like to be notified when on subscription state changes
 * (connection, access rights error, disconnection and unexpected disconnection).
 */
@property (nonatomic, strong) NSHashTable<id <PNEventsListener>> *stateListeners;

/**
 * @brief Queue which is used to serialize access to shared listener information.
 */
@property (nonatomic, strong) dispatch_queue_t resourceAccessQueue;


#pragma mark - Initialization and Configuration

/**
 * @brief Initialize state listener manager for concrete \b PubNub client instance.
 *
 * @param client Client for which manager should operate and use data.
 *
 * @return Initialized and ready to use state listener manager.
 */
- (instancetype)initForClient:(PubNub *)client;


#pragma mark - Notification

/**
 * @brief Notify all status event change subscriber about new event.
 *
 * @param status State object which describe operation and category.
 */
- (void)notifyStatusObservers:(PNStatus *)status;


#pragma mark - Misc

/**
 * @brief Make copy of listeners from specified collection.
 *
 * @param listeners Collection from which event listeners should be copied.
 *
 * @return Listeners copy.
 */
- (NSHashTable *)listenersCopyFrom:(NSHashTable *)listeners;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNStateListener


#pragma mark - Initialization and Configuration

+ (instancetype)stateListenerForClient:(PubNub *)client {
    return [[self alloc] initForClient:client];
}

- (instancetype)initForClient:(PubNub *)client {
    if ((self = [super init])) {
        _client = client;
        _messageListeners = [NSHashTable weakObjectsHashTable];
        _signalListeners = [NSHashTable weakObjectsHashTable];
        _messageActionListeners = [NSHashTable weakObjectsHashTable];
        _presenceEventListeners = [NSHashTable weakObjectsHashTable];
        _objectEventListeners = [NSHashTable weakObjectsHashTable];
        _fileEventListeners = [NSHashTable weakObjectsHashTable];
        _stateListeners = [NSHashTable weakObjectsHashTable];
        _resourceAccessQueue = dispatch_queue_create("com.pubnub.listener", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

- (void)inheritStateFromListener:(PNStateListener *)listener {
    if ([listener isEqual:self]) {
        return;
    }
    
    NSHashTable *messageListeners = [listener listenersCopyFrom:listener.messageListeners];
    NSHashTable *signalListeners = [listener listenersCopyFrom:listener.signalListeners];
    NSHashTable *actionListeners = [listener listenersCopyFrom:listener.messageActionListeners];
    NSHashTable *presenceEventListeners = [listener listenersCopyFrom:listener.presenceEventListeners];
    NSHashTable *objectEventListeners = [listener listenersCopyFrom:listener.objectEventListeners];
    NSHashTable *fileEventListeners = [listener listenersCopyFrom:listener.fileEventListeners];
    NSHashTable *stateListeners = [listener listenersCopyFrom:listener.stateListeners];
    
    dispatch_async(self.resourceAccessQueue, ^{
        self.messageListeners = messageListeners;
        self.signalListeners = signalListeners;
        self.messageActionListeners = actionListeners;
        self.presenceEventListeners = presenceEventListeners;
        self.objectEventListeners = objectEventListeners;
        self.fileEventListeners = fileEventListeners;
        self.stateListeners = stateListeners;
    });
}


#pragma mark - Listeners list modification

- (void)addListener:(id <PNEventsListener>)listener {
    dispatch_async(self.resourceAccessQueue, ^{
        if ([listener respondsToSelector:@selector(client:didReceiveMessage:)]) {
            [self.messageListeners addObject:listener];
        }
        
        if ([listener respondsToSelector:@selector(client:didReceiveSignal:)]) {
            [self.signalListeners addObject:listener];
        }
        
        if ([listener respondsToSelector:@selector(client:didReceiveMessageAction:)]) {
            [self.messageActionListeners addObject:listener];
        }
        
        if ([listener respondsToSelector:@selector(client:didReceivePresenceEvent:)]) {
            [self.presenceEventListeners addObject:listener];
        }
        
        if ([listener respondsToSelector:@selector(client:didReceiveObjectEvent:)]) {
            [self.objectEventListeners addObject:listener];
        }
        
        if ([listener respondsToSelector:@selector(client:didReceiveFileEvent:)]) {
            [self.fileEventListeners addObject:listener];
        }
        
        if ([listener respondsToSelector:@selector(client:didReceiveStatus:)]) {
            [self.stateListeners addObject:listener];
        }
    });
}

- (void)removeListener:(id <PNEventsListener>)listener {
    dispatch_async(self.resourceAccessQueue, ^{
        [self.messageListeners removeObject:listener];
        [self.signalListeners removeObject:listener];
        [self.messageActionListeners removeObject:listener];
        [self.presenceEventListeners removeObject:listener];
        [self.objectEventListeners removeObject:listener];
        [self.fileEventListeners removeObject:listener];
        [self.stateListeners removeObject:listener];
    });
}

- (void)removeAllListeners {
    dispatch_async(self.resourceAccessQueue, ^{
        [self.messageListeners removeAllObjects];
        [self.signalListeners removeAllObjects];
        [self.messageActionListeners removeAllObjects];
        [self.presenceEventListeners removeAllObjects];
        [self.objectEventListeners removeAllObjects];
        [self.fileEventListeners removeAllObjects];
        [self.stateListeners removeAllObjects];
    });
}


#pragma mark - Listeners notification

- (void)notifyWithBlock:(dispatch_block_t)block {
    dispatch_async(self.resourceAccessQueue, block);
}

- (void)notifyMessage:(PNMessageResult *)message {
    NSArray<id <PNEventsListener>> *listeners = self.messageListeners.allObjects;
    
    [self.client.logger debugWithLocation:@"PNStateListener" andMessageFactory:^PNLogEntry *{
        return [PNDictionaryLogEntry entryWithMessage:[message.data dictionaryRepresentation]
                                              details:@"Received message:"
                                            operation:PNSubscribeLogMessageOperation];
    }];
    
    /**
     * Silence static analyzer warnings.
     * Code is aware about this case and at the end will simply call on 'nil' object method.
     * In most cases if referenced object become 'nil' it mean what there is no more need in
     * it and probably whole client instance has been deallocated.
     */
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
    pn_dispatch_async(self.client.callbackQueue, ^{
        for (id <PNEventsListener> listener in listeners) {
            [listener client:self.client didReceiveMessage:message];
        }
    });
    #pragma clang diagnostic pop
}

- (void)notifySignal:(PNSignalResult *)signal {
    NSArray<id <PNEventsListener>> *listeners = self.signalListeners.allObjects;
    
    [self.client.logger debugWithLocation:@"PNStateListener" andMessageFactory:^PNLogEntry *{
        return [PNDictionaryLogEntry entryWithMessage:[signal.data dictionaryRepresentation]
                                              details:@"Received signal:"
                                            operation:PNSubscribeLogMessageOperation];
    }];

    pn_dispatch_async(self.client.callbackQueue, ^{
        for (id <PNEventsListener> listener in listeners) {
            [listener client:self.client didReceiveSignal:signal];
        }
    });
}

- (void)notifyMessageAction:(PNMessageActionResult *)action {
    NSArray<id <PNEventsListener>> *listeners = self.messageActionListeners.allObjects;
    
    [self.client.logger debugWithLocation:@"PNStateListener" andMessageFactory:^PNLogEntry *{
        return [PNDictionaryLogEntry entryWithMessage:[action.data dictionaryRepresentation]
                                              details:@"Received message action event:"
                                            operation:PNSubscribeLogMessageOperation];
    }];

    pn_dispatch_async(self.client.callbackQueue, ^{
        for (id <PNEventsListener> listener in listeners) {
            [listener client:self.client didReceiveMessageAction:action];
        }
    });
}

- (void)notifyPresenceEvent:(PNPresenceEventResult *)event {
    NSArray<id <PNEventsListener>> *listeners = self.presenceEventListeners.allObjects;
    
    [self.client.logger debugWithLocation:@"PNStateListener" andMessageFactory:^PNLogEntry *{
        return [PNDictionaryLogEntry entryWithMessage:[event.data dictionaryRepresentation]
                                              details:@"Received presence event:"
                                            operation:PNSubscribeLogMessageOperation];
    }];

    pn_dispatch_async(self.client.callbackQueue, ^{
        for (id <PNEventsListener> listener in listeners) {
            [listener client:self.client didReceivePresenceEvent:event];
        }
    });
}

- (void)notifyObjectEvent:(PNObjectEventResult *)event {
    NSArray<id <PNEventsListener>> *listeners = self.objectEventListeners.allObjects;
    
    [self.client.logger debugWithLocation:@"PNStateListener" andMessageFactory:^PNLogEntry *{
        return [PNDictionaryLogEntry entryWithMessage:[event.data dictionaryRepresentation]
                                              details:@"Received app context event:"
                                            operation:PNSubscribeLogMessageOperation];
    }];

    pn_dispatch_async(self.client.callbackQueue, ^{
        for (id <PNEventsListener> listener in listeners) {
            [listener client:self.client didReceiveObjectEvent:event];
        }
    });
}

- (void)notifyFileEvent:(PNFileEventResult *)event {
    NSArray<id <PNEventsListener>> *listeners = self.fileEventListeners.allObjects;
    
    [self.client.logger debugWithLocation:@"PNStateListener" andMessageFactory:^PNLogEntry *{
        return [PNDictionaryLogEntry entryWithMessage:[event.data dictionaryRepresentation]
                                              details:@"Received file share event:"
                                            operation:PNSubscribeLogMessageOperation];
    }];

    pn_dispatch_async(self.client.callbackQueue, ^{
        for (id <PNEventsListener> listener in listeners) {
            [listener client:self.client didReceiveFileEvent:event];
        }
    });
}

- (void)notifyStatusChange:(PNSubscribeStatus *)status {
    [self notifyStatusObservers:status];
}

- (void)notifyHeartbeatStatus:(PNStatus *)status {
    [self notifyStatusObservers:status];
}


#pragma mark - Notification

- (void)notifyStatusObservers:(PNStatus *)status {
    NSArray<id <PNEventsListener>> *listeners = self.stateListeners.allObjects;

    pn_dispatch_async(self.client.callbackQueue, ^{
        for (id <PNEventsListener> listener in listeners) {
            [listener client:self.client didReceiveStatus:status];
        }
    });
}


#pragma mark - Misc

- (NSHashTable *)listenersCopyFrom:(NSHashTable *)listeners {
    __block NSHashTable *listenersCopy = nil;
    
    dispatch_sync(self.resourceAccessQueue, ^{
        listenersCopy = [listeners copy];
    });
    
    return listenersCopy;
}

#pragma mark -


@end
