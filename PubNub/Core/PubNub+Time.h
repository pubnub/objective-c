#import <PubNub/PubNub+Core.h>

// Request
#import <PubNub/PNTimeRequest.h>

// Response
#import <PubNub/PNTimeResult.h>

// Deprecated
#import <PubNub/PNTimeAPICallBuilder.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// **PubNub** `Time` API.
@interface PubNub (Time)


#pragma mark - Time token API builder interdace (deprecated)

/// Time API access builder.
@property (nonatomic, readonly, strong) PNTimeAPICallBuilder * (^time)(void)
    DEPRECATED_MSG_ATTRIBUTE("Builder-based interface deprecated. Please use corresponding request-based interfaces.");


#pragma mark - Time token request

/// Fetch high-precision PubNub timetoken.
///
/// #### Example:
/// ```objc
/// [self.client timeWithRequest:[PNTimeRequest new] completion:^(PNTimeResult *result, PNErrorStatus *status) {
///     if (!status.isError) {
///         // Handle downloaded server time token using: `result.data.timetoken`.
///     } else {
///         // Handle time token fetch error. Check `category` property to find out possible issue because of which
///         // request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - request: Request with information required to fetch timetoken.
///   - block: Timetoken fetch request completion block.
- (void)timeWithRequest:(PNTimeRequest *)request completion:(PNTimeCompletionBlock)block
    NS_SWIFT_NAME(timeWithRequest(_:completion:));

/// Request current time from **PubNub** service servers.
///
/// #### Example:
/// ```objc
/// [self.client timeWithCompletion:^(PNTimeResult *result, PNErrorStatus *status) {
///     if (!status.isError) {
///         // Handle downloaded server time token using: `result.data.timetoken`.
///     } else {
///         // Handle time token download error. Check `category` property to find out possible issue because of which
///         // request did fail.
///         //
///         // Request can be resent using: `[status retry];`.
///     }
/// }];
/// ```
///
/// - Parameter block: Time request completion block.
- (void)timeWithCompletion:(PNTimeCompletionBlock)block 
    NS_SWIFT_NAME(timeWithCompletion(_:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-timeWithRequest:completion:' method instead.");

#pragma mark -


@end

NS_ASSUME_NONNULL_END
