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

/// `PubNub` client instance logger.
///
/// Logger can be used to add additional logs.
@property(strong, nonatomic) PNLoggerManager *logger;


#pragma mark - Misc

/// Serialize configuration object.
///
/// - Returns: Configuration object data represented as `NSDictionary`.
- (NSDictionary *)dictionaryRepresentation;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
