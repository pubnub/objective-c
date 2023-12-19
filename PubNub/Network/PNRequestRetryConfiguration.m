#import "PNRequestRetryConfiguration+Private.h"


#pragma mark Types

/// Retry delay computation policies.
typedef NS_ENUM(NSUInteger, PNRequestRetryPolicy) {
    /// Use equal delays between retry attempts.
    PNLinearRetryPolicy,

    /// Use a `minimumDelay` delay that will exponentially increase with each failed request retry attempt.
    PNExponentialRetryPolicy
};


#pragma mark - Macro

#define VARARGS_TO_ENDPOINTS_ARRAY(firstValue, type) ({ \
    NSMutableArray *excludedEndpoints = [NSMutableArray array]; \
    type endpoint = firstValue; \
    va_list args; \
    va_start(args, firstValue); \
    while (endpoint != 0) { \
        [excludedEndpoints addObject:@(endpoint)]; \
        endpoint = va_arg(args, type); \
    } \
    va_end(args); \
    excludedEndpoints; \
})


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Private interface declaration

@interface PNRequestRetryConfiguration ()

#pragma mark - Information

/// Retry delay computation policy.
@property(nonatomic, assign) PNRequestRetryPolicy policy;

/// Minimum delay between retry attempts.
///
/// The delay is used for the `PNLinearRetryPolicy` policy, which is used between retry attempts. For the
/// `PNExponentialRetryPolicy` policy, which is used as the `minimumDelay`, which will be used to calculate the next
/// delay based on the number of retry attempts.
///
/// > Important: The minimum allowed delay is **2.0**.
@property(nonatomic, assign) NSTimeInterval minimumDelay;

/// Maximum allowed computed delay that should be used between retry attempts.
@property(nonatomic, assign) NSTimeInterval maximumInterval;

/// Maximum allowed number of failed requests that should be retried automatically before reporting an error.
///
/// > Important: The maximum allowed number of retries is **10**.
@property(nonatomic, assign) NSUInteger maximumRetry;

/// A list of endpoint groups for which automatic retry shouldn't be used.
@property(nonatomic, nullable, strong) NSArray *excludedEndpoints;


#pragma mark - Initialization and configuration

/// Initialize request retry configuration.
///
/// - Parameters:
///   - policy: Retry delay computation policy.
///   - minimumDelay: Delay is used for the 'PNLinearRetryPolicy' policy, which is used between retry attempts.
///     For the 'PNExponentialRetryPolicy' policy, which is used as the `minimumDelay`, which will be used to calculate
///     the next delay based on the number of retry attempts.
///   - maximumDelay: Maximum allowed computed delay that should be used between retry attempts.
///   - maximumRetry: The number of failed requests that should be retried automatically before reporting an error.
///   - endpoints: A list of endpoint groups for which automatic retry shouldn't be used.
/// - Returns: Initialized automatic request retry configuration.
- (instancetype)initWithPolicy:(PNRequestRetryPolicy)policy
                  minimumDelay:(NSTimeInterval)minimumDelay
                  maximumDelay:(NSTimeInterval)maximumDelay
                  maximumRetry:(NSUInteger)maximumRetry
             excludedEndpoints:(NSArray<NSNumber *> *)endpoints;


#pragma mark - Helpers

/// Identify group of endpoints from `url`.
///
/// - Returns: Returns identifier endpoint group or `PNUnknownEndpoint` if none of checks matched.
- (PNEndpoint)endpointFromURL:(NSURL *)url;

/// Check whether provided URL belong to the group of excluded endpoints or not.
///
/// - Returns: `YES` if endpoint with the provided `url` has been explicitly excluded from automatic retry.
- (BOOL)isExcludedEndpointURL:(NSURL *)url;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNRequestRetryConfiguration

#pragma mark - Initialization and configuration

+ (instancetype)configurationWithLinearDelay {
    return [self configurationWithLinearDelayExcludingEndpoints:0];
}

+ (instancetype)configurationWithLinearDelayExcludingEndpoints:(PNEndpoint)endpoints, ... {
    return [[self alloc] initWithPolicy:PNLinearRetryPolicy
                           minimumDelay:2.f
                           maximumDelay:0.0f
                           maximumRetry:10
                      excludedEndpoints:VARARGS_TO_ENDPOINTS_ARRAY(endpoints, PNEndpoint)];
}

+ (instancetype)configurationWithLinearDelay:(NSTimeInterval)delay
                                maximumRetry:(NSUInteger)maximumRetry
                           excludedEndpoints:(PNEndpoint)endpoints, ... {
    return [[self alloc] initWithPolicy:PNLinearRetryPolicy
                           minimumDelay:delay
                           maximumDelay:0.0f
                           maximumRetry:maximumRetry
                      excludedEndpoints:VARARGS_TO_ENDPOINTS_ARRAY(endpoints, PNEndpoint)];
}

+ (instancetype)configurationWithExponentialDelay {
    return [self configurationWithExponentialDelayExcludingEndpoints:0];
}

+ (instancetype)configurationWithExponentialDelayExcludingEndpoints:(PNEndpoint)endpoints, ... {
    return [[self alloc] initWithPolicy:PNExponentialRetryPolicy
                           minimumDelay:2.f
                           maximumDelay:150.f
                           maximumRetry:6
                      excludedEndpoints:VARARGS_TO_ENDPOINTS_ARRAY(endpoints, PNEndpoint)];
}

+ (instancetype)configurationWithExponentialDelay:(NSTimeInterval)minimumDelay
                                     maximumDelay:(NSTimeInterval)maximumDelay
                                     maximumRetry:(NSUInteger)maximumRetry
                                excludedEndpoints:(PNEndpoint)endpoints, ... {
    return [[self alloc] initWithPolicy:PNExponentialRetryPolicy
                           minimumDelay:minimumDelay
                           maximumDelay:maximumDelay
                           maximumRetry:maximumRetry
                      excludedEndpoints:VARARGS_TO_ENDPOINTS_ARRAY(endpoints, PNEndpoint)];
}

- (instancetype)initWithPolicy:(PNRequestRetryPolicy)policy
                  minimumDelay:(NSTimeInterval)minimumDelay
                  maximumDelay:(NSTimeInterval)maximumDelay
                  maximumRetry:(NSUInteger)maximumRetry
             excludedEndpoints:(NSArray<NSNumber *> *)endpoints {
    if ((self = [super init])) {
        _policy = policy;
        _minimumDelay = MAX(minimumDelay, 2.0f);
        _maximumInterval = MAX(_minimumDelay, maximumDelay);
        _maximumRetry = MIN(maximumRetry, 10);
        _excludedEndpoints = endpoints.count ? endpoints : nil;
    }

    return self;
}

#pragma mark - NSCopying implementation

- (id)copyWithZone:(NSZone *)zone {
    PNRequestRetryConfiguration *configuration = [[PNRequestRetryConfiguration allocWithZone:zone] init];
    configuration.policy = self.policy;
    configuration.minimumDelay = self.minimumDelay;
    configuration.maximumInterval = self.maximumInterval;
    configuration.maximumRetry = self.maximumRetry;

    return configuration;
}


#pragma mark - Helpers

- (PNEndpoint)endpointFromURL:(NSURL *)url {
    PNEndpoint endpoint = PNUnknownEndpoint;
    NSString *path = url.path;

    if ([path hasPrefix:@"/v2/subscribe"]) endpoint = PNSubscribeEndpoint;
    else if ([path hasPrefix:@"/publish/"] || [path hasPrefix:@"/signal/"]) endpoint = PNMessageSendEndpoint;
    else if ([path hasPrefix:@"/v2/presence"]) endpoint = PNPresenceEndpoint;
    else if ([path hasPrefix:@"/v2/history/"] || [path hasPrefix:@"/v3/history"]) endpoint = PNMessageStorageEndpoint;
    else if ([path hasPrefix:@"/v1/message-actions/"]) endpoint = PNMessageReactionsEndpoint;
    else if ([path hasPrefix:@"/v1/channel-registration/"]) endpoint = PNChannelGroupsEndpoint;
    else if ([path hasPrefix:@"/v2/objects/"]) endpoint = PNAppContextEndpoint;
    else if ([path hasPrefix:@"/v1/push/"] || [path hasPrefix:@"/v2/push/"]) {
        endpoint = PNDevicePushNotificationsEndpoint;
    } else if ([path hasPrefix:@"/v1/files/"]) {
        endpoint = PNFilesEndpoint;
    }

    return endpoint;
}

- (BOOL)isExcludedEndpointURL:(NSURL *)url {
    if (!self.excludedEndpoints.count) return NO;

    return [self.excludedEndpoints containsObject:@([self endpointFromURL:url])];
}

- (BOOL)isRetriableRequest:(NSURLRequest *)request 
              withResponse:(NSURLResponse *)response
              retryAttempt:(NSUInteger)retryAttempt {
    if ([self isExcludedEndpointURL:request.URL]) return NO;
    else if (retryAttempt > self.maximumRetry) return NO;

    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    return httpResponse.statusCode == 429 || httpResponse.statusCode >= 500 || httpResponse.statusCode == 0;
}

- (NSTimeInterval)retryDelayForFailedRequest:(NSURLRequest *)request
                                withResponse:(NSURLResponse *)response
                                retryAttempt:(NSUInteger)retryAttempt {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSString *retryAfterHeader = [httpResponse valueForHTTPHeaderField:@"retry-after"];
    NSTimeInterval delay = -1.f;
    if (![self isRetriableRequest:request withResponse:response retryAttempt:retryAttempt]) return delay;

    if (retryAfterHeader && httpResponse.statusCode == 429) delay = retryAfterHeader.doubleValue;
    else if (self.policy == PNLinearRetryPolicy) delay = self.minimumDelay;
    else delay = MIN(self.minimumDelay * pow(2, retryAttempt - 1), self.maximumInterval);

    return delay + (float)arc4random_uniform(UINT32_MAX) / UINT32_MAX;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<PNRequestRetryConfiguration: %p\n\tpolicy: %@\n\tminimum delay: %f%@"
                                       "\n\tmaximum retry attempts: %lu\n>",
        self,
        self.policy == PNLinearRetryPolicy ? @"linear" : @"exponential",
        self.minimumDelay,
        self.policy == PNExponentialRetryPolicy ? [NSString stringWithFormat:@"\n\tmaximum delay: %f", self.maximumInterval] : @"",
        self.maximumRetry
    ];
}

#pragma mark -


@end
