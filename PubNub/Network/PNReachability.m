/**
 * @author Serhii Mamontov
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNReachability.h"
#import "PubNub+CorePrivate.h"
#import "PNConfiguration.h"
#import "PNLogMacro.h"
#import "PubNub.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Protected interface declaration

@interface PNReachability ()


#pragma mark - Information

/**
 * @brief Client which created this reachability helper instance and will be used to call \b time
 * API for \c ping requests.
 */
@property (nonatomic, weak) PubNub *client;

/**
 * @brief Queue which is used to serialize access to shared reachability helper resources.
 */
@property (nonatomic, strong) dispatch_queue_t resourceAccessQueue;

/**
 * @brief Whether remote service ping active at this moment or not.
 */
@property (nonatomic, assign, getter = pingingRemoteService) BOOL pingRemoteService;

/**
 * @brief Copy of block which should be called every time when \b ping API receives response from
 * \b PubNub network or network sub-system.
 */
@property (nonatomic, copy) void(^pingCompleteBlock)(BOOL pingSuccessful);

/**
 * @brief Reachability monitor used to track state of network connection.
 */
@property (nonatomic, assign) BOOL reachable;


#pragma mark - Initialization and Configuration

/**
 * @brief Initialize reachability helper which will allow to identify current \b PubNub network
 * state.
 *
 * @param client \b PubNub client for which this helper has been created.
 * @param block Block which is called by helper to inform about current ping round results.
 *
 * @return Initialized and ready to use reachability helper instance.
 */
- (instancetype)initForClient:(PubNub *)client withPingStatus:(void(^)(BOOL pingSuccessful))block;


#pragma mark - Handlers

/**
 * @brief Process service response.
 *
 * @note In case if there is no response object or it's content malformed reachability will be set
 * to 'not available'.
 *
 * @param result Time API calling result object.
 */
- (void)handleServicePingResult:(PNTimeResult *)result;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNReachability

@synthesize pingRemoteService = _pingRemoteService;


#pragma mark - Initialization and Configuration

+ (instancetype)reachabilityForClient:(PubNub *)client withPingStatus:(void (^)(BOOL))block {
    
    return [[self alloc] initForClient:client withPingStatus:block];
}

- (instancetype)initForClient:(PubNub *)client withPingStatus:(void(^)(BOOL pingSuccessful))block {
    
    // Check whether initialization was successful or not.
    if ((self = [super init])) {
        _client = client;
        [_client.logger enableLogLevel:PNReachabilityLogLevel];
        _pingCompleteBlock = [block copy];
        _resourceAccessQueue = dispatch_queue_create("com.pubnub.reachability",
                                                     DISPATCH_QUEUE_CONCURRENT);
        _reachable = YES;
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
        // Try to request 'time' API to ensure what network really available.
        __weak __typeof(self) weakSelf = self;
        
        [self.client timeWithCompletion:^(PNTimeResult *result, __unused PNErrorStatus *status) {
            [weakSelf handleServicePingResult:result];
        }];
    }
}

- (void)stopServicePing {
    
    self.pingRemoteService = NO;
}


#pragma mark - Handlers

- (void)handleServicePingResult:(PNTimeResult *)result {
    
    BOOL successfulPing = result.data != nil;
    
    if (self.reachable && !successfulPing) {
        PNLogReachability(self.client.logger, @"<PubNub::Reachability> Connection went down.");
    }
    
    if (!self.reachable && successfulPing) {
        PNLogReachability(self.client.logger, @"<PubNub::Reachability> Connection restored.");
    }
    
    if (self.pingCompleteBlock) {
        self.pingCompleteBlock(successfulPing);
    }
    
    if (self.pingingRemoteService) {
        NSTimeInterval delay = ((self.reachable && !successfulPing) ? 1.f : 10.0f);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{

           self.pingRemoteService = NO;
           [self startServicePing];
       });
    }
    self.reachable = successfulPing;
}

#pragma mark -


@end
