/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNStateListener.h"
#import "PNObjectEventListener.h"
#import "PubNub+CorePrivate.h"


#pragma mark Protected interface declaration

@interface PNStateListener ()


#pragma mark - Information 

/**
 @brief  Weak reference on client for which state listeners manager created.
 
 @since 4.0
 */
@property (nonatomic, weak) PubNub *client;

/**
 @brief  Stores list of listeners which would like to be notified when new message arrive from
         remote data feed objects on which client subscrubed at this moment.
 
 @return Hash table with list of new message listeners.
 
 @since 4.0
 */
@property (nonatomic, strong) NSHashTable *messageListeners;

/**
 @brief  Stores list of listeners which would like to be notified when new presence event arrive 
         from remote data feed objects on which client subscrubed at this moment.
 
 @return Hash table with list of presence event listeners.
 
 @since 4.0
 */
@property (nonatomic, strong) NSHashTable *presenceEventListeners;


/**
 @brief  Stores list of listeners which would like to be notified when on subscription state 
         changes (connection, access rights error, disconnection and unexpected disconnection).
 
 @since 4.0
 */
@property (nonatomic, strong) NSHashTable *stateListeners;

/**
 @brief  Stores reference on queue which is used to serialize access to shared listener
         information.
 
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
- (instancetype)initForClient:(PubNub *)client NS_DESIGNATED_INITIALIZER;

#pragma mark -

@end


#pragma mark - Interface implementation

@implementation PNStateListener


#pragma mark - Initialization and Configuration

+ (instancetype)stateListenerForClient:(PubNub *)client {
    
    return [[self alloc] initForClient:client];
}

- (instancetype)initForClient:(PubNub *)client {
    
    // Check whether initializtion was successful or not.
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

- (void)addListeners:(NSArray *)listeners {
    
    dispatch_async(self.resourceAccessQueue, ^{
        
        for (id listener in listeners) {
            
            // Ensure what provided listener conforms to required protocol.
            if ([listener conformsToProtocol:@protocol(PNObjectEventListener)]) {
                
                if ([listener respondsToSelector:@selector(client:didReceiveMessage:withStatus:)]) {
                    
                    [self.messageListeners addObject:listener];
                }
                if ([listener respondsToSelector:@selector(client:didReceivePresenceEvent:)]) {
                    
                    [self.presenceEventListeners addObject:listener];
                }
                
                if ([listener respondsToSelector:@selector(client:didReceiveStatus:)]) {
                    
                    [self.stateListeners addObject:listener];
                }
            }
            else {
                
                DDLogWarn(@"<PubNub> %@ can't be used as object event listener because it "
                          "doesn't conform to PNObjectEventListener protocol", listener);
            }
        }
    });
}

- (void)removeListeners:(NSArray *)listeners {
    
    dispatch_async(self.resourceAccessQueue, ^{
        
        for (id listener in listeners) {
            
            [self.messageListeners removeObject:listener];
            [self.presenceEventListeners removeObject:listener];
            [self.stateListeners removeObject:listener];
        }
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

- (void)notifyMessage:(PNResult<PNMessageResult> *)message withStatus:(PNStatus<PNStatus> *)status {
    
    NSArray *listeners = [self.messageListeners allObjects];
    // Silence static analyzer warnings.
    // Code is aware about this case and at the end will simply call on 'nil' object method.
    // This instance is one of client properties and if client already deallocated there is
    // no need to this object which will be deallocated as well.
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wreceiver-is-weak"
    #pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
    dispatch_async(self.client.callbackQueue, ^{
        
        for (id <PNObjectEventListener> listener in listeners) {
            
            [listener client:self.client didReceiveMessage:message withStatus:status];
        }
    });
    #pragma clang diagnostic pop
}

- (void)notifyPresenceEvent:(PNResult<PNPresenceEventResult> *)event {
    
    NSArray *listeners = [self.presenceEventListeners allObjects];
    // Silence static analyzer warnings.
    // Code is aware about this case and at the end will simply call on 'nil' object method.
    // This instance is one of client properties and if client already deallocated there is
    // no need to this object which will be deallocated as well.
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wreceiver-is-weak"
    #pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
    dispatch_async(self.client.callbackQueue, ^{
        
        for (id <PNObjectEventListener> listener in listeners) {
            
            [listener client:self.client didReceivePresenceEvent:event];
        }
    });
    #pragma clang diagnostic pop
}

- (void)notifyStatusChange:(PNStatus<PNSubscriberStatus> *)status {
    
    NSArray *listeners = [self.stateListeners allObjects];
    // Silence static analyzer warnings.
    // Code is aware about this case and at the end will simply call on 'nil' object method.
    // This instance is one of client properties and if client already deallocated there is
    // no need to this object which will be deallocated as well.
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wreceiver-is-weak"
    #pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
    dispatch_async(self.client.callbackQueue, ^{
        
        for (id <PNObjectEventListener> listener in listeners) {
            
            [listener client:self.client didReceiveStatus:status];
        }
    });
    #pragma clang diagnostic pop
}

#pragma mark -


@end
