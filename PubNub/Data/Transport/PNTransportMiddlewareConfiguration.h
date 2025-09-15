#import <Foundation/Foundation.h>
#import <PubNub/PubNub.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Transport middleware module configuration.
@interface PNTransportMiddlewareConfiguration : NSObject


#pragma mark - Properties

/// Transport module configuration object.
@property(strong, nonatomic, readonly) PNTransportConfiguration *transportConfiguration;

/// Current `PubNub` instance configuration object.
@property(strong, nonatomic, readonly) PNConfiguration *configuration;

/// Initialized and ready to use transport implementation.
@property(strong, nonatomic, readonly) id<PNTransport> transport;

/// Unique `PubNub` instance identifier.
@property(copy, nonatomic, readonly) NSString *clientInstanceId;


#pragma mark - Initialization and Configuration

/// Create middleware configuration.
///
/// - Parameters:
///   - configuration: `PubNub` client configuration object.
///   - clientInstanceId: Unique `PubNub` instance identifier.
///   - transport: Instantiated transport object.
///   - maximumConnections: Maximum simultaneously connections which can be opened.
///   - logger: `PubNub` client instance logger.
/// - Returns: Configured and ready to use middleware configuration object.
+ (instancetype)configurationWithClientConfiguration:(PNConfiguration *)configuration
                                    clientInstanceId:(NSString *)clientInstanceId
                                           transport:(id<PNTransport>)transport
                                  maximumConnections:(NSUInteger)maximumConnections
                                              logger:(PNLoggerManager *)logger;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
