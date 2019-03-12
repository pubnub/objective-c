#import <Foundation/Foundation.h>
#import "PNStructures.h"
#import "PNDefines.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Class which responsible for gathering of client's 'telemetry'.
 *
 * @discussion Track various client parameters which can be used for service performance analysis.
 *
 * @since 4.6.2
 *
 * @author Serhii Mamontov
 * @version 4.8.4
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNTelemetry : NSObject


#pragma mark Telemetry information

/**
 * @brief Retrieve dictionary with latencies for each used API endpoint.
 *
 * @discussion \a NSDictionary will contain pre-formatted keys, so SDK will be able to use them with
 * URL building method to append to each API endpoint.
 *
 * @return \a NSDictionary with latency information from last minute for each used API endpoint.
 */
- (NSDictionary *)operationsLatencyForRequest;


#pragma mark - Telemetry information tracking

/**
 * @brief Start request execution time tracking.
 *
 * @discussion Internally manager will mark time when request has been started and it will be used
 * to calculate resulting latency. This methods used if metrics not available.
 *
 * @param operationType One of \b PNOperationType enumerator fields which describe for what kind of
 *     operation manager should start tracking execution time.
 * @param identifier Unique operation identifier which will be used to store start time.
 */
- (void)startLatencyMeasureFor:(PNOperationType)operationType withIdentifier:(NSString *)identifier;

/**
 * @brief Stop request execution time tracking.
 *
 * @discussion Internally manager will find information about request start timestamp and calculate
 * resulting operation execution time. This methods used if metrics not available.
 *
 * @param operationType One of \b PNOperationType enumerator fields which describe what kind of
 *     operation manager should stop tracking execution time.
 * @param identifier Unique operation identifier which will be used to find information about
 *     operation start time.
 */
- (void)stopLatencyMeasureFor:(PNOperationType)operationType withIdentifier:(NSString *)identifier;


#pragma mark - Telemetry information update

/**
 * @brief Store latency for operation which has been processed recently.
 *
 * @discussion Method allow to gathen (and maintain internally) information about requests latency
 * (or request duration if metrics not available).
 *
 * @param latency Calculated operation latency.
 * @param operationType One of \b PNOperationType enumerator fields which describe what kind of
 *     operation manager should store request latency.
 */
- (void)setLatency:(NSTimeInterval)latency forOperation:(PNOperationType)operationType;


#pragma mark - Misc

/**
 * @brief Invalidate accumulated telemetry information.
 *
 * @discussion Along with invalidated data all scheduled timers will be invalidated as well.
 */
- (void)invalidate;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
