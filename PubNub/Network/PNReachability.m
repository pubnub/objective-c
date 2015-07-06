/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNReachability.h"
#import <AFNetworkReachabilityManager.h>
#import "PubNub+CorePrivate.h"
#import "PNConfiguration.h"
#import "PubNub.h"


#pragma mark CocoaLumberjack logging support

/**
 @brief  Cocoa Lumberjack logging level configuration for network manager.
 
 @since 4.0
 */
static DDLogLevel ddLogLevel = (DDLogLevel)PNReachabilityLogLevel;


#pragma mark - Protected interface declaration

@interface PNReachability ()


#pragma mark - Information

/**
 @brief  Reference on client which created this reachability helper instance and will be used to
         call \b time API for \c ping requests.
 
 @since 4.0
 */
@property (nonatomic, weak) PubNub *client;

/**
 @brief  Stores reference on queue which is used to serialize access to shared reachability helper
         resources.
 
 @since 4.0
 */
@property (nonatomic, strong) dispatch_queue_t resourceAccessQueue;

/**
 @brief  Stores whether remote service ping active at this moment or not.
 
 @since 4.0
 */
@property (nonatomic, assign, getter = pingingRemoteService) BOOL pingRemoteService;

/**
 @brief  Stores reference on copy of block which should be called every time when \b ping API
         receives response from \b PubNub network or network sub-system.
 
 @since 4.0
 */
@property (nonatomic, copy) void(^pingCompleteBlock)(BOOL pingSuccessful);

/**
 @brief  Stores reference on reachability monitor used to track state of network connection.
 
 @since 4.0
 */
@property (nonatomic, strong) AFNetworkReachabilityManager *reachabilityManager;
@property (nonatomic, assign) AFNetworkReachabilityStatus reachabilityStatus;


#pragma mark - Initialization and Configuration

/**
 @brief  Initialize reachability helper which will allow to identify current \b PubNub network state.
 
 @param client Reference on \b PubNub client for which this helper has been created.
 @param block  Reference on block which is called by helper to inform about current ping round
               results.
 
 @return Initialized and ready to use reachability helper instance.
 
 @since 4.0
 */
- (instancetype)initForClient:(PubNub *)client
               withPingStatus:(void(^)(BOOL pingSuccessful))block NS_DESIGNATED_INITIALIZER;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNReachability

@synthesize pingRemoteService = _pingRemoteService;


#pragma mark - Logger

/**
 @brief  Called by Cocoa Lumberjack during initialization.
 
 @return Desired logger level for \b PubNub client main class.
 
 @since 4.0
 */
+ (DDLogLevel)ddLogLevel {
    
    return ddLogLevel;
}

/**
 @brief  Allow modify logger level used by Cocoa Lumberjack with logging macros.
 
 @param logLevel New log level which should be used by logger.
 
 @since 4.0
 */
+ (void)ddSetLogLevel:(DDLogLevel)logLevel {
    
    ddLogLevel = logLevel;
}


#pragma mark - Initialization and Configuration

+ (instancetype)reachabilityForClient:(PubNub *)client withPingStatus:(void (^)(BOOL))block {
    
    return [[self alloc] initForClient:client withPingStatus:block];
}

- (instancetype)initForClient:(PubNub *)client withPingStatus:(void(^)(BOOL pingSuccessful))block {
    
    // Check whether initialization was successful or not.
    if ((self = [super init])) {
        
        __weak __typeof(self) weakSelf = self;
        _client = client;
        _pingCompleteBlock = [block copy];
        _resourceAccessQueue = dispatch_queue_create("com.pubnub.reachability",
                                                     DISPATCH_QUEUE_CONCURRENT);
        _reachabilityStatus = AFNetworkReachabilityStatusUnknown;
        _reachabilityManager = [AFNetworkReachabilityManager managerForDomain:client.configuration.origin];
        [_reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            
            // Silence static analyzer warnings.
            // Code is aware about this case and at the end will simply call on 'nil' object method.
            // In most cases if referenced object become 'nil' it mean what there is no more need in
            // it and probably whole client instance has been deallocated.
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Wreceiver-is-weak"
            #pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
            AFNetworkReachabilityStatus previousStatus = weakSelf.reachabilityStatus;
            if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
                
                DDLogReachability([[weakSelf class] ddLogLevel], @"<PubNub> Network available via WiFi");
            } else if (status == AFNetworkReachabilityStatusReachableViaWWAN) {
                
                DDLogReachability([[weakSelf class] ddLogLevel], @"<PubNub> Network available via WWAN");
            } else if (status == AFNetworkReachabilityStatusNotReachable &&
                       weakSelf.reachabilityStatus != status) {
                
                DDLogReachability([[weakSelf class] ddLogLevel], @"<PubNub> Network not available");
            }
            
            weakSelf.reachabilityStatus = status;
            if (previousStatus == AFNetworkReachabilityStatusNotReachable &&
                status != AFNetworkReachabilityStatusNotReachable &&
                status != AFNetworkReachabilityStatusUnknown) {
                
                DDLogReachability([[weakSelf class] ddLogLevel], @"<PubNub> Connection restored.");
            }
            else if (status == AFNetworkReachabilityStatusNotReachable &&
                     previousStatus != AFNetworkReachabilityStatusNotReachable &&
                     previousStatus != AFNetworkReachabilityStatusUnknown) {
                
                DDLogReachability([[weakSelf class] ddLogLevel], @"<PubNub> Connection went down.");
            }
                
            // Launch service ping process.
            [weakSelf startServicePing];
            #pragma clang diagnostic pop
        }];
        
        DDLogReachability([[self class] ddLogLevel], @"<PubNub> Start reachability monitor for: %@",
                          client.configuration.origin);
        [_reachabilityManager startMonitoring];
    }
    
    return self;
}

- (BOOL)pingingRemoteService {
    
    __block BOOL pingingRemoteService = NO;
    dispatch_sync(self.resourceAccessQueue, ^{
        
        pingingRemoteService = self->_pingRemoteService;
    });
    
    return pingingRemoteService;
}

- (void)setPingRemoteService:(BOOL)pingRemoteService {
    
    dispatch_barrier_async(self.resourceAccessQueue, ^{
        
        self->_pingRemoteService = pingRemoteService;
    });
}


#pragma mark - Service ping

- (void)startServicePing {
    
    if (!self.pingingRemoteService) {
        
        self.pingRemoteService = YES;
        
        // Silence static analyzer warnings.
        // Code is aware about this case and at the end will simply call on 'nil' object method.
        // In most cases if referenced object become 'nil' it mean what there is no more need in
        // it and probably whole client instance has been deallocated.
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wreceiver-is-weak"
        #pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
        // Try to request 'time' API to ensure what network really available.
        [self.client timeWithCompletion:^(PNTimeResult *result, __unused PNErrorStatus *status) {
            
            self.pingCompleteBlock(result.data != nil);
            if (self.pingingRemoteService) {
                
                NSTimeInterval delay = (self.reachabilityStatus == AFNetworkReachabilityStatusNotReachable ||
                                        self.reachabilityStatus == AFNetworkReachabilityStatusUnknown ?
                                        10.f : 1.0f);
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)),
                               dispatch_get_main_queue(), ^{
                                   
                                   self.pingRemoteService = NO;
                                   [self startServicePing];
                               });
            }
        }];
        #pragma clang diagnostic pop
    }
}

- (void)stopServicePing {
    
    self.pingRemoteService = NO;
}

#pragma mark -

@end
