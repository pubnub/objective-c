/**
 @author Sergey Mamontov
 @since 4.6.1
 @copyright © 2009-2017 PubNub, Inc.
 */
#import "PNTelemetry.h"
#import "PNPrivateStructures.h"
#import "PNLockSupport.h"
#import "PNNumber.h"


#pragma mark Static

/**
 @brief  Stores for how long each stored latency should live in persistent storage for particular API 
         endpoint.
 
 @since 4.6.2
 */
static NSTimeInterval const kPNOperationLatencyMaximumAge = 60.0f;

/**
 @brief  Stores reference on key under which request status is stored.
 
 @since 4.6.2
 */
static NSString * const kPNOperationDateKey = @"d";

/**
 @brief  Stores reference on key under which service advisory information stored.
 
 @since 4.6.2
 */
static NSString * const kPNOperationLatencyKey = @"l";


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Protected interface declaration

@interface PNTelemetry ()


#pragma mark - Information 

/**
 @brief  Stores reference on list of
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<NSDictionary *> *> *latencies;
/**
 @brief      Stores reference on map of active operations and their start date.
 @discussion Dictionary used by start/stop latency measure API to calculate operation latency from time which
             has been required to receive response (if metrics not available).
 
 @since 4.6.2
 */
@property (nonatomic, strong) NSMutableDictionary *trackedLatencies;

/**
 @brief      Stores reference on timer which is used to clean accumulated latencies information.
 @discussion SDK required to store latency information for last usage minute, so all outdated latencies 
             information should be removed from persistent storage.
 
 @since 4.6.2
 */
@property (nonatomic, strong, nullable) NSTimer *cleanUpTimer;

/**
 @brief  Spin/unfair-lock which is used to protect access to shared resources from multiple threads.
 
 @since 4.6.2
 */
@property (nonatomic, assign) os_unfair_lock resourceAccessLock;


#pragma mark - Operation information

/**
 @brief      Shortened name of API endpoint for specific operation.
 @discussion Some operations refer to single endpoint with only difference in passed parameters, but actual
             endpoint is the same. This method return shortened name of this endpoint.
 
 @param operationType One of \b PNOperationType enumerator fields which describe for which operation endpoint
                      should be retrieved.
 
 @return Shortened API endpoint name.
 
 @since 4.6.2
 */
- (NSString *)endpointNameForOperation:(PNOperationType)operationType;


#pragma mark - Handlers

/**
 @brief      Handler clean up timmer triggered.
 @discussion Use this handler to clean up outdated latencies information.
 
 @param timer Reference on timer which triggered callback.
 
 @since 4.6.2
 */
- (void)handleCleanUpTimer:(NSTimer *)timer;

#pragma mark -


@end

NS_ASSUME_NONNULL_END



@implementation PNTelemetry


#pragma mark - Initialization and configuration

- (instancetype)init {
    
    // Cjeck whether initialization has been successful or not.
    if ((self = [super init])) {
        
        self.resourceAccessLock = OS_UNFAIR_LOCK_INIT;
        self.latencies = [NSMutableDictionary new];
        self.trackedLatencies = [NSMutableDictionary new];
        self.cleanUpTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self
                                                           selector:@selector(handleCleanUpTimer:) 
                                                           userInfo:nil repeats:YES];
    }
    
    return self;
}


#pragma mark - Telemetry information

- (NSDictionary *)operationsLatencyForRequest {
    
    NSMutableDictionary *latenciesForRequest = [NSMutableDictionary new];
    pn_trylock(&_resourceAccessLock, ^{
        
        NSString *averageKeyPath = [@"@avg." stringByAppendingString:kPNOperationLatencyKey];
        [self.latencies enumerateKeysAndObjectsUsingBlock:^(NSString *latencyKey, 
                                                            NSMutableArray<NSDictionary *> *latencies, 
                                                            BOOL *latenciesEnumeratorStop) {
            
            NSString *averageLatencyKey = [@"l_" stringByAppendingString:latencyKey];
            latenciesForRequest[averageLatencyKey] = [latencies valueForKeyPath:averageKeyPath];
        }];
    });
    
    return [latenciesForRequest copy];
}



#pragma mark - Telemetry information tracking

- (void)startLatencyMeasureFor:(PNOperationType)operationType withIdentifier:(NSString *)identifier {
    
    // Check whether subscribe operation asked for latency measurment or not. 
    // There is no point to track long-poll operation latency.
    if (operationType != PNSubscribeOperation) {
        NSNumber *date = @([[NSDate date] timeIntervalSince1970]);
        pn_trylock(&_resourceAccessLock, ^{ self.trackedLatencies[identifier] = date; });
    }
}

- (void)stopLatencyMeasureFor:(PNOperationType)operationType withIdentifier:(NSString *)identifier {
    
    // Check whether subscribe operation asked for latency measurment or not. 
    // There is no point to track long-poll operation latency.
    if (operationType != PNSubscribeOperation) {
        
        NSTimeInterval date = [[NSDate date] timeIntervalSince1970];
        pn_trylock(&_resourceAccessLock, ^{
            
            NSNumber *startDate = self.trackedLatencies[identifier];
            if (startDate) {
                
                [self.trackedLatencies removeObjectForKey:identifier];
                [self setLatency:(date - startDate.doubleValue) forOperation:operationType];
            }
        });
    }

}

#pragma mark - Telemetry information update

- (void)setLatency:(NSTimeInterval)latency forOperation:(PNOperationType)operationType {
    
    // Check whether subscribe operation asked for latency measurment or not. 
    // There is no point to track long-poll operation latency.
    if (operationType != PNSubscribeOperation) {
        
        NSNumber *date = @([[NSDate date] timeIntervalSince1970]);
        pn_trylock(&_resourceAccessLock, ^{
            
            NSString *endpointName = [self endpointNameForOperation:operationType];
            NSMutableArray *latencies = self.latencies[endpointName];
            if (!latencies) {
                latencies = [NSMutableArray new];
                self.latencies[endpointName] = latencies;
            }
            // Store latency information along with timestamp which can be used for clean up.
            [latencies addObject:@{ kPNOperationDateKey: date, kPNOperationLatencyKey: @(latency) }];
        });
    }
}


#pragma mark - Operation information

- (NSString *)endpointNameForOperation:(PNOperationType)operationType {
    
    NSString *operation = nil;
    switch (operationType) {
        case PNPublishOperation: 
            operation = @"pub";
            break;
        case PNHistoryOperation: 
        case PNHistoryForChannelsOperation: 
            operation = @"hist";
            break;
        case PNUnsubscribeOperation: 
        case PNWhereNowOperation: 
        case PNHereNowGlobalOperation: 
        case PNHereNowForChannelOperation: 
        case PNHereNowForChannelGroupOperation: 
        case PNHeartbeatOperation: 
        case PNSetStateOperation: 
        case PNStateForChannelOperation: 
        case PNStateForChannelGroupOperation: 
            operation = @"pres";
            break;
        case PNAddChannelsToGroupOperation: 
        case PNRemoveChannelsFromGroupOperation: 
        case PNChannelGroupsOperation: 
        case PNRemoveGroupOperation: 
        case PNChannelsForGroupOperation: 
            operation = @"cg";
            break;
        case PNPushNotificationEnabledChannelsOperation: 
        case PNAddPushNotificationsOnChannelsOperation: 
        case PNRemovePushNotificationsFromChannelsOperation: 
        case PNRemoveAllPushNotificationsOperation: 
            operation = @"push";
            break;
        default:
            operation = @"time";
            break;
    }
    
    return operation;
}


#pragma mark - Handlers

- (void)handleCleanUpTimer:(NSTimer *)timer {
    
    pn_trylock(&_resourceAccessLock, ^{
        
        NSTimeInterval date = [[NSDate date] timeIntervalSince1970];
        NSArray<NSString *> *endpoints = self.latencies.allKeys;
        for (NSString *key in endpoints) {
            
            NSMutableArray *outdatedLatencies = [NSMutableArray new];
            NSMutableArray<NSDictionary *> *latencies = self.latencies[key];
            for (NSDictionary *latencyInformation in latencies) {
                NSNumber *latencyStoreDate = latencyInformation[kPNOperationDateKey];
                if (date - latencyStoreDate.doubleValue > kPNOperationLatencyMaximumAge) {
                    [outdatedLatencies addObject:latencyInformation];
                }
            }
            [latencies removeObjectsInArray:outdatedLatencies];
            if (latencies.count == 0) { [self.latencies removeObjectForKey:key]; }
        }
    });
}


#pragma mark - Misc

- (void)invalidate {
    
    if ([_cleanUpTimer isValid]) { [_cleanUpTimer invalidate]; }
    _cleanUpTimer = nil;
}

#pragma mark -


@end
