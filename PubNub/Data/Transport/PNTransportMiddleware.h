#import <Foundation/Foundation.h>
#import <PubNub/PNTransportMiddlewareConfiguration.h>
#import <PubNub/PNTransport.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface implementation

/// Transport middelware module.
///
/// Middleware extend base transport module functionality with behavior expected by the `PubNub` client.
@interface PNTransportMiddleware : NSObject <PNTransport>


#pragma mark - Initialization and Configuration

/// Create transport middleware with `configuration`.
///
/// - Parameter configuration: Transport middleware module configuration object.
/// - Returns: Configured and ready to use transport middleware.
+ (instancetype)middlewareWithConfiguration:(PNTransportMiddlewareConfiguration *)configuration;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
