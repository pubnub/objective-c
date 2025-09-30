#import "PNTransportMiddlewareConfiguration.h"
#import "PNTransportConfiguration+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// Transport middleware module configuration private extension.
@interface PNTransportMiddlewareConfiguration ()


#pragma mark - Properties
/// Current `PubNub` instance configuration object.
@property(strong, nonatomic) PNConfiguration *configuration;

/// Maximum simultaneously connections which can be opened.
@property(assign, nonatomic) NSUInteger maximumConnections;


/// Initialized and ready to use transport implementation.
@property(strong, nonatomic) id<PNTransport> transport;

/// Unique `PubNub` instance identifier.
@property(copy, nonatomic) NSString *clientInstanceId;

/// `PubNub` client instance logger.
///
/// Logger can be used to add additional logs.
@property(strong, nonatomic) PNLoggerManager *logger;


#pragma mark - Initialization and Configuration

/// Initialize middleware configuration.
///
/// - Parameters:
///   - configuration: `PubNub` client configuration object.
///   - clientInstanceId: Unique `PubNub` instance identifier.   
///   - transport: Instantiated transport object.
///   - maximumConnections: Maximum simultaneously connections which can be opened.
///   - logger: `PubNub` client instance logger.
/// - Returns: Initialized middleware configuration object.
- (instancetype)initWithClientConfiguration:(PNConfiguration *)configuration
                           clientInstanceId:(NSString *)clientInstanceId
                                  transport:(id<PNTransport>)transport
                         maximumConnections:(NSUInteger)maximumConnections
                                     logger:(PNLoggerManager *)logger;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNTransportMiddlewareConfiguration

#pragma mark - Properties

- (PNTransportConfiguration *)transportConfiguration {
    PNTransportConfiguration *configuration = [PNTransportConfiguration new];
    configuration.retryConfiguration = self.configuration.requestRetry;
    configuration.maximumConnections = self.maximumConnections;
    configuration.logger = self.logger;
    
    return configuration;
}


#pragma mark - Initialization and Configuration

+ (instancetype)configurationWithClientConfiguration:(PNConfiguration *)configuration
                                    clientInstanceId:(NSString *)clientInstanceId
                                           transport:(id<PNTransport>)transport
                                  maximumConnections:(NSUInteger)maximumConnections
                                              logger:(PNLoggerManager *)logger {
    return [[self alloc] initWithClientConfiguration:configuration
                                    clientInstanceId:(NSString *)clientInstanceId
                                           transport:transport
                                  maximumConnections:maximumConnections
                                              logger:logger];
}

- (instancetype)initWithClientConfiguration:(PNConfiguration *)configuration
                           clientInstanceId:(NSString *)clientInstanceId
                                  transport:(id<PNTransport>)transport
                         maximumConnections:(NSUInteger)maximumConnections
                                     logger:(PNLoggerManager *)logger {
    if ((self = [super init])) {
        _clientInstanceId = [clientInstanceId copy];
        _maximumConnections = maximumConnections;
        _configuration = configuration;
        _transport = transport;
        _logger = logger;
    }
    
    return self;
}

#pragma mark -


@end
