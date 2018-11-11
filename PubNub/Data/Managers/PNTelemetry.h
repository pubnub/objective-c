#import <Foundation/Foundation.h>
#import "PNStructures.h"
#import "PNDefines.h"


NS_ASSUME_NONNULL_BEGIN

/**
 @brief      Class which responsible for gathering of client's 'telemetry'.
 @discussion Track various client parameters which can be used for service performance analysis.
 
 @author Sergey Mamontov
 @since 4.6.2
 @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNTelemetry : NSObject


///------------------------------------------------
/// @name Telemetry information
///------------------------------------------------

/**
 @brief      Retrieve dictionary with latencies for each used API endpoint.
 @discussion Dictionary will contain pre-formatted keys, so SDK will be able to use them with URL building 
             method to append to each API endpoint.
 
 @return Dictionary with latency information from last minute for each used API endpoint.
 
 @since 4.6.2
 */
- (NSDictionary *)operationsLatencyForRequest;


///------------------------------------------------
/// @name Telemetry information tracking
///------------------------------------------------

#if !PN_URLSESSION_TRANSACTION_METRICS_AVAILABLE || !PN_OS_VERSION_10_SDK_API_IS_SAFE
/**
 @brief      Start request execution time tracking.
 @discussion Internally manager will mark time when request has been started and it will be used to calculate
             resulting latency. This methods used if metrics not available.

 @param operationType One of \b PNOperationType enumerator fields which describe for what kind of operation
                      manager should start tracking execution time.
 @param identifier    Reference on unique operation identifier which will be used to store start time.

 @since 4.6.2
 */
- (void)startLatencyMeasureFor:(PNOperationType)operationType withIdentifier:(NSString *)identifier;

/**
 @brief      Stop request execution time tracking.
 @discussion Internally manager will find information about request start timestamp and calculate resulting
             operation execution time. This methods used if metrics not available.

 @param operationType One of \b PNOperationType enumerator fields which describe what kind of operation
                      manager should stop tracking execution time.
 @param identifier    Reference on unique operation identifier which will be used to find information about
                      operation start time.

 @since 4.6.2
 */
- (void)stopLatencyMeasureFor:(PNOperationType)operationType withIdentifier:(NSString *)identifier;
#endif


///------------------------------------------------
/// @name Telemetry information update
///------------------------------------------------

/**
 @brief      Store latency for operation which has been processed recently.
 @discussion Method allow to gathen (and maintain internally) information about requests latency (or request 
             duration if metrics not available).
 
 @param latency       Calculated operation latency.
 @param operationType One of \b PNOperationType enumerator fields which describe what kind of operation
                      manager should store request latency.
 
 @since 4.6.2
 */
- (void)setLatency:(NSTimeInterval)latency forOperation:(PNOperationType)operationType;


///------------------------------------------------
/// @name Misc
///------------------------------------------------

/**
 @brief      Invalidate accumulated telemetry information.
 @discussion Along with invalidated data all scheduled timers will be invalidated as well.
 */
- (void)invalidate;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
