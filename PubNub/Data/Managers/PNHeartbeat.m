/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
#import "PNHeartbeat.h"
#import "PubNub+PresencePrivate.h"
#import "PubNub+CorePrivate.h"
#import "PNConfiguration.h"
#import "PNStructures.h"
#import "PNHelpers.h"
#import "PNStatus.h"


NS_ASSUME_NONNULL_BEGIN

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
@property (nonatomic, nullable, strong) dispatch_source_t heartbeatTimer;

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
- (instancetype)initForClient:(PubNub *)client;


#pragma mark - Handlers

/**
 @brief  Process heartbeat timer fire event and send heartbeat request to \b PubNub service.

 @since 4.0
 */
- (void)handleHeartbeatTimer;


#pragma mark - Misc

/**
 @brief  Check whether current configuration require inform about heartbeat request processing \c status or 
         not.
 
 @return \c YES in case if delegate should be notified.
 */
- (BOOL)shouldNotifyAboutHeartbeatWithStatus:(PNStatus *)status;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


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
        _resourceAccessQueue = dispatch_queue_create("com.pubnub.heartbeat", DISPATCH_QUEUE_CONCURRENT);
    }
    
    return self;
}

- (dispatch_source_t)heartbeatTimer {
    
    __block dispatch_source_t timer = nil;
    pn_safe_property_read(self.resourceAccessQueue, ^{ timer = self->_heartbeatTimer; });
    
    return timer;
}

- (void)setHeartbeatTimer:(dispatch_source_t)heartbeatTimer {
    
    pn_safe_property_write(self.resourceAccessQueue, ^{ self->_heartbeatTimer = heartbeatTimer; });
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
        dispatch_source_set_event_handler(timer, ^{ [weakSelf handleHeartbeatTimer]; });
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
    if (timer != NULL && dispatch_source_testcancel(timer) == 0) { dispatch_source_cancel(timer); }
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
    if ([PNChannel objectsWithOutPresenceFrom:[self.client.subscriberManager allObjects]].count) {
        
        __weak __typeof(self) weakSelf = self;
        [self.client heartbeatWithCompletion:^(PNStatus *status) {
            
            if ([weakSelf shouldNotifyAboutHeartbeatWithStatus:status]) {
                
                [weakSelf.client.listenersManager notifyHeartbeatStatus:status];
            }
        }];
    }
    else { [self stopHeartbeatIfPossible]; }
    #pragma clang diagnostic pop
}


#pragma mark - Misc

- (BOOL)shouldNotifyAboutHeartbeatWithStatus:(PNStatus *)status {
    
    PNHeartbeatNotificationOptions heartbeatOptions = self.client.configuration.heartbeatNotificationOptions;
    BOOL shouldNotify = !((heartbeatOptions & PNHeartbeatNotifyNone) == PNHeartbeatNotifyNone);
    if (shouldNotify) {
        
        if (!((heartbeatOptions & PNHeartbeatNotifyAll) == PNHeartbeatNotifyAll)) {
            
            if (status.isError) { 
                
                shouldNotify = ((heartbeatOptions & PNHeartbeatNotifyFailure) == PNHeartbeatNotifyFailure);
            }
            else { 
                
                shouldNotify = ((heartbeatOptions & PNHeartbeatNotifySuccess) == PNHeartbeatNotifySuccess);
            }
        }
    }
    
    return shouldNotify;
}

#pragma mark -


@end
