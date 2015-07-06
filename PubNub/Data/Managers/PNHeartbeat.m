/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNHeartbeat.h"
#import "PubNub+PresencePrivate.h"
#import "PubNub+CorePrivate.h"
#import "PNConfiguration.h"
#import "PNHelpers.h"


#pragma mark Protected interface declaration

@interface PNHeartbeat ()


#pragma mark - Information

/**
 @brief  Stores weak reference on client for which heartbeat manager has been created.
 
 @since 4.0
 */
@property (nonatomic, weak) PubNub *client;

/**
 @brief  Stores reference on timer used to trigger heartbeat requests.
 
 @since 4.0
 */
@property (nonatomic, strong) dispatch_source_t heartbeatTimer;

/**
 @brief  Stores reference on queue which is used to serialize access to shared heartbeat 
         information.
 
 @since 4.0
 */
@property (nonatomic, strong) dispatch_queue_t resourceAccessQueue;


#pragma mark - Initialization and Configuration

/**
 @brief  Initialize and configure heartbeat manager.
 
 @param client Reference on \b PubNub client for which heartbeat manager has been created.
 
 @return Initialized and ready to use heartbeat manager.
 
 @since 4.0
 */
- (instancetype)initForClient:(PubNub *)client NS_DESIGNATED_INITIALIZER;


#pragma mark - Handlers

/**
 @brief  Process heartbeat timer fire event and send heartbeat request to \b PubNub service.

 @since 4.0
 */
- (void)handleHeartbeatTimer;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNHeartbeat

@synthesize heartbeatTimer = _heartbeatTimer;


#pragma mark - Initialization and Configuration

+ (instancetype)heartbeatForClient:(PubNub *)client {
    
    return [[self alloc] initForClient:client];
}

- (instancetype)initForClient:(PubNub *)client {
    
    // Check whether initialization was successful or not.
    if ((self = [super init])) {
        
        _client = client;
        _resourceAccessQueue = dispatch_queue_create("com.pubnub.heartbeat",
                                                     DISPATCH_QUEUE_CONCURRENT);
    }
    
    return self;
}

- (dispatch_source_t)heartbeatTimer {
    
    __block dispatch_source_t timer = nil;
    dispatch_sync(self.resourceAccessQueue, ^{
        
        timer = self->_heartbeatTimer;
    });
    
    return timer;
}

- (void)setHeartbeatTimer:(dispatch_source_t)heartbeatTimer {
    
    dispatch_barrier_async(self.resourceAccessQueue, ^{
        
        self->_heartbeatTimer = heartbeatTimer;
    });
}


#pragma mark - State manipulation

- (void)startHeartbeatIfRequired {

    // Stop previous heartbeat timer if it has been launched.
    [self stopHeartbeatIfPossible];
    
    // Silence static analyzer warnings.
    // Code is aware about this case and at the end will simply call on 'nil' object method.
    // In most cases if referenced object become 'nil' it mean what there is no more need in
    // it and probably whole client instance has been deallocated.
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wreceiver-is-weak"
    #pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
    if (self.client.configuration.presenceHeartbeatInterval > 0) {
        
        __weak __typeof(self) weakSelf = self;
        dispatch_queue_t timerQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, timerQueue);
        dispatch_source_set_event_handler(timer, ^{

            [weakSelf handleHeartbeatTimer];
        });
        uint64_t offset = (uint64_t)self.client.configuration.presenceHeartbeatInterval * NSEC_PER_SEC;
        dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)offset);
        dispatch_source_set_timer(timer, start, offset, NSEC_PER_SEC);
        self.heartbeatTimer = timer;
        dispatch_resume(timer);
    }
    #pragma clang diagnostic pop
}

- (void)stopHeartbeatIfPossible {

    dispatch_source_t timer = self.heartbeatTimer;
    if (timer != NULL && dispatch_source_testcancel(timer) == 0) {
        
        dispatch_source_cancel(timer);
    }
    self.heartbeatTimer = nil;
}


#pragma mark - Handlers

- (void)handleHeartbeatTimer {
    
    // Silence static analyzer warnings.
    // Code is aware about this case and at the end will simply call on 'nil' object method.
    // In most cases if referenced object become 'nil' it mean what there is no more need in
    // it and probably whole client instance has been deallocated.
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wreceiver-is-weak"
    #pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
    if ([[PNChannel objectsWithOutPresenceFrom:[self.client.subscriberManager allObjects]] count]) {
        
        [self.client heartbeatWithCompletion:NULL];
    }
    else {
        
        [self stopHeartbeatIfPossible];
    }
    #pragma clang diagnostic pop
}

#pragma mark -


@end
