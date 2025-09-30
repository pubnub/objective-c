#import <PubNub/PNTransportResponse.h>
#import <PubNub/PNTransportRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Extension interface declaration

/// `NSError` extension for transport related errors.
@interface NSError (PNTransport)


#pragma mark - Initialization and Configuration

/// Create error instance for processed `request`.
///
/// Analyze remote response and create error instance to describe `request` processing issues.
///
/// - Parameters:
///   - request: Object which contain all required information to perform request.
///   - response: Remote origin response with results of access to the resource.
///   - error: Request processing error from the transport implementation.
/// - Returns: Configured and ready to use error instance or `nil` in case if `response` doesn't represent error.
+ (nullable instancetype)pn_errorWithTransportRequest:(PNTransportRequest *)request
                                             response:(nullable id<PNTransportResponse>)response
                                                error:(nullable NSError *)error;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
