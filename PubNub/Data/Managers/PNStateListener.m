/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
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
 @brief  Weak reference on client for which state listeners manager created.
 
 @since 4.0
 */
@property (nonatomic, weak) PubNub *client;

/**
 @brief  Stores list of listeners which would like to be notified when new message arrive from remote data 
         feed objects on which client subscribed at this moment.
 
 @return Hash table with list of new message listeners.
 
 @since 4.0
 */
@property (nonatomic, strong) NSHashTable<id <PNObjectEventListener>> *messageListeners;

/**
 @brief  Stores list of listeners which would like to be notified when new presence event arrive from remote 
         data feed objects on which client subscribed at this moment.
 
 @return Hash table with list of presence event listeners.
 
 @since 4.0
 */
@property (nonatomic, strong) NSHashTable<id <PNObjectEventListener>> *presenceEventListeners;


/**
 @brief  Stores list of listeners which would like to be notified when on subscription state changes 
         (connection, access rights error, disconnection and unexpected disconnection).
 
 @since 4.0
 */
@property (nonatomic, strong) NSHashTable<id <PNObjectEventListener>> *stateListeners;

/**
 @brief  Stores reference on queue which is used to serialize access to shared listener information.
 
 @since 4.0
 */
@property (nonatomic, strong) dispatch_queue_t resourceAccessQueue;


#pragma mark - Initialization and Configuration

/**
 @brief  Initialize state listener manager for concrete \b PubNub client instance.
 
 @param client Reference on client for which manager should operate and use data.
 
 @return Initialized and ready to use state listener manager.
 
 @since 4.0
 */
- (instancetype)initForClient:(PubNub *)client;


#pragma mark - Notification

/**
 @brief  Notify all status event change subscriber about new event.
 
 @param status Reference on state object which describe operation and category.
 */
- (void)notifyStatusObservers:(PNStatus *)status;

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
    
    // Check whether initialization was successful or not.
    if ((self = [super init])) {
        
        _client = client;
        _messageListeners = [NSHashTable weakObjectsHashTable];
        _presenceEventListeners = [NSHashTable weakObjectsHashTable];
        _stateListeners = [NSHashTable weakObjectsHashTable];
        _resourceAccessQueue = dispatch_queue_create("com.pubnub.listener", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

- (void)inheritStateFromListener:(PNStateListener *)listener {
    
    _messageListeners = [listener.messageListeners mutableCopy];
    _presenceEventListeners = [listener.presenceEventListeners mutableCopy];
    _stateListeners = [listener.stateListeners mutableCopy];
}


#pragma mark - Listeners list modification

- (void)addListener:(id <PNObjectEventListener>)listener {
    
    dispatch_async(self.resourceAccessQueue, ^{
        
        if ([listener respondsToSelector:@selector(client:didReceiveMessage:)]) {
            
            [self.messageListeners addObject:listener];
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
        [self.presenceEventListeners removeObject:listener];
        [self.stateListeners removeObject:listener];
    });
}

- (void)removeAllListeners {
    
    dispatch_async(self.resourceAccessQueue, ^{
            
        [self.messageListeners removeAllObjects];
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
    // Silence static analyzer warnings.
    // Code is aware about this case and at the end will simply call on 'nil' object method.
    // In most cases if referenced object become 'nil' it mean what there is no more need in
    // it and probably whole client instance has been deallocated.
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wreceiver-is-weak"
    #pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
    pn_dispatch_async(self.client.callbackQueue, ^{
        
        for (id <PNObjectEventListener> listener in listeners) {
            
            [listener client:self.client didReceiveMessage:message];
        }
    });
    #pragma clang diagnostic pop
}

- (void)notifyPresenceEvent:(PNPresenceEventResult *)event {
    
    NSArray<id <PNObjectEventListener>> *listeners = self.presenceEventListeners.allObjects;
    // Silence static analyzer warnings.
    // Code is aware about this case and at the end will simply call on 'nil' object method.
    // In most cases if referenced object become 'nil' it mean what there is no more need in
    // it and probably whole client instance has been deallocated.
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wreceiver-is-weak"
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
    // Silence static analyzer warnings.
    // Code is aware about this case and at the end will simply call on 'nil' object method.
    // In most cases if referenced object become 'nil' it mean what there is no more need in
    // it and probably whole client instance has been deallocated.
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wreceiver-is-weak"
    #pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
    pn_dispatch_async(self.client.callbackQueue, ^{
        
        for (id <PNObjectEventListener> listener in listeners) {
            
            [listener client:self.client didReceiveStatus:status];
        }
    });
    #pragma clang diagnostic pop
}

#pragma mark -


@end
