#import "PNRequestRetryConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

/// Request automatic retry configuration private extension.
@interface PNRequestRetryConfiguration (Private)


#pragma mark - Helpers

/// Check whether `request` can be retried or not.
///
/// A few scenarios may lead to the `NO` result:
/// * request excluded
/// * status code not retriable
/// * reached the maximum number of retry attempts
///
/// - Returns: `YES` if provided `request` can be retried.
- (BOOL)isRetriableRequest:(NSURLRequest *)request
              withResponse:(NSURLResponse *)response
              retryAttempt:(NSUInteger)retryAttempt;

/// Compute delay between failed request retry attempts.
///
/// - Returns: _Positive_ delay value or _negative_ in case the request can't be retried.
- (NSTimeInterval)retryDelayForFailedRequest:(NSURLRequest *)request
                                withResponse:(NSURLResponse *)response
                                retryAttempt:(NSUInteger)retryAttempt;

/// Serialize retry configuration object.
///
/// - Returns: Retry configuration object data represented as `NSDictionary`.
- (NSDictionary *)dictionaryRepresentation;

#pragma mark -


@end


NS_ASSUME_NONNULL_END
