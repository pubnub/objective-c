/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2010-2018 PubNub, Inc.
 */
#import "PNStateListener.h"
#import "PNObjectEventListener.h"
#import "PubNub+CorePrivate.h"
#import "PNSubscribeStatus.h"
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
 * @brief Stores list of listeners which would like to be notified when new message arrive from
 * remote data feed objects on which client subscribed at this moment.
 *
 * @return Hash table with list of new message listeners.
 */
@property (nonatomic, strong) NSHashTable<id <PNObjectEventListener>> *messageListeners;

/**
 * @brief Stores list of listeners which would like to be notified when new signal arrive from
 * remote data feed objects on which client subscribed at this moment.
 *
 * @return Hash table with list of new message listeners.
 */
@property (nonatomic, strong) NSHashTable<id <PNObjectEventListener>> *signalListeners;

/**
 * @brief Stores list of listeners which would like to be notified when new presence event arrive
 * from remote data feed objects on which client subscribed at this moment.
 *
 * @return Hash table with list of presence event listeners.
 */
@property (nonatomic, strong) NSHashTable<id <PNObjectEventListener>> *presenceEventListeners;


/**
 * @brief Stores list of listeners which would like to be notified when on subscription state
 * changes (connection, access rights error, disconnection and unexpected disconnection).
 */
@property (nonatomic, strong) NSHashTable<id <PNObjectEventListener>> *stateListeners;

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
        _presenceEventListeners = [NSHashTable weakObjectsHashTable];
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
    NSHashTable *presenceEventListeners = [listener listenersCopyFrom:listener.presenceEventListeners];
    NSHashTable *stateListeners = [listener listenersCopyFrom:listener.stateListeners];
    
    dispatch_async(self.resourceAccessQueue, ^{
        self.messageListeners = messageListeners;
        self.signalListeners = signalListeners;
        self.presenceEventListeners = presenceEventListeners;
        self.stateListeners = stateListeners;
    });
}


#pragma mark - Listeners list modification

- (void)addListener:(id <PNObjectEventListener>)listener {
    dispatch_async(self.resourceAccessQueue, ^{
        if ([listener respondsToSelector:@selector(client:didReceiveMessage:)]) {
            [self.messageListeners addObject:listener];
        }
        
        if ([listener respondsToSelector:@selector(client:didReceiveSignal:)]) {
            [self.signalListeners addObject:listener];
        }
        
        if ([listener respondsToSelector:@selector(client:didReceivePresenceEvent:)]) {
            [self.presenceEventListeners addObject:listener];
        }
        
        if ([listener respondsToSelector:@selector(client:didReceiveStatus:)]) {
            [self.stateListeners addObject:listener];
        }
    });
}

- (void)removeListener:(id <PNObjectEventListener>)listener {
    dispatch_async(self.resourceAccessQueue, ^{
        [self.messageListeners removeObject:listener];
        [self.signalListeners removeObject:listener];
        [self.presenceEventListeners removeObject:listener];
        [self.stateListeners removeObject:listener];
    });
}

- (void)removeAllListeners {
    dispatch_async(self.resourceAccessQueue, ^{
        [self.messageListeners removeAllObjects];
        [self.signalListeners removeAllObjects];
        [self.presenceEventListeners removeAllObjects];
        [self.stateListeners removeAllObjects];
    });
}


#pragma mark - Listeners notification

- (void)notifyWithBlock:(dispatch_block_t)block {
    dispatch_async(self.resourceAccessQueue, block);
}

- (void)notifyMessage:(PNMessageResult *)message {
    NSArray<id <PNObjectEventListener>> *listeners = self.messageListeners.allObjects;
    
    /**
     * Silence static analyzer warnings.
     * Code is aware about this case and at the end will simply call on 'nil' object method.
     * In most cases if referenced object become 'nil' it mean what there is no more need in
     * it and probably whole client instance has been deallocated.
     */
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
    pn_dispatch_async(self.client.callbackQueue, ^{
        for (id <PNObjectEventListener> listener in listeners) {
            [listener client:self.client didReceiveMessage:message];
        }
    });
    #pragma clang diagnostic pop
}

- (void)notifySignal:(PNSignalResult *)signal {
    NSArray<id <PNObjectEventListener>> *listeners = self.signalListeners.allObjects;
    
    /**
     * Silence static analyzer warnings.
     * Code is aware about this case and at the end will simply call on 'nil' object method.
     * In most cases if referenced object become 'nil' it mean what there is no more need in
     * it and probably whole client instance has been deallocated.
     */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
    pn_dispatch_async(self.client.callbackQueue, ^{
        for (id <PNObjectEventListener> listener in listeners) {
            [listener client:self.client didReceiveSignal:signal];
        }
    });
#pragma clang diagnostic pop
}

- (void)notifyPresenceEvent:(PNPresenceEventResult *)event {
    NSArray<id <PNObjectEventListener>> *listeners = self.presenceEventListeners.allObjects;
    
    /**
     * Silence static analyzer warnings.
     * Code is aware about this case and at the end will simply call on 'nil' object method.
     * In most cases if referenced object become 'nil' it mean what there is no more need in
     * it and probably whole client instance has been deallocated.
     */
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
    pn_dispatch_async(self.client.callbackQueue, ^{
        for (id <PNObjectEventListener> listener in listeners) {
            [listener client:self.client didReceivePresenceEvent:event];
        }
    });
    #pragma clang diagnostic pop
}

- (void)notifyStatusChange:(PNSubscribeStatus *)status {
    [self notifyStatusObservers:status];
}

- (void)notifyHeartbeatStatus:(PNStatus *)status {
    [self notifyStatusObservers:status];
}


#pragma mark - Notification

- (void)notifyStatusObservers:(PNStatus *)status {
    NSArray<id <PNObjectEventListener>> *listeners = self.stateListeners.allObjects;
    
    /**
     * Silence static analyzer warnings.
     * Code is aware about this case and at the end will simply call on 'nil' object method.
     * In most cases if referenced object become 'nil' it mean what there is no more need in
     * it and probably whole client instance has been deallocated.
     */
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
    pn_dispatch_async(self.client.callbackQueue, ^{
        for (id <PNObjectEventListener> listener in listeners) {
            [listener client:self.client didReceiveStatus:status];
        }
    });
    #pragma clang diagnostic pop
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
