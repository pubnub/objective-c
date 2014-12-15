//
//  PNReachability.h
//  pubnub
//
//  This class helps PubNub client to monitor
//  PubNub services reachability.
//  WARNING: It is designed only for internal
//           PubNub client library usage.
//
//
//  Created by Sergey Mamontov on 12/7/12.
//
//

#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNError;


#pragma mark - Public interface declaration

@interface PNReachability : NSObject


#pragma mark Properties

// Stores reference on block which will be called each time when service reachability is changed
@property (nonatomic, copy) void(^reachabilityChangeHandleBlock)(BOOL connected);

@property (nonatomic, readonly, assign, getter = isSimulatingNetworkSwitchEvent) BOOL simulatingNetworkSwitchEvent;

@property (atomic, copy) NSString *serviceOrigin;

#pragma mark - Class methods

/**
 * Retrieve reference on reachability monitor instance which will be configured to track PubNub services reachability
 * (using origin provided during PubNub client configuration)
 */
+ (PNReachability *)serviceReachability;


#pragma mark - Instance methods

/**
 * Managing reachability monitor activity
 */
- (void)startServiceReachabilityMonitoring;
- (void)restartServiceReachabilityMonitoring;
- (void)stopServiceReachabilityMonitoring;
- (void)suspend;
- (void)checkSuspended:(void (^)(BOOL suspended))checkCompletionBlock;
- (void)resume;

/**
 * Check whether service reachability check performed or not
 */
- (void)checkServiceReachabilityChecked:(void (^)(BOOL checked))checkCompletionBlock;

/**
 * Check whether PubNub service can be reached now or not
 */
- (void)checkServiceAvailable:(void (^)(BOOL available))checkCompletionBlock;

/**
 * Force reachability monitor to perform reachability check w/o any callbacks.
 * Return whether reachability refresh in it turn cause reachability state change event generation or not.
 */
- (void)refreshReachabilityState:(void (^)(BOOL willGenerateReachabilityChangeEvent))refreshCompletionBlock;
- (void)refreshReachabilityStateWithEvent:(BOOL)shouldGenerateReachabilityChangeEvent
                                 andBlock:(void (^)(BOOL willGenerateReachabilityChangeEvent))refreshCompletionBlock;

/**
 * Allow to update current reachability state according to the error object (there is some situation when sockets may go down
 * on network error long before reachability will notice this)
 */
- (void)updateReachabilityFromError:(PNError *)error;

#pragma mark -


@end
