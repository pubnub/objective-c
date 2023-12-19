#import <Foundation/Foundation.h>
#import <PubNub/PNStructures.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Request automatic retry configuration.
///
/// The **PubNub**'s client network layer uses retry configuration to calculate delays between failed request recovery
/// attempts.
///
/// - Since: 5.3.0
/// - Copyright: 2010-2023 PubNub, Inc.
@interface PNRequestRetryConfiguration : NSObject <NSCopying>


#pragma mark - Initialization and configuration

/// Create a request retry configuration with a linear retry policy.
///
/// Configurations with a linear retry policy will use equal delays between retry attempts.
/// The default implementation uses a **2.0** seconds delay and **10** maximum retry attempts.
///
/// > Note: The PubNub client will schedule request retries after a calculated delay, but the actual retry may not
/// happen at the same moment (there is a small leeway).
///
/// #### Example:
/// ```objc
/// PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo"
///                                                                  subscribeKey:@"demo"
///                                                                        userID:@"user"];
/// configuration.requestRetry = [PNRequestRetryConfiguration configurationWithLinearDelay];
/// ```
///
/// - Returns: Initialized automatic request retry configuration.
+ (instancetype)configurationWithLinearDelay;

/// Create a request retry configuration with a linear retry policy.
///
/// Configurations with a linear retry policy will use equal delays between retry attempts.
/// The default implementation uses a **2.0** seconds delay and **10** maximum retry attempts.
///
/// > Note: The PubNub client will schedule request retries after a calculated delay, but the actual retry may not
/// happen at the same moment (there is a small leeway).
///
/// #### Example:
/// ```objc
/// PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo"
///                                                                  subscribeKey:@"demo"
///                                                                        userID:@"user"];
/// // Disabling message publish and signal request automatic retry.
/// configuration.requestRetry = [PNRequestRetryConfiguration configurationWithLinearDelayExcludingEndpoints:PNMessageSendEndpoint, 0];
/// ```
///
/// - Parameter endpoints: A `0`-terminated list of endpoint groups for which automatic retry shouldn't be used.
/// - Returns: Initialized automatic request retry configuration.
+ (instancetype)configurationWithLinearDelayExcludingEndpoints:(PNEndpoint)endpoints, ...;

/// Create a request retry configuration with a linear retry policy.
///
/// Configurations with a linear retry policy will use equal delay between retry attempts.
///
/// > Note: The PubNub client will schedule request retries after a calculated delay, but the actual retry may not
/// happen at the same moment (there is a small leeway).
///
/// #### Example:
/// ```objc
/// PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo"
///                                                                  subscribeKey:@"demo"
///                                                                        userID:@"user"];
/// // Disabling message publish, signal and message storage access request automatic retry.
/// configuration.requestRetry = [PNRequestRetryConfiguration configurationWithLinearDelay:3.f
///                                                                           maximumRetry:3
///                                                                      excludedEndpoints:PNMessageSendEndpoint, PNMessageStorageEndpoint, 0];
/// ```
///
/// - Parameters:
///   - delay: Delay between failed requests automatically retries attempts.
///     > Important: The minimum allowed delay is **2.0**.
///   - maximumRetry: The number of failed requests that should be retried automatically before reporting an error.
///     > Important: The maximum allowed number of retries is **10**.
///   - endpoints: A `0`-terminated list of endpoint groups for which automatic retry shouldn't be used.
/// - Returns: Initialized automatic request retry configuration.
+ (instancetype)configurationWithLinearDelay:(NSTimeInterval)delay
                                maximumRetry:(NSUInteger)maximumRetry
                           excludedEndpoints:(PNEndpoint)endpoints, ...;

/// Create a request retry configuration with a exponential retry policy.
///
/// Configurations with an exponential retry policy will use `minimumDelay` that will exponentially increase with each
/// failed request retry attempt.
/// The default implementation uses a **2.0** seconds minimum, **150** maximum delays, and **6** maximum retry attempts.
///
/// > Note: The PubNub client will schedule request retries after a calculated delay, but the actual retry may not
/// happen at the same moment (there is a small leeway).
///
/// #### Example:
/// ```objc
/// PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo"
///                                                                  subscribeKey:@"demo"
///                                                                        userID:@"user"];
/// configuration.requestRetry = [PNRequestRetryConfiguration configurationWithExponentialDelay];
/// ```
///
/// - Returns: Initialized automatic request retry configuration.
+ (instancetype)configurationWithExponentialDelay;

/// Create a request retry configuration with a exponential retry policy.
///
/// Configurations with an exponential retry policy will use `minimumDelay` that will exponentially increase with each
/// failed request retry attempt.
/// The default implementation uses a **2.0** seconds minimum, **150** maximum delays, and **6** maximum retry attempts.
///
/// > Note: The PubNub client will schedule request retries after a calculated delay, but the actual retry may not
/// happen at the same moment (there is a small leeway).
///
/// #### Example:
/// ```objc
/// PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo"
///                                                                  subscribeKey:@"demo"
///                                                                        userID:@"user"];
/// // Disabling message publish and signal request automatic retry.
/// configuration.requestRetry = [PNRequestRetryConfiguration configurationWithExponentialDelayExcludingEndpoints:PNMessageSendEndpoint, 0];
/// ```
///
/// - Parameter endpoints: A `0`-terminated list of endpoint groups for which automatic retry shouldn't be used.
/// - Returns: Initialized automatic request retry configuration.
+ (instancetype)configurationWithExponentialDelayExcludingEndpoints:(PNEndpoint)endpoints, ...;

/// Create a request retry configuration with an exponential retry policy.
///
/// Configurations with an exponential retry policy will use `minimumDelay` that will exponentially increase with each
/// failed request retry attempt.
///
/// > Note: The PubNub client will schedule request retries after a calculated delay, but the actual retry may not
/// happen at the same moment (there is a small leeway).
///
/// #### Example:
/// ```objc
/// PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo"
///                                                                  subscribeKey:@"demo"
///                                                                        userID:@"user"];
/// // Disabling message publish, signal and message storage access request automatic retry.
/// configuration.requestRetry = [PNRequestRetryConfiguration configurationWithExponentialDelay:3.f
///                                                                                maximumDelay:120.f
///                                                                                maximumRetry:3
///                                                                           excludedEndpoints:PNMessageSendEndpoint, PNMessageStorageEndpoint, 0];
/// ```
///
/// - Parameters:
///   - minimumDelay: Base delay, which will be used to calculate the next delay depending on the number of retry
///     attempts.
///     > Important: The minimum allowed delay is **2.0**.
///   - maximumDelay: Maximum allowed computed delay that should be used between retry attempts.
///   - maximumRetry: The number of failed requests that should be retried automatically before reporting an error.
///     > Important: The maximum allowed number of retries is **10**.
///   - endpoints: A `0`-terminated list of endpoint groups for which automatic retry shouldn't be used.
/// - Returns: Initialized automatic request retry configuration.
+ (instancetype)configurationWithExponentialDelay:(NSTimeInterval)minimumDelay
                                     maximumDelay:(NSTimeInterval)maximumDelay
                                     maximumRetry:(NSUInteger)maximumRetry
                                excludedEndpoints:(PNEndpoint)endpoints, ...;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
