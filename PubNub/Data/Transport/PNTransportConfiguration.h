#import <Foundation/Foundation.h>
#import <PubNub/PNRequestRetryConfiguration.h>
#import <PubNub/PNLoggerManager.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// General transport module configuration.
@interface PNTransportConfiguration : NSObject


#pragma mark - Properties

/// Request automatic retry configuration.
@property(strong, nullable, nonatomic, readonly) PNRequestRetryConfiguration *retryConfiguration;

/// Maximum simultaneously connections which can be opened.
@property(assign, nonatomic, readonly) NSUInteger maximumConnections;

/// `PubNub` client instance logger.
///
/// Logger can be used to add additional logs.
@property(strong, nonatomic, readonly) PNLoggerManager *logger;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
