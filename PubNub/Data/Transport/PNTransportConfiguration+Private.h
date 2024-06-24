#import <PubNub/PubNub.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// General transport module configuration private extension.
@interface PNTransportConfiguration () <NSCopying>


#pragma mark - Properties

/// Request automatic retry configuration.
@property(strong, nullable, nonatomic) PNRequestRetryConfiguration *retryConfiguration;

/// Maximum simultaneously connections which can be opened.
@property(assign, nonatomic) NSUInteger maximumConnections;

#ifndef PUBNUB_DISABLE_LOGGER
/// `PubNub` client instance logger.
///
/// Logger can be used to add additional logs into console and file (if enabled).
@property(strong, nonatomic) PNLLogger *logger;
#endif // PUBNUB_DISABLE_LOGGER

#pragma mark -


@end

NS_ASSUME_NONNULL_END
