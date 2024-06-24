#import <PubNub/PubNub.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// **PubNub** core extension for backward compatibility.
///
/// Extension contains methods which handles deprecated features and compute required values.
@interface PubNub (Deprecated)


#pragma mark - Result and Status

/// Set values for deprecated properties.
/// 
/// - Parameters:
///   - result: Operation processing result object.
///   - request: Actual request which has been used to access remote origin resource.
///   - response: Remote origin response with results of access to the resource.
- (void)updateResult:(PNOperationResult *)result
         withRequest:(nullable PNTransportRequest *)request
            response:(nullable id<PNTransportResponse>)response;

#pragma mark -

@end


NS_ASSUME_NONNULL_END
