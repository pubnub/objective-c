#import <Foundation/Foundation.h>
#import <PubNub/PNRequestRetryConfiguration.h>
#ifndef PUBNUB_DISABLE_LOGGER
#import <PubNub/PNLLogger.h>
#endif // PUBNUB_DISABLE_LOGGER


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// General transport module configuration.
@interface PNTransportConfiguration : NSObject


#pragma mark - Properties

/// Request automatic retry configuration.
@property(strong, nullable, nonatomic, readonly) PNRequestRetryConfiguration *retryConfiguration;

/// Maximum simultaneously connections which can be opened.
@property(assign, nonatomic, readonly) NSUInteger maximumConnections;

#ifndef PUBNUB_DISABLE_LOGGER
/// `PubNub` client instance logger.
///
/// Logger can be used to add additional logs into console and file (if enabled).
@property(strong, nonatomic, readonly) PNLLogger *logger;
#endif // PUBNUB_DISABLE_LOGGER

#pragma mark -


@end

NS_ASSUME_NONNULL_END
