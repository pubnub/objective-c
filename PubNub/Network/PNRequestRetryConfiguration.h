#import <Foundation/Foundation.h>
#import <PubNub/PNStructures.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Request automatic retry configuration.
///
/// The **PubNub**'s client network layer uses retry configuration to calculate intervals between failed request
/// recovery attempts.
///
/// - Since: 5.3.0
/// - Copyright: 2010-2023 PubNub, Inc.
@interface PNRequestRetryConfiguration : NSObject <NSCopying>


#pragma mark - Initialization and configuration

/// Create a request retry configuration with a linear retry policy.
///
/// Configurations with a linear retry policy will use equal intervals between retry attempts.
/// The default implementation uses a **2.0** seconds interval and **10** maximum retry attempts.
///
/// > Note: The PubNub client will schedule request retries after a calculated interval, but the actual retry may
/// not happen at the same moment (there is a small leeway).
///
/// #### Example:
/// ```objc
/// PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo"
///                                                                  subscribeKey:@"demo"
///                                                                        userID:@"user"];
/// configuration.requestRetry = [PNRequestRetryConfiguration configurationWithLinearInterval];
/// ```
///
/// - Returns: Initialized automatic request retry configuration.
+ (instancetype)configurationWithLinearInterval;

/// Create a request retry configuration with a linear retry policy.
///
/// Configurations with a linear retry policy will use equal intervals between retry attempts.
/// The default implementation uses a **2.0** seconds interval and **10** maximum retry attempts.
///
/// > Note: The PubNub client will schedule request retries after a calculated interval, but the actual retry may
/// not happen at the same moment (there is a small leeway).
///
/// #### Example:
/// ```objc
/// PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo"
///                                                                  subscribeKey:@"demo"
///                                                                        userID:@"user"];
/// // Disabling message publish and signal request automatic retry.
/// configuration.requestRetry = [PNRequestRetryConfiguration configurationWithLinearIntervalExcludingEndpoints:PNMessageSendEndpoint, 0];
/// ```
///
/// - Parameter endpoints: A `0`-terminated list of endpoint groups for which automatic retry shouldn't be used.
/// - Returns: Initialized automatic request retry configuration.
+ (instancetype)configurationWithLinearIntervalExcludingEndpoints:(PNEndpoint)endpoints, ...;

/// Create a request retry configuration with a linear retry policy.
///
/// Configurations with a linear retry policy will use equal intervals between retry attempts.
///
/// > Note: The PubNub client will schedule request retries after a calculated interval, but the actual retry may
/// not happen at the same moment (there is a small leeway).
///
/// #### Example:
/// ```objc
/// PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo"
///                                                                  subscribeKey:@"demo"
///                                                                        userID:@"user"];
/// // Disabling message publish, signal and message storage access request automatic retry.
/// configuration.requestRetry = [PNRequestRetryConfiguration configurationWithLinearInterval:3.f
///                                                                      maximumRetryAttempts:3
///                                                                         excludedEndpoints:PNMessageSendEndpoint, PNMessageStorageEndpoint, 0];
/// ```
///
/// - Parameters:
///   - interval: An interval between failed requests automatically retries attempts.
///     > Important: The minimum allowed interval is **2.0**.
///   - maximumRetryAttempts: The number of failed requests that should be retried automatically before reporting an
///   error.
///     > Important: The maximum allowed number of retries is **10**.
///   - endpoints: A `0`-terminated list of endpoint groups for which automatic retry shouldn't be used.
/// - Returns: Initialized automatic request retry configuration.
+ (instancetype)configurationWithLinearInterval:(NSTimeInterval)interval
                           maximumRetryAttempts:(NSUInteger)maximumRetryAttempts
                              excludedEndpoints:(PNEndpoint)endpoints, ...;

/// Create a request retry configuration with a exponential retry policy.
///
/// Configurations with a exponential retry policy will use `minimumDelay` interval that will exponentially increase 
/// with each failed request retry attempt.
/// The default implementation uses a **2.0** seconds minimum, **150** maximum intervals, and **6** maximum retry
/// attempts.
///
/// > Note: The PubNub client will schedule request retries after a calculated interval, but the actual retry may
/// not happen at the same moment (there is a small leeway).
///
/// #### Example:
/// ```objc
/// PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo"
///                                                                  subscribeKey:@"demo"
///                                                                        userID:@"user"];
/// configuration.requestRetry = [PNRequestRetryConfiguration configurationWithExponentialInterval];
/// ```
///
/// - Returns: Initialized automatic request retry configuration.
+ (instancetype)configurationWithExponentialInterval;

/// Create a request retry configuration with a exponential retry policy.
///
/// Configurations with a exponential retry policy will use `minimumDelay` interval that will exponentially increase
/// with each failed request retry attempt.
/// The default implementation uses a **2.0** seconds minimum, **150** maximum intervals, and **6** maximum retry
/// attempts.
///
/// > Note: The PubNub client will schedule request retries after a calculated interval, but the actual retry may
/// not happen at the same moment (there is a small leeway).
///
/// #### Example:
/// ```objc
/// PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo"
///                                                                  subscribeKey:@"demo"
///                                                                        userID:@"user"];
/// // Disabling message publish and signal request automatic retry.
/// configuration.requestRetry = [PNRequestRetryConfiguration configurationWithExponentialIntervalExcludingEndpoints:PNMessageSendEndpoint, 0];
/// ```
///
/// - Parameter endpoints: A `0`-terminated list of endpoint groups for which automatic retry shouldn't be used.
/// - Returns: Initialized automatic request retry configuration.
+ (instancetype)configurationWithExponentialIntervalExcludingEndpoints:(PNEndpoint)endpoints, ...;

/// Create a request retry configuration with an exponential retry policy.
///
/// Configurations with an exponential retry policy will use a base interval that will exponentially increase with each
/// failed request retry attempt.
///
/// > Note: The PubNub client will schedule request retries after a calculated interval, but the actual retry may
/// not happen at the same moment (there is a small leeway).
///
/// #### Example:
/// ```objc
/// PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo"
///                                                                  subscribeKey:@"demo"
///                                                                        userID:@"user"];
/// // Disabling message publish, signal and message storage access request automatic retry.
/// configuration.requestRetry = [PNRequestRetryConfiguration configurationWithExponentialInterval:3.f
///                                                                                maximumInterval:120.f
///                                                                           maximumRetryAttempts:3
///                                                                              excludedEndpoints:PNMessageSendEndpoint, PNMessageStorageEndpoint, 0];
/// ```
///
/// - Parameters:
///   - minimumInterval: Base interval, which will be used to calculate the next interval depending on the number of
///     retry attempts.
///     > Important: The minimum allowed interval is **2.0**.
///   - maximumInterval: Maximum allowed computed interval that should be used between retry attempts.
///   - maximumRetryAttempts: The number of failed requests that should be retried automatically before reporting an
///   error.
///     > Important: The maximum allowed number of retries is **10**.
///   - endpoints: A `0`-terminated list of endpoint groups for which automatic retry shouldn't be used.
/// - Returns: Initialized automatic request retry configuration.
+ (instancetype)configurationWithExponentialInterval:(NSTimeInterval)minimumInterval
                                     maximumInterval:(NSTimeInterval)maximumInterval
                                maximumRetryAttempts:(NSUInteger)maximumRetryAttempts
                                   excludedEndpoints:(PNEndpoint)endpoints, ...;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
